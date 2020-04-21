//
//  NotificationManager.swift
//  Education
//
//  Created by Andrey Medvedev on 16/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation
import UserNotifications
import Firebase
import FirebaseMessaging

class NotificationManager: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {

    static let shared = NotificationManager()

    var pendingNotification: [String: Any]?

    override init() {
        super.init()
    }

    func setupRemoteNotifications() {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

        if #available(iOS 10.0, *) {
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.delegate = self
            notificationCenter.getNotificationSettings { (settings) in
//                if settings.authorizationStatus == UNAuthorizationStatus.authorized {
//                    DispatchQueue.main.async {
//                        UIApplication.shared.registerForRemoteNotifications()
//                    }
//                }
            }
        } else {

        }
    }

    func registerDeviceToken(deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    static func requestRemoteNotificationsAuthorization() {
        let app = UIApplication.shared
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound],
                                      completionHandler: { (isGranted, _) in
//                                        guard isGranted else { return }
//
//                                        DispatchQueue.main.async {
//                                            UIApplication.shared.registerForRemoteNotifications()
//                                        }
                })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            app.registerUserNotificationSettings(settings)
        }
        app.registerForRemoteNotifications()
    }

    static func subscribeToPushNotifications() {
        subscribeToFCMTopics()
        sendDeviceTokenToServer()
    }

    static func unsubscribeFromPushNotifications() {
        unsubscribeFromFCMTopics()
        resetDeviceToken()
//        deleteDeviceTokenFromServer()
    }

    // MARK: - UNUserNotificationCenterDelegate methods
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if !UserManager.isAuthenticated() {
            // no pushes for signed off users
            completionHandler()
            return
        }

        handlePushNotification(response.notification)
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if !UserManager.isAuthenticated() {
            // no pushes for signed off users
            completionHandler([])
            return
        }

//        handlePushNotification(notification)
//        completionHandler([.badge])
        completionHandler([.badge, .sound, .alert])
    }

    // MARK: - MessagingDelegate methods
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("FCM token: \(fcmToken)")
        UserManager.fcmToken = fcmToken
        NotificationManager.subscribeToPushNotifications()
    }

    // MARK: - Private static
    private static func sendDeviceTokenToServer() {
        if let deviceToken = UserManager.fcmToken,
            deviceToken != UserManager.fcmTokenRegistered{
            NotificationManager.shared.sendDeviceToken(deviceToken)
        }
    }

//    private static func deleteDeviceTokenFromServer() {
//        if let deviceToken = UserManager.deviceToken {
//            NotificationManager.shared.deleteDeviceToken(deviceToken)
//        }
//    }

    private static func resetDeviceToken() {
        InstanceID.instanceID().deleteID { (error) in }
    }

    private static func subscribeToFCMTopics() {
    }

    private static func unsubscribeFromFCMTopics() {
    }

    // MARK: - Private
    private func subscribe(to topic: String) {
        DispatchQueue.main.async {
            if Messaging.messaging().fcmToken != nil {
                Messaging.messaging().subscribe(toTopic: topic)
            }
        }
    }

    private func unsubscribe(from topic: String) {
        DispatchQueue.main.async {
            Messaging.messaging().unsubscribe(fromTopic: topic)
        }
    }

    private func sendDeviceToken(_ deviceToken: String) {
        guard UserManager.isAuthenticated() else { return }

        NotificationsService
            .saveDeviceToken(deviceToken,
                             success: {
                                UserManager.fcmTokenRegistered = deviceToken
                                print("SUCCESS: saveDeviceToken: \(deviceToken)")
            },
                             failure: { error in
                                print("FAILURE: saveDeviceToken: \(error)")
            })
    }

//    private func deleteDeviceToken(_ deviceToken: String) {
//        guard UserManager.isAuthenticated() else { return }
//
//    }

    @available(iOS 10.0, *)
    private func handlePushNotification(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        self.pendingNotification = userInfo as? [String: Any]

        NotificationCenter.default.post(name: Notification.Name.DidReceivePushNotification,
                                        object: nil,
                                        userInfo: nil)
    }
}
