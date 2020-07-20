//
//  SceneDelegate.swift
//  Transmission Remote SwiftUI
//
//  Created by  on 1/20/20.
//

import UIKit
import SwiftUI
import TransmissionRPC
import BackgroundTasks
import os

enum InterfaceappState {
    case portrait
    case landscape
}


class AddTorrentState: ObservableObject {
    @Published var displayView: Bool = false
    @Published var connector = RPCConnector()
}

enum BgTaskType {
    case notify
    case updateData
}


class SceneDelegate: UIResponder, UIWindowSceneDelegate, NSUserActivityDelegate {
    
    var window: UIWindow?
    var appState = AppState()
    var connector: RPCConnector!
    let defaults =  UserDefaults.standard
    @ObservedObject var addTorrentState: AddTorrentState = AddTorrentState()
    var bgSession: RPCSession?
    var bgNotifyTime: Date = Date(timeIntervalSince1970: 0)
    var torrents = [Torrent]()
    
    var  isDownloading: Bool {
        return self.connector.categorization.items.contains(where: { [TorrentStatus.download,TorrentStatus.downloadWait].contains( $0.status) && $0.activityDate ?? Date(timeIntervalSince1970: 0) > self.bgNotifyTime - 10 })
    }
    var haveActivity: Bool {
        return self.connector.categorization.items.contains(where: {$0.activityDate ?? Date(timeIntervalSince1970: 0) > self.connector.lastUpdate - 180 })
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        self.appState.isLandscape = (scene as? UIWindowScene)?.interfaceOrientation.isLandscape ?? false
        self.appState.sizeIsCompact = (scene as? UIWindowScene)?.traitCollection.verticalSizeClass == .compact || (scene as? UIWindowScene)?.traitCollection.horizontalSizeClass == .compact
        
        let serverConfig = ServerConfigDB.shared.defaultConfig ?? RPCServerConfig()
        self.connector = RPCConnector(serverConfig: serverConfig)
        let contentView = SplitView(addTorrentState: self.addTorrentState).environmentObject(self.connector).environmentObject(self.appState).environmentObject(self.connector.categorization)
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }

            let bgTaskRefresh = BGTaskScheduler.shared.register(forTaskWithIdentifier: "johnnyvega.TransmissionRemoteSwiftUI.Notify", using: nil, launchHandler: { task in
                self.handleAppNotify(bgTask: task as! BGAppRefreshTask)
            })
            if bgTaskRefresh {
                os_log("TransmissionRemoteSwiftUI: Background Task Refresh registered")
            }
            let bgTaskProcessing = BGTaskScheduler.shared.register(forTaskWithIdentifier: "johnnyvega.TransmissionRemoteSwiftUI.UpdateData", using: nil, launchHandler: { task in
                self.handleUpdateData(bgTask: task as! BGProcessingTask)
            })
            if bgTaskProcessing {
                os_log("TransmissionRemoteSwiftUI: Background Task Processing registered")
            }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        let sema = DispatchSemaphore(value: 0)
        self.torrents = []
        
        if self.bgSession != nil {
            DispatchQueue.global(qos: .userInteractive).async {
                BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: "johnnyvega.TransmissionRemoteSwiftUI.Notify")
                BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: "johnnyvega.TransmissionRemoteSwiftUI.UpateData")
                self.bgSession!.stopRequests()
            }
        }
        if self.connector.lastUpdate > Date(timeIntervalSince1970: 0) {
            if self.connector.session == nil && self.connector.serverConfig != nil {
                guard let session  = try? RPCSession(withURL: self.connector.serverConfig!.configURL!, andTimeout: self.connector.serverConfig!.requestTimeout)
                    else {
                        self.connector.firstTime = true
                        return
                    }
                self.connector.session = session
                self.connector.restart = true
            }
            
            var arguments = JSONObject()
            arguments[JSONKeys.fields] =  [JSONKeys.id, JSONKeys.name, JSONKeys.activityDate, JSONKeys.startDate, JSONKeys.addedDate, JSONKeys.percentDone, JSONKeys.status]
            
            var activeIds = Set<TrId>()
            DispatchQueue.global(qos: .userInteractive).async {
                activeIds = Set(self.connector.categorization.items.filter({$0.isDownloading || $0.isSeeding || $0.isWaiting || $0.isChecking }).map({$0.trId}))
            }
            
            let request = RPCRequest(forMethod: JSONKeys.torrent_get, withArguments: arguments, usingSession: self.connector.session!, andPriority: .veryHigh, dataCompletion:  { (data, error) in
                
                if error != nil {
                    os_log("TransmissionRemoteSwiftUI: %@",error!.localizedDescription)
                    sema.signal()
                    return
                } else {
                    var torrents = [TorrentActive]()
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .secondsSince1970
                        let response = try decoder.decode(JSONTorrentsActive.self, from: data!)
                        torrents = response.arguments.torrents
                    } catch {
                        sema.signal()
                        return
                    }
                    let updatedIds = Set(torrents.filter({ $0.activityDate ?? Date(timeIntervalSince1970: 0) >= self.connector.lastUpdate - 180 || $0.startDate ?? Date(timeIntervalSince1970: 0) >= self.connector.lastUpdate - 180 || $0.addedDate ?? Date(timeIntervalSince1970: 0) >= self.connector.lastUpdate - 180 }).map({$0.trId}))
                    let trIds = Array(updatedIds.union(activeIds))
                    if !(trIds.isEmpty) {
                        self.connector.session?.getInfo(forTorrents: trIds, withPriority: .veryHigh, andCompletionHandler: { torrents, _, error in
                            let lastUpdate = Date(timeIntervalSinceNow: -10)
                            if error != nil {
                                os_log("TransmissionRemoteSwiftUI: %@",error!.localizedDescription)
                            }
                            else {
                                self.torrents = torrents ?? []
                                self.connector.lastUpdate = lastUpdate
                            }
                            sema.signal()
                        })
                    } else {
                        sema.signal()
                    }
                }
            })
            self.connector.session?.addTorrentRequest(request)
            sema.wait()
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
                
        if !(self.torrents.isEmpty) {
            DispatchQueue.main.async {
                self.connector.categorization.updateItems(with: self.torrents)
            }
        }
        self.connector.session?.getSessionConfig(andCompletionHandler: {sessionConfig, error in
            if error != nil {
                os_log("%@",error!.localizedDescription)
            } else if let sessionConfig = sessionConfig {
                DispatchQueue.main.async {
                    self.connector.sessionConfig.update(with: sessionConfig)
                }
            }
        })
        if self.connector.restart {
            self.connector.reconnectSession()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        self.connector.disconnectSesssion()
        if self.bgSession == nil {
            guard let session = try? RPCSession(withURL: self.connector.serverConfig!.configURL!, andTimeout: self.connector.serverConfig!.requestTimeout) else { return }
            self.bgSession = session
        } else {
            try? self.bgSession?.restart()
        }
       
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        if self.bgSession != nil {
            self.scheduleAppRefresh(.notify)
            self.scheduleAppRefresh(.updateData)
        }
    }

    func windowScene(_ windowScene: UIWindowScene, didUpdate previousCoordinateSpace: UICoordinateSpace, interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation, traitCollection previousTraitCollection: UITraitCollection) {
        
        self.appState.sizeIsCompact = windowScene.traitCollection.verticalSizeClass == .compact || windowScene.traitCollection.horizontalSizeClass == .compact
        
        self.appState.isLandscape = windowScene.interfaceOrientation.isLandscape || UIDevice.current.systemName == "Mac OS X"
        
    }
    
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        var torrentFile: TorrentFile? = nil
        var magnetURL: MagnetURL? = nil
        
        
        for urlContext in URLContexts {
           let url = urlContext.url
            if MagnetURL.isMagnetURL(url) {
                magnetURL = MagnetURL(url: url)
            } else {
                if url.startAccessingSecurityScopedResource() {
                    torrentFile = TorrentFile(fileURL: url)
                    url.stopAccessingSecurityScopedResource()
                }
            }

            let connector = RPCConnector()
            connector.message = self.connector.message
            connector.torrentFile = torrentFile
            connector.fsDir = torrentFile?.fileList ?? FSDirectory()
            for item in connector.fsDir.rootItem.items ?? [] {
                item.parent = nil
            }
            self.addTorrentState.connector = connector
            if ServerConfigDB.shared.db.count > 0 && ((torrentFile != nil) || magnetURL != nil) {
                DispatchQueue.main.async {
                    self.addTorrentState.displayView = true
                }
            }
        }

    }
    
    
    func scheduleAppRefresh(_ type: BgTaskType) {
        do {
            switch type {
                case .notify:
                    let request = BGAppRefreshTaskRequest(identifier: "johnnyvega.TransmissionRemoteSwiftUI.Notify")
                    if self.isDownloading {
                        request.earliestBeginDate = Date(timeIntervalSinceNow: 60)
                    } else {
                        request.earliestBeginDate = Date(timeIntervalSinceNow: 120*60)
                    }
                    try BGTaskScheduler.shared.submit(request)
                    os_log("TransmissionRemoteSwiftUI: Background Task scheduled to start after %{time_t}d",time_t(request.earliestBeginDate!.timeIntervalSince1970))
                case .updateData:
                    let request = BGProcessingTaskRequest(identifier: "johnnyvega.TransmissionRemoteSwiftUI.UpdateData")
                    if self.haveActivity {
                        request.earliestBeginDate = Date(timeIntervalSinceNow: 180)
                    } else {
                        request.earliestBeginDate = Date(timeIntervalSinceNow: 180*60)
                    }
                    try BGTaskScheduler.shared.submit(request)
                    os_log("TransmissionRemoteSwiftUI: Background Task scheduled to start after %{time_t}d",time_t(request.earliestBeginDate!.timeIntervalSince1970))
            }
        } catch {
            guard let myError = error as? BGTaskScheduler.Error else {
                os_log("TransmissionRemoteSwiftUI: Could not schedule app refresh: %@",error.localizedDescription)
                return
            }
            switch myError.code {
                case .notPermitted:
                    os_log("TransmissionRemoteSwiftUI: App is Not permitted to launch Background Tasks")
                case .tooManyPendingTaskRequests:
                    os_log("TransmissionRemoteSwiftUI: Too many pending Tasks of the type requested")
                case .unavailable:
                    os_log("TransmissionRemoteSwiftUI: App can’t schedule background work")
                @unknown default:
                    os_log("TransmissionRemoteSwiftUI: Background Unknown Error")
            }
        }
        
    }
    
    
    func handleAppNotify(bgTask: BGAppRefreshTask) {
        
        self.scheduleAppRefresh(.notify)
        os_log("TransmissionRemoteSwiftUI: Starting Processing of Backgroud Task")
        
        do {
            try self.bgSession?.restart()
        } catch {
            return
        }
        
        let torrentsDownloading = self.connector.categorization.items.filter({ $0.status == .download || $0.status == .downloadWait }).map({$0.trId})
        
        if !(torrentsDownloading.isEmpty) {
            let fields = [JSONKeys.id, JSONKeys.name, JSONKeys.status, JSONKeys.activityDate, JSONKeys.percentDone, JSONKeys.startDate, JSONKeys.addedDate]
            var arguments = JSONObject()
            arguments[JSONKeys.fields] = fields
            arguments[JSONKeys.ids] = torrentsDownloading
            
            let request = RPCRequest(forMethod: JSONKeys.torrent_get, withArguments: arguments, usingSession: self.bgSession!, andPriority: .veryHigh, dataCompletion:  { (data, error) in
                self.bgNotifyTime = Date() - 10
                if error != nil {
                    os_log("TransmissionRemoteSwiftUI: %@",error!.localizedDescription)
                    return
                }
                var torrents: [TorrentActive]
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let response = try decoder.decode(JSONTorrentsActive.self, from: data!)
                    torrents = response.arguments.torrents
                } catch {
                    return
                }
                    var bagnumber = 0
                    DispatchQueue.main.async {
                        bagnumber = UIApplication.shared.applicationIconBadgeNumber
                    }
                    for torrent in torrents {
                        if  torrent.percentDone >= 1 {
                            let content = UNMutableNotificationContent()
                            content.title = String.localizedStringWithFormat("Torrent Finished")
                            content.body = String.localizedStringWithFormat("\"%@\" have been downloaded.", torrent.name)
                            content.sound = UNNotificationSound.default
                            content.userInfo = ["trId": torrent.trId]
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                            bagnumber += 1
                            content.badge = NSNumber(value: bagnumber)
                            let request = UNNotificationRequest(identifier: torrent.name, content: content, trigger: trigger)
                            UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                                if error != nil {
                                    os_log("TransmissionRemoteSwiftUI: Notification for torrent: %@  failed with Error: %@",torrent.name, error!.localizedDescription)
                                }
                            })
                        }
                        self.connector.categorization.items.first(where: {$0.trId == torrent.trId })!.status = torrent.status
                        self.connector.categorization.items.first(where: {$0.trId == torrent.trId })!.activityDate = torrent.activityDate
                    }
            })
            
            bgTask.expirationHandler = {
                // After all operations are cancelled, the completion block below is called to set the task to complete.
                request.cancel()
                os_log("TransmissionRemoteSwiftUI: Backgroud Notification Task was Cancelled")
            }
            
            request.completionBlock = {
                os_log("TransmissionRemoteSwiftUI: Backgroud Notification Task %@ successfully",!request.isCancelled ? "completed" : "did not completed")
                bgTask.setTaskCompleted(success: !request.isCancelled)
            }
            self.bgSession?.addTorrentRequest(request)
        }
    }
    
    func handleUpdateData(bgTask: BGProcessingTask) {
        
        self.scheduleAppRefresh(.updateData)
        os_log("TransmissionRemoteSwiftUI: Starting Processing of Backgroud Task")
        
        do {
            try self.bgSession?.restart()
        } catch {
            return
        }
        
        var arguments = JSONObject()
        arguments[JSONKeys.fields] = [
            JSONKeys.activityDate,
            JSONKeys.editDate,
            JSONKeys.addedDate,
            JSONKeys.bandwidthPriority,
            JSONKeys.comment,
            JSONKeys.creator,
            JSONKeys.dateCreated,
            JSONKeys.doneDate,
            JSONKeys.downloadDir,
            JSONKeys.downloadedEver,
            JSONKeys.downloadLimit,
            JSONKeys.downloadLimited,
            JSONKeys.error,
            JSONKeys.errorString,
            JSONKeys.eta,
            JSONKeys.hashString,
            JSONKeys.haveUnchecked,
            JSONKeys.haveValid,
            JSONKeys.honorsSessionLimits,
            JSONKeys.id,
            JSONKeys.isFinished,
            JSONKeys.name,
            JSONKeys.peer_limit,
            JSONKeys.peersConnected,
            JSONKeys.peersGettingFromUs,
            JSONKeys.peersSendingToUs,
            JSONKeys.percentDone,
            JSONKeys.pieceCount,
            JSONKeys.pieceSize,
            JSONKeys.queuePosition,
            JSONKeys.rateDownload,
            JSONKeys.rateUpload,
            JSONKeys.recheckProgress,
            JSONKeys.secondsDownloading,
            JSONKeys.secondsSeeding,
            JSONKeys.seedIdleLimit,
            JSONKeys.seedIdleMode,
            JSONKeys.seedRatioLimit,
            JSONKeys.seedRatioMode,
            JSONKeys.status,
            JSONKeys.totalSize,
            JSONKeys.uploadedEver,
            JSONKeys.uploadLimit,
            JSONKeys.uploadLimited,
            JSONKeys.uploadRatio
        ]
        
        let request = RPCRequest(forMethod: JSONKeys.torrent_get, withArguments: arguments, usingSession: self.bgSession!, andPriority: .veryHigh, dataCompletion:  { (data, error) in
            
            let lastUpdate = Date(timeIntervalSinceNow: -10)
            var torrents: [Torrent]?
            
            if error != nil {
                os_log("TransmissionRemoteSwiftUI: %@",error!.localizedDescription)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                let response = try decoder.decode(JSONTorrents.self, from: data!)
                torrents = response.arguments.torrents
            } catch {
                return
            }
            if let torrentsToUpdate = torrents?.filter({$0.activityDate ?? Date(timeIntervalSince1970: 0) >= self.connector.lastUpdate }),
                !torrentsToUpdate.isEmpty {
                var bagnumber = 0
                DispatchQueue.main.async {
                    bagnumber = UIApplication.shared.applicationIconBadgeNumber
                }
                for torrent in torrentsToUpdate.filter({$0.percentDone >= 1}) {
                    if self.connector.categorization.items.contains(where: {$0.trId == torrent.trId && $0.percentDone < 1 && torrent.percentDone >= 1}) {
                        let content = UNMutableNotificationContent()
                        content.title = String.localizedStringWithFormat("Torrent Finished")
                        content.body = String.localizedStringWithFormat("\"%@\" have been downloaded.", torrent.name)
                        content.sound = UNNotificationSound.default
                        content.userInfo = ["trId": torrent.trId]
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                        bagnumber += 1
                        content.badge = NSNumber(value: bagnumber)
                        let request = UNNotificationRequest(identifier: torrent.name, content: content, trigger: trigger)
                        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                            if error != nil {
                                os_log("TransmissionRemoteSwiftUI: Notification for torrent: %@  failed with Error: %@",torrent.name, error!.localizedDescription)
                            }
                        })
                    }
                }
                self.connector.categorization.setItems(torrentsToUpdate)
            }
            self.connector.lastUpdate = lastUpdate
        })
        
        bgTask.expirationHandler = {
            // After all operations are cancelled, the completion block below is called to set the task to complete.
            request.cancel()
            os_log("TransmissionRemoteSwiftUI: Backgroud Update Task was Cancelled")
        }
        
        request.completionBlock = {
            os_log("TransmissionRemoteSwiftUI: Backgroud Update Task %@ successfully",!request.isCancelled ? "completed" : "did not completed")
            bgTask.setTaskCompleted(success: !request.isCancelled)
        }
        self.bgSession?.addTorrentRequest(request)
    }
}

