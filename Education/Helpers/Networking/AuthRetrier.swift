//
//  AuthRetrier.swift
//  Education
//
//  Created by Andrey Medvedev on 18/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation
import Alamofire

class ServiceAuthRetrier: AuthRetrier {
    // MARK: - RequestRetrier
    override func should(_ manager: SessionManager,
                         retry request: Request,
                         with error: Error,
                         completion: @escaping RequestRetryCompletion) {

        if let response = request.task?.response as? HTTPURLResponse,
            UserManager.isAuthenticated(),
            response.statusCode == 401 {
            if isRefreshing {
                requestsQueue.append(completion)
            } else {
                isRefreshing = true


                let successHandler: ((AuthData) -> Void) = { (authData) in
                    UserManager.auth = authData
                    NotificationCenter.default.post(name: .DidRefreshTokenSucceeded,
                                                    object: nil)

                    self.isRefreshing = false
                    completion(true, 0.0)
                    self.replayQueue()
                }
                let failureHandler: ((NetworkError) -> Void) = { (error) in
                    switch error {
                    case .unauthorized:
                        UserManager.auth = nil
                        NotificationCenter.default.post(name: .DidRefreshTokenFailed,
                                                        object: nil)

                        self.isRefreshing = false
                        completion(false, 0.0)
                        self.cleanQueue()
                    default:
                        self.isRefreshing = false
                        completion(false, 0.0)
                    }

                }

                UserManager.refreshToken(success: successHandler,
                                         failure: failureHandler)
            }
        } else {
            completion(false, 0.0)
        }
    }

    override func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        guard let authHeader = UserManager.authHeaderValue() else {
            return try super.adapt(urlRequest)
        }

        var updatedRequest = urlRequest
        updatedRequest.setValue(authHeader, forHTTPHeaderField: "Authorization")
        updatedRequest.setValue(CommonValue.appType, forHTTPHeaderField: "App-Type")
        updatedRequest.setValue(CommonValue.appVersion, forHTTPHeaderField: "App-Version")
        updatedRequest.setValue(CommonValue.appLang, forHTTPHeaderField: "App-Lang")
        return updatedRequest
    }
}

class AuthRetrier: RequestRetrier, RequestAdapter {
    fileprivate var requestsQueue = [RequestRetryCompletion]()
    fileprivate var isRefreshing = false

    // MARK: - RequestRetrier
    func should(_ manager: SessionManager,
                retry request: Request,
                with error: Error,
                completion: @escaping RequestRetryCompletion) {
    }

    // MARK: - RequestAdapter
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        return urlRequest
    }

    // MARK: - Private
    fileprivate func cleanQueue() {
        requestsQueue.forEach { (retryCallback) in
            retryCallback(false, 0.0)
        }
        requestsQueue.removeAll()
    }

    fileprivate func replayQueue() {
        requestsQueue.forEach { (retryCallback) in
            retryCallback(true, 0.0)
        }
        requestsQueue.removeAll()
    }
}
