//
//  NetworkingError.swift
//  Education
//
//  Created by Andrey Medvedev on 16/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

enum AppError: Error {
    case networkError(NetworkError)
}
