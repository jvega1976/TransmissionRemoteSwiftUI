//
//  iOS_1App.swift
//  iOS_1
//
//  Created by Johnny Vega Sosa on 6/27/20.
//

import SwiftUI


@main
struct TransmissionRemote_App: App {
    
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    
    var appState: AppState = AppState.current
    var connector: RPCConnector
    var alertManager: AlertManager = AlertManager()
    
    init() {
        
        if let serverConfig = ServerConfigDB.shared.defaultConfig {
            self.connector = RPCConnector(serverConfig: serverConfig)
            self.connector.connectSession()
        } else {
            self.connector = RPCConnector()
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.criticalAlert,.sound,.badge,.provisional, .providesAppNotificationSettings], completionHandler: { granted, error in
            if !granted {
                print("NotificatioCenter authorization not granted")
            }
            if error != nil {
                print("%@",error!.localizedDescription)
            }
            // Enable or disable features based on authorization.
        })
        delegate.connector = connector
        delegate.appState = appState
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    }
    
    var body: some Scene {
        WindowGroup {
            SplitView()
                .environmentObject(self.connector)
                .environmentObject(self.appState)
                .environmentObject(self.connector.categorization)
                .environmentObject(self.alertManager)
        }
    }
}
