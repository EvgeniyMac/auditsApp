//
//  DataResponse+Additions.swift
//  Education
//
//  Created by Andrey Medvedev on 16/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Alamofire
import ObjectMapper

extension DataResponse {
    func getNetworkError() -> NetworkError {
        if let responseData = self.data,
            let jsonString = String(data: responseData, encoding: String.Encoding.utf8) {

            if let errorValue = self.error as? AFError {
                switch errorValue {
                case .responseValidationFailed(reason:
                    AFError.ResponseValidationFailureReason.unacceptableStatusCode(code: 401)):
                    return NetworkError.unauthorized
                case .responseValidationFailed(reason:
                    AFError.ResponseValidationFailureReason.unacceptableStatusCode(code: 403)):
                    guard let serverError = serverError(fromResponseString: jsonString) else {
                        return NetworkError.defaultError
                    }
                    if serverError.type == ServerError.ErrorType.versionNotSupported {
                        return NetworkError.deprecatedVersion
                    } else {
                        return NetworkError.userBlocked
                    }
                case .responseValidationFailed(reason:
                    AFError.ResponseValidationFailureReason.unacceptableStatusCode(code: 404)):
                    return NetworkError.itemNotFound
                default:
                    return networkError(fromResponseString: jsonString) ?? NetworkError.defaultError
                }
            } else if let errorValue = self.error as? URLError {
                switch errorValue.code {
                case URLError.notConnectedToInternet:
                    return NetworkError.noInternetConnection
                default:
                    return networkError(fromResponseString: jsonString) ?? NetworkError.defaultError
                }
            }
        }
        return NetworkError.defaultError
    }

    // MARK: - Private
    private func networkError(fromResponseString jsonString: String) -> NetworkError? {
        if let serverError = serverError(fromResponseString: jsonString) {
            return NetworkError.serverError(error: serverError)
        }
        return nil
    }

    private func serverError(fromResponseString jsonString: String) -> ServerError? {
        if let error = Mapper<ServerError>().map(JSONString: jsonString) {
            return error
        } else if let dictionary = Mapper<ServerError>().mapDictionary(JSONString: jsonString) {
            return dictionary.values.first
        }
        return nil
    }
}
