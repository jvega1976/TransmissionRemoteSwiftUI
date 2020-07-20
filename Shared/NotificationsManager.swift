//
//  Notifications.swift
//  iOS_1
//
//  Created by Johnny Vega Sosa on 6/28/20.
//

import Foundation
import UserNotifications

class NotificationsManager: NSObject, UNUserNotificationCenterDelegate {

    static let main: NotificationsManager = NotificationsManager()
    
func enableNotifications() {
    
    
    
    let defaults = UserDefaults(suiteName: TR_URL_DEFAULTS)!
    let center = UNUserNotificationCenter.current()
    
        let dbConfig = [RPCServerConfig()]
        let data = try! PropertyListEncoder().encode(dbConfig)
        var appDefaults: [String: Any] = [TR_URL_CONFIG_KEY : data]
        appDefaults[TR_URL_ACTUAL_KEY] =  -1
        appDefaults[TR_URL_CONFIG_REQUEST] = 10
        appDefaults[TR_URL_CONFIG_REFRESH] = 5
        appDefaults["videoApplication"] = "none"
        appDefaults["DirectoryMapping"] = [Any]()
        appDefaults["SpeedMenuItems"] = [["rate": 50], ["rate": 100], ["rate": 250],["rate": 500],["rate": 1024]]
        appDefaults[USERDEFAULTS_KEY_WEBDAV] = "https://jvega:Nmjcup0112*@diskstation.johnnyvega.net:5006/others/Downloaded"
        defaults.register(defaults: appDefaults)
        defaults.synchronize()
        center.requestAuthorization(options: [.alert,.criticalAlert,.sound,.badge,.provisional, .providesAppNotificationSettings], completionHandler: { granted, error in
            if !granted {
                print("NotificatioCenter authorization not granted")
            }
            if error != nil {
                print("%@",error!.localizedDescription)
            }
            // Enable or disable features based on authorization.
        })
        center.delegate = self
        center.removeAllDeliveredNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged(_:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
        // get changes that might have happened while this
        // instance of your app wasn't running
        NSUbiquitousKeyValueStore.default.synchronize()

}
    
   @objc  func storeChanged(_ notification: Notification?) {
        
        let userInfo = notification?.userInfo
        let reason = userInfo?[NSUbiquitousKeyValueStoreChangeReasonKey] as? NSNumber
        
        if reason != nil {
            let reasonValue = reason?.intValue ?? 0
            print("%@",String(format: "storeChanged with reason %ld", reasonValue))
            
            if (reasonValue == NSUbiquitousKeyValueStoreServerChange) || (reasonValue == NSUbiquitousKeyValueStoreInitialSyncChange) {
                
                let keys = userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [Any]
                let store = NSUbiquitousKeyValueStore.default
                let userDefaults = UserDefaults(suiteName: TR_URL_DEFAULTS)
                
                for key in keys ?? [] {
                    guard let key = key as? String else {
                        continue
                    }
                    let value = store.object(forKey: key)
                    userDefaults?.set(value, forKey: key)
                    print("storeChanged updated value for %@",key)
                    userDefaults?.synchronize()
                }
            }
        }
    }
}
