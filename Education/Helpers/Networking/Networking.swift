//
//  Networking.swift
//  Education
//
//  Created by Andrey Medvedev on 16/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

class Networking {
    private static let kServerUrlKey = "kServerUrlKey"

    static let auth = Networking(with: SessionManager(), retrier: nil)
    static let shared = Networking(with: SessionManager(), retrier: ServiceAuthRetrier())

    static var serverUrl: URL? {
        set {
            UserDefaults.standard.set(newValue, forKey: kServerUrlKey)
            UserDefaults.standard.synchronize()
        }

        get {
            let storedValue = UserDefaults.standard.url(forKey: kServerUrlKey)
            return storedValue ?? Constants.serverUrlDefault
        }
    }

    private static let kDataKeyPath: String? = nil

    private var manager = createSessionManager()

    init(with sessionManager: SessionManager, retrier: AuthRetrier?) {
        sessionManager.retrier = retrier
        sessionManager.adapter = retrier

        self.manager = sessionManager
    }

    // MARK: - Requests
    func request(forHost host: URL? = Networking.serverUrl,
                 path: String,
                 method: Alamofire.HTTPMethod) -> URLRequest {
        let request = NSMutableURLRequest()
        request.httpMethod = method.rawValue
        request.url = host?.appendingPathComponent(path)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(CommonValue.appType, forHTTPHeaderField: "App-Type")
        request.setValue(CommonValue.appVersion, forHTTPHeaderField: "App-Version")
        request.setValue(CommonValue.appLang, forHTTPHeaderField: "App-Lang")
        return request as URLRequest
    }

    func request(forUrl url: URL,
                 method: Alamofire.HTTPMethod) -> URLRequest {
        let request = NSMutableURLRequest()
        request.httpMethod = method.rawValue
        request.url = url
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(CommonValue.appType, forHTTPHeaderField: "App-Type")
        request.setValue(CommonValue.appVersion, forHTTPHeaderField: "App-Version")
        request.setValue(CommonValue.appLang, forHTTPHeaderField: "App-Lang")
        return request as URLRequest
    }

    func performRequest(call: URLRequestConvertible,
                        success: @escaping () -> Void,
                        failure: @escaping (NetworkError) -> Void) {
        performRequest(call).responseData(completionHandler: { (response) in
            switch response.result {
            case .success:
                success()
            case .failure:
                failure(response.getNetworkError())
            }
        })
    }

    func performRequestObject<T: Mappable>(call: URLRequestConvertible,
                                           keyPath: String? = Networking.kDataKeyPath,
                                           success: @escaping (T) -> Void,
                                           failure: @escaping (NetworkError) -> Void) {
        performRequest(call).responseObject(keyPath: keyPath, completionHandler: { (response: DataResponse<T>) in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    success(value)
                } else {
                    failure(NetworkError.noData)
                }
            case .failure:
                failure(response.getNetworkError())
            }
        })
    }

    func performRequestArray<T: Mappable>(call: URLRequestConvertible,
                                          keyPath: String? = Networking.kDataKeyPath,
                                          success: @escaping ([T]) -> Void,
                                          failure: @escaping (NetworkError) -> Void) {
        performRequest(call).responseArray(keyPath: keyPath, completionHandler: { (response: DataResponse<[T]>) in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    success(value)
                } else {
                    failure(NetworkError.noData)
                }
            case .failure:
                failure(response.getNetworkError())
            }
        })
    }

    func performRequestArrayJson(call: URLRequestConvertible,
                                 keyPath: String? = Networking.kDataKeyPath,
                                 success: @escaping ([[String: Any]]) -> Void,
                                 failure: @escaping (NetworkError) -> Void) {
        performRequest(call).responseJSON { (response) in
            switch response.result {
            case .success:
                if let resultArray = response.result.value as? [[String: Any]] {
                    success(resultArray)
                } else {
                    failure(NetworkError.incorrectResponse)
                }
            case .failure:
                failure(response.getNetworkError())
            }
        }
    }

    func performUploadRequestObject<T: Mappable>(
        call: URLRequestConvertible,
        upload: @escaping (MultipartFormData) -> Void,
        success: @escaping (T) -> Void,
        failure: @escaping (NetworkError) -> Void) {
        Alamofire.upload(multipartFormData: upload,
                         with: call,
                         encodingCompletion: { (result) in
                            switch result {
                            case .success(let uploadRequest, _, _):
                                uploadRequest.responseJSON(
                                    completionHandler: { (response) in
                                    switch response.result {
                                    case .success:
                                        if let json = response.result.value as? [String: Any],
                                            let object = T.init(JSON: json){
                                            success(object)
                                        } else {
                                            failure(NetworkError.noData)
                                        }
                                    case .failure:
                                        failure(response.getNetworkError())
                                    }
                                })
                            case .failure:
                                failure(NetworkError.defaultError)
                            }
        })
    }

    func performUploadRequestObject<T: Mappable>(
        call: URLRequestConvertible,
        data: Data,
        success: @escaping (T) -> Void,
        failure: @escaping (NetworkError) -> Void) {
        performUploadRequest(call, with: data).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success:
            if let json = response.result.value as? [String: Any],
                let object = T.init(JSON: json){
                    success(object)
                } else {
                    failure(NetworkError.noData)
                }
            case .failure:
                failure(response.getNetworkError())
            }
        })
    }

    // MARK: - Private
    private func performRequest(_ requestData: URLRequestConvertible) -> DataRequest {
        return self.manager.request(requestData).validate()
    }

    private func performUploadRequest(_ requestData: URLRequestConvertible,
                                      with data: Data) -> UploadRequest {
        return self.manager.upload(data, with: requestData).validate()
    }

    private static func createSessionManager() -> Alamofire.SessionManager {
        return Alamofire.SessionManager.default
    }
}
