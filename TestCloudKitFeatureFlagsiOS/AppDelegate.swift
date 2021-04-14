//
//  AppDelegate.swift
//  TestCloudKitFeatureFlagsiOS
//
//  Created by Robin Malhotra on 14/04/2021.
//

import UIKit
import CloudKitFeatureFlags
import CloudKit
import Combine

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    //Sub in your own container ID for testing
    let container = CKContainer(identifier: "iCloud.com.rmalhotra.CloudKitTrial")
    lazy var featureFlags = CloudKitFeatureFlagsRepository(container: container)
    var cancellables = Set<AnyCancellable>()
    
    let predicate = NSPredicate(value: true)
    lazy var subscription = CKQuerySubscription(recordType: "FeatureFlag", predicate: predicate, options: [.firesOnRecordUpdate])

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldBadge = false;
        notificationInfo.shouldSendContentAvailable = true;
        subscription.notificationInfo = notificationInfo
        container.publicCloudDatabase.save(subscription) { (subscription, error) in
            print(error)
            print(subscription)
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (registered, error) in
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.container.publicCloudDatabase.fetch(withRecordID: CKRecord.ID.init(recordName: "testFeatureFlag1"), completionHandler: { [self]
//                record, error in
//                
//                //Updating a record here
//                record?.setValue(0.2, forKey: "rollout")
//                container.publicCloudDatabase.save(record!) { (record, error) in
//                    print(record)
//                }
//            })
//        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        let notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo)
        print(notification)
    }


    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

