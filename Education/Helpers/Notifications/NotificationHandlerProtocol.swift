//
//  NotificationHandlerProtocol.swift
//  Education
//
//  Created by Andrey Medvedev on 19.01.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import UIKit

protocol NotificationHandlerProtocol: AnyObject {
    func handlePushNotification()
}

//extension UIViewController: NotificationHandlerProtocol {
//    func handlePushNotification() {
//        // a default implementation in the extension to make the method optional
//    }
//}
