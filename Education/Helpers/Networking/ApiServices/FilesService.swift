//
//  FilesService.swift
//  Education
//
//  Created by Andrey Medvedev on 05.03.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import Alamofire

class FilesService {

    private static let kDataKeyPath: String? = "data"
    private static let kImageName = "img"

    enum FilesCall: URLRequestConvertible {
        case saveImage
        case updateImage(imageId: String)
        case deleteImage(imageId: String)

        private var method: HTTPMethod {
            switch self {
            case .saveImage, .updateImage:
                return .post
            case .deleteImage:
                return .delete
            }
        }

        private var path: String {
            switch self {
            case .saveImage:
                return "v2/files/images/save"
            case .updateImage(let imageId):
                return "v2/files/images/\(imageId)"
            case .deleteImage(let imageId):
                return "v2/files/images/\(imageId)"
            }
        }

        private var encoding: ParameterEncoding {
            switch self {
            case .saveImage, .updateImage:
                return Alamofire.JSONEncoding.default
            case .deleteImage:
                return Alamofire.URLEncoding.default
            }
        }

        func asURLRequest() throws -> URLRequest {
            var request = Networking.shared.request(path: path, method: method)
            switch self {
            case .saveImage, .updateImage:
                if let authHeader = UserManager.authHeaderValue() {
                    request.setValue(authHeader, forHTTPHeaderField: "Authorization")
                }
            default:
                break
            }
            let parameters = Parameters()
            return try self.encoding.encode(request, with: parameters)
        }
    }

    static func saveImage(_ image: UIImage,
                          success: @escaping (RemoteFile) -> Void,
                          failure: @escaping (NetworkError) -> Void) {
        let serviceCall = FilesCall.saveImage
        uploadImage(image, call: serviceCall, success: success, failure: failure)
    }

    static func updateImage(_ image: UIImage,
                            imageId: String,
                            success: @escaping (RemoteFile) -> Void,
                            failure: @escaping (NetworkError) -> Void) {
        let serviceCall = FilesCall.updateImage(imageId: imageId)
        uploadImage(image, call: serviceCall, success: success, failure: failure)
    }

    static func deleteImage(imageId: String,
                            success: @escaping () -> Void,
                            failure: @escaping (NetworkError) -> Void) {
        let serviceCall = FilesCall.deleteImage(imageId: imageId)
        Networking.shared.performRequest(call: serviceCall,
                                         success: success,
                                         failure: failure)
    }

    // MARK: - Private
    private static func uploadImage(_ image: UIImage,
                                    call: FilesCall,
                                    success: @escaping (RemoteFile) -> Void,
                                    failure: @escaping (NetworkError) -> Void) {
        guard let photoData = image.jpegData(compressionQuality: 0.7) else {
            failure(NetworkError.incorrectInputData)
            return
        }

        Networking.shared.performUploadRequestObject(
            call: call,
            upload: { (multipartFormData) in
                multipartFormData.append(photoData,
                                         withName: kImageName,
                                         fileName: kImageName,
                                         mimeType: "image/jpg")
        },
            success: success,
            failure: failure)
    }
}
