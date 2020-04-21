//
//  AppDelegate.swift
//  Education
//
//  Created by Andrey Medvedev on 15/03/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit
import AlamofireNetworkActivityLogger
import FirebaseAuth
import Sentry

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        startSentry()

        if isDebug {
            NetworkActivityLogger.shared.level = .debug
            NetworkActivityLogger.shared.startLogging()
        }

        NotificationManager.shared.setupRemoteNotifications()

        return true
    }

    private func startSentry() {
        // Create a Sentry client and start crash handler
        do {
            Client.shared = try Client(dsn: Constants.sentryDSN)
            try Client.shared?.startCrashHandler()
        } catch let error {
            print("Sentry error: \(error)")
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Notifications
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs Device Token: " + deviceToken.reduce("", {$0 + String(format: "%02x", $1)}))
        NotificationManager.shared.registerDeviceToken(deviceToken: deviceToken)
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        NotificationManager.shared.pendingNotification = userInfo as? [String: Any]
        NotificationCenter.default.post(name: Notification.Name.DidReceivePushNotification,
                                        object: nil,
                                        userInfo: nil)
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification notification: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }

        NotificationManager.shared.pendingNotification = notification as? [String : Any]
        NotificationCenter.default.post(name: Notification.Name.DidReceivePushNotification,
                                        object: nil,
                                        userInfo: nil)
    }

    // MARK: - URLs
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if Auth.auth().canHandle(url) {
            return true
        }
        print("WARNING: Url: \(url) should be handled")
        // TODO: check this when backend will be ready
        return true
    }
}

