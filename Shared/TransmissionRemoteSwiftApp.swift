//
//  TransmissionRemoteSwiftApp.swift
//  Shared
//
//  Created by Johnny Vega Sosa on 6/24/20.
//

import SwiftUI
import TransmissionRPC

@main
struct TransmissionRemoteSwiftApp: App {
    @StateObject var appState: AppState = AppState.current
    var connector: RPCConnector
    
    init() {
        
        if let serverConfig = ServerConfigDB.shared.defaultConfig {
            self.connector = RPCConnector(serverConfig: serverConfig)
            self.connector.connectSession()
        } else {
            self.connector = RPCConnector()
        }
        
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
        UIApplication.shared.applicationIconBadgeNumber = 0
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged(_:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
        // get changes that might have happened while this
        // instance of your app wasn't running
        NSUbiquitousKeyValueStore.default.synchronize()
        
        return true
    }
    
    var body: some Scene {
        WindowGroup("Transmission Remote") {
            SplitView()
                .environmentObject(self.connector)
                .environmentObject(self.appState)
                .environmentObject(self.connector.categorization)
        }
    }

}


