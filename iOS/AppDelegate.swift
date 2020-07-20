//
//  AppDelegate.swift
//  Transmission Remote SwiftUI
//
//  Created by  on 1/20/20.
//

import UIKit
import SwiftUI
import BackgroundTasks
import UserNotifications
import TransmissionRPC
import os


class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let defaults = UserDefaults(suiteName: TR_URL_DEFAULTS)!
    var connector: RPCConnector!
    var bgSession: RPCSession?
    var appState: AppState!
    var bgNotifyTime: Date = Date(timeIntervalSince1970: 0)
    var torrents = [Torrent]()
    
    var  isDownloading: Bool {
        return self.connector.categorization.items.contains(where: { [TorrentStatus.download,TorrentStatus.downloadWait].contains( $0.status) && $0.activityDate ?? Date(timeIntervalSince1970: 0) > self.bgNotifyTime - 10 })
    }
    
    var haveActivity: Bool {
        return self.connector.categorization.items.contains(where: {$0.activityDate ?? Date(timeIntervalSince1970: 0) > self.connector.lastUpdate - 180 })
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
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
        
        UNUserNotificationCenter.current().delegate = self.connector
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged(_:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
        // get changes that might have happened while this
        // instance of your app wasn't running
        NSUbiquitousKeyValueStore.default.synchronize()
                
        let bgTaskRefresh = BGTaskScheduler.shared.register(forTaskWithIdentifier: "johnnyvega.TransmissionRemoteSwiftUI.Notify", using: nil, launchHandler: { task in
            DispatchQueue.global(qos: .userInitiated).async{
                self.connector.handleAppNotify(bgTask: task as! BGAppRefreshTask)
            }
        })
        if bgTaskRefresh {
            os_log("TransmissionRemoteSwiftUI: Background Task Refresh registered")
        }
        let bgTaskProcessing = BGTaskScheduler.shared.register(forTaskWithIdentifier: "johnnyvega.TransmissionRemoteSwiftUI.UpdateData", using: nil, launchHandler: { task in
            self.connector.handleUpdateData(bgTask: task as! BGProcessingTask)
        })
        if bgTaskProcessing {
            os_log("TransmissionRemoteSwiftUI: Background Task Processing registered")
        }
        return true
    }
    
    
    @objc func storeChanged(_ notification: Notification?) {
        
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
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if self.connector.session != nil {
            self.connector.scheduleAppRefresh(.notify)
            self.connector.scheduleAppRefresh(.updateData)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {

        if self.bgSession == nil {
            guard let session = try? RPCSession(withURL: self.connector.serverConfig!.configURL!, andTimeout: self.connector.serverConfig!.requestTimeout) else { return }
            self.bgSession = session
        } else {
            try? self.bgSession?.restart()
        }
    }
    

}
