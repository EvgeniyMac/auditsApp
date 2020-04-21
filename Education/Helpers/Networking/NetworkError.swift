//
//  NetworkError.swift
//  Education
//
//  Created by Andrey Medvedev on 16/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case defaultError
    case insufficientRequestData
    case incorrectInputData
    case incorrectResponse
    case noData
    case noInternetConnection
    case itemNotFound
    case unauthorized
    case userBlocked
    case deprecatedVersion
    case authFailed
    case serverError(error: ServerError)
    case authError(error: AuthError)

    var localizedDescription: String {
        switch self {
        case .defaultError:
            return Localization.string("error.networking")
        case .insufficientRequestData:
            return Localization.string("error.request_data_insufficient")
        case .incorrectInputData:
            return Localization.string("error.incorrect_input_data")
        case .incorrectResponse:
            return Localization.string("error.incorrect_response")
        case .noData:
            return Localization.string("error.no_data")
        case .noInternetConnection:
            return Localization.string("error.no_internet_connection")
        case .itemNotFound:
            return Localization.string("error.item_not_found")
        case .unauthorized:
            return Localization.string("error.unauthorized")
        case .userBlocked:
            return Localization.string("error.user_blocked")
        case .deprecatedVersion:
            return Localization.string("error.deprecated_version")
        case .authFailed:
            return Localization.string("error.auth_failed")
        case .serverError(let error):
            return error.message
                ?? Localization.string("error.networking")
        case .authError(let error):
            return error.message
                ?? Localization.string("error.networking")
        }
    }
}
