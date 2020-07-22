//
//  Torrents.swift
//  Transmission Remote SwiftUI
//
//  Created by  on 1/20/20.
//

import Foundation
import TransmissionRPC
import Combine
import SwiftUI
import UserNotifications
import BackgroundTasks
import os

let MAXACROSS:Double = 40

enum BgTaskType {
    case notify
    case updateData
}

@objcMembers  class RPCConnector : NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    static private (set) var shared: RPCConnector = RPCConnector()
    
    @ObservedObject var message: Message = Message()
    
    @Published var serverConfig: RPCServerConfig?  {
        didSet {
            if self.session != nil {
                self.stopRefresh()
            }
            if self.serverConfig == nil {
                self.session = nil
            } else {
                try? self.session = RPCSession(withURL: self.serverConfig!.configURL!, andTimeout: self.serverConfig!.requestTimeout)
            }
            self.firstTime = true
        }
    }
    
    @Published var session: RPCSession?
    
    @Published var categorization: TorrentCategorization = TorrentCategorization() {
        didSet {
            if self.refreshTimer.isValid {
                self.refreshTimer.invalidate()
            }
            self.stopRefresh()
            self.firstTime  = true
        }
    }
    @Published var sessionConfig: SessionConfig
    @Published var sessionStats: SessionStats
    @Published var torrent: Torrent {
        didSet {
            self.getPeers()
            self.peers = []
            self.peerStat = PeerStat()
        }
    }
    @Published var selectedTorrents: Set<TrId> = Set<TrId>()
    @Published var selectedFiles: Set<String> = Set<String>()
    
    @Published var peers: [Peer] = []
    @Published var peerStat: PeerStat = PeerStat()
    @Published var fsDir = FSDirectory()
    @Published var torrentFile: TorrentFile? {
        didSet {
            self.fsDir = torrentFile?.fileList ?? FSDirectory()
            for item in self.fsDir.rootItem.items ?? [] {
                item.parent = nil
            }
        }
    }

    @Published var freeSpace: String = "..."
    
    @Published var editMode: EditMode = .inactive
    @Published var fileEditMode: EditMode = .inactive
    
    public var firstTime: Bool = true
    public var restart: Bool = false
    private var refreshTimer: Timer = Timer()
    private var peersRefreshTimer: Timer = Timer()
    
    public var lastUpdate: Date = Date(timeIntervalSince1970: 0)
    private var bgNotifyTime: Date = Date(timeIntervalSince1970: 0)
    
    var  isDownloading: Bool {
        return self.categorization.items.contains(where: { [TorrentStatus.download,TorrentStatus.downloadWait].contains( $0.status) && $0.activityDate ?? Date(timeIntervalSince1970: 0) > self.bgNotifyTime - 10 })
    }
    var haveActivity: Bool {
        return self.categorization.items.contains(where: {$0.activityDate ?? Date(timeIntervalSince1970: 0) > self.lastUpdate - 180 })
    }
    
    
    override init() {
        self.sessionStats = SessionStats()
        self.sessionConfig = SessionConfig()
        self.torrent = Torrent()
        super.init()
        
    }


    convenience init (serverConfig: RPCServerConfig) {
        self.init()
        self.serverConfig = serverConfig
    }
    
    
    deinit {
        if refreshTimer.isValid {
            refreshTimer.invalidate()
        }
        self.session?.stopRequests()
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner,.sound])
        center.removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    
    @objc func connectSession(serverConfig: RPCServerConfig) {
       
        self.serverConfig = serverConfig
        self.firstTime = true
        self.startRefresh()
        //registerBgTasks()
    }
    
    func connectSession() {
        if self.session == nil && self.serverConfig != nil {
            do {
                self.session = try RPCSession(withURL: serverConfig!.configURL!, andTimeout: serverConfig!.requestTimeout)
            } catch {
                self.message.type = .error
                self.message.message = error.localizedDescription
            }
        } 
        self.firstTime = true
        self.startRefresh()
    }
    
    func disconnectSesssion() {
        if refreshTimer.isValid {
            refreshTimer.invalidate()
        }
        self.session?.stopRequests()
    }
    
    @objc func reconnectSession() {
        try? self.session?.restart()
        self.startRefresh()
    }
    
    func startRefresh() {
        self.refreshData()
        self.refreshTimer = Timer.scheduledTimer(withTimeInterval: serverConfig!.refreshTimeout, repeats: true) {_ in
            self.refreshData()
        }
    }
    
    func stopRefresh() {
        if refreshTimer.isValid {
            refreshTimer.invalidate()
        }
        self.session?.stopRequests()
    }
    
    func startPeersRefresh() {
        peersRefreshTimer = Timer.scheduledTimer(withTimeInterval: self.serverConfig?.refreshTimeout ?? 0, repeats: true, block: { _ in
            self.getPeers()
        })
    }
    
    func stopPeersRefresh() {
        if self.peersRefreshTimer.isValid {
            self.peersRefreshTimer.invalidate()
        }
    }
    
    func refreshData() {
        if self.firstTime {
            session?.getInfo(forTorrents: nil, withPriority: .veryHigh, andCompletionHandler: { torrents, removed, error in
                DispatchQueue.main.async {
                    if error != nil {
                        self.message.type = .error
                        self.message.message = error!.localizedDescription
                        self.firstTime = true
                    }
                    else {
                        self.categorization.setItems(torrents!)
                        if let torrent = self.categorization.itemsForSelectedCategory.first {
                            self.torrent = torrent
                        }
                        let trIds = self.categorization.items.map({$0.trId})
                        self.session?.getAllFiles(forTorrent: trIds, completionHandler: { fsDirs, error in
                            if error == nil {
                                fsDirs.forEach { fsDir in
                                    if let torrent = self.categorization.items.first(where: { $0.trId == fsDir.id }) {
                                        DispatchQueue.main.async {
                                            torrent.files = fsDir
                                        }
                                    }
                                }
                            }
                        })
                        self.firstTime = false
                    }
                }
            })
            self.session?.getSessionConfig(andCompletionHandler: {sessionConfig, error in
                DispatchQueue.main.async {
                    if error != nil {
                        self.getSessionConfig()
                    } else {
                        self.sessionConfig.update(with: sessionConfig!)
                    }
                }
            })
        } else {
            if !self.editMode.isEditing  {
                session?.getInfo(forTorrents: RecentlyActive, andCompletionHandler: { torrents, removed, error in
                    DispatchQueue.main.async {
                        if error != nil {
                            self.message.type = .error
                            self.message.message = error!.localizedDescription
                        }
                        else {
                            if !(removed!.isEmpty) {
                                self.categorization.removeItems(where: {removed!.contains($0.trId)})
                            }
                            if !(torrents!.isEmpty) {
                                if !self.categorization.items.isEmpty {
                                    let completedTorrents = torrents!.filter({$0.isSeeding || $0.isFinished})
                                    for torrent in completedTorrents {
                                        if self.categorization.items.contains(where: {$0.trId == torrent.trId && $0.isDownloading }) {
                                            let content = UNMutableNotificationContent()
                                            content.title = String.localizedStringWithFormat("Torrent Finisheh")
                                            content.body = String.localizedStringWithFormat("\"%@\" have been downloaded.", torrent.name)
                                            content.sound = UNNotificationSound.default
                                            content.userInfo = ["trId": torrent.trId]
                                            
                                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                                            let request = UNNotificationRequest(identifier: "Now", content: content, trigger: trigger)
                                            let center = UNUserNotificationCenter.current()
                                            DispatchQueue.main.async(execute: {
                                                center.add(request, withCompletionHandler: { error in
                                                    if error != nil {
                                                        os_log("Notification for torrent: %@ failed with Error: %@",torrent.name!,error!.localizedDescription)
                                                    }
                                                })
                                            })
                                        }
                                        
                                    }
                                }
                                let newTorrents = Set(torrents!).subtracting(self.categorization.items).map{ $0.trId }
                                self.categorization.updateItems(with: torrents!)
                                self.getFiles(trId: newTorrents)
                            }
                        }
                    }
                })
                
                
                self.session?.getSessionStats(andCompletionHandler: {sessionStats, error in
                    DispatchQueue.main.async {
                        if error != nil {
                            self.message.type = .error
                            self.message.message = error!.localizedDescription
                        } else {
                            self.sessionStats.update(with:sessionStats!)
                        }
                    }
                })
                
                self.session?.getFreeSpace(availableIn: self.sessionConfig.downloadDir, andCompletionHandler: { space, error in
                    if error == nil {
                        guard let freeSpace = space else { return }
                        DispatchQueue.main.async {
                            self.freeSpace = ByteCountFormatter.formatByteCount(freeSpace)
                        }                        
                    }
                })
            }
        }
    }
    
    
    
    func getInfo(for trId: [TrId]? = nil) {
        let trId = trId ?? [self.torrent.trId]
        session?.getInfo(forTorrents: trId, withPriority: .veryHigh, andCompletionHandler: { torrents, _, error in
            if error == nil {
                DispatchQueue.main.async {
                    guard let torrents = torrents else { return }
                    let newTorrents = Array(Set(torrents).subtracting(self.categorization.items))
                    if !newTorrents.isEmpty {
                        self.categorization.updateItems(with: newTorrents)
                        self.getFiles(trId: newTorrents.map({$0.trId}))
                    }
                }
            }
        })
    }
    
    func startTorrent(trId: [TrId]? = nil) {
        session?.start(torrents: trId, withPriority: .veryHigh, completionHandler: { error in
            
            if error != nil {
                DispatchQueue.main.async {
                    self.message.type = .error
                    self.message.message = error!.localizedDescription
                }
            } else  {
                DispatchQueue.main.async {
                    self.message.type = .info
                    if trId?.count == 1,
                        let name = self.categorization.items.first(where: {$0.trId == trId?.first })?.name {
                        self.message.message = "Torrent \"\(name)\" sucessfully started"
                    } else {
                        self.message.message = "\(trId?.count ?? 0) Torrent\(trId?.count ?? 0 > 1 ? "s" : "") started sucessfully"
                    }
                }
                self.getInfo(for: trId)
            }
        })
    }
    
    
    func startNowTorrent(trId: [TrId]?) {
        
        session?.startNow(torrents: trId, withPriority: .veryHigh, completionHandler: { error in
            DispatchQueue.main.async {
                if error != nil {
                    self.message.type = .error
                    self.message.message = error!.localizedDescription
                } else  {
                    self.message.type = .info
                    self.message.message = "Torrent started sucessfully"
                        self.getInfo(for: trId)
                }
            }
            
        })
    }
    
    
    func stopTorrent(trId: [TrId]? = nil) {
        
        self.session?.stop(torrents: trId, withPriority: .veryHigh, completionHandler: { error in
            
            if error != nil {
                DispatchQueue.main.async {
                    self.message.type = .error
                    self.message.message = error!.localizedDescription
                }
            } else  {
                DispatchQueue.main.async {
                    self.message.type = .info
                    if trId?.count == 1,
                        let name = self.categorization.items.first(where: {$0.trId == trId?.first })?.name {
                        self.message.message = "Torrent \"\(name)\" sucessfully stopped"
                    } else {
                        self.message.message = "\(trId?.count ?? 0) Torrent\(trId?.count ?? 0 > 1 ? "s" : "") sucessfully stopped"
                    }
                }
                self.getInfo(for: trId)
            }
        })
    }
    
    func verifyTorrent(trId: [TrId]) {
        
        self.session?.verify(torrents: trId, withPriority: .veryHigh, completionHandler: { error in
            DispatchQueue.main.async {
                if error != nil {
                    self.message.type = .error
                    self.message.message = error!.localizedDescription
                } else  {
                    self.message.type = .info
                    self.message.message = "Torrent verification started sucessfully"
                    self.getInfo(for: trId)
                }
            }
        })
    }
    
    func reannounceTorrent(trId: [TrId]) {
        self.session?.reannounce(torrents: trId, withPriority: .veryHigh, completionHandler: { error in
            DispatchQueue.main.async {
                if error != nil {
                    self.message.type = .error
                    self.message.message = error!.localizedDescription
                } else  {
                    self.message.type = .info
                    self.message.message = "Torrent reannounced sucessfully"
                    self.getInfo(for: trId)
                }
            }
        })
    }
    
    func removeTorrent(trId: [TrId]) {
        
        self.session?.remove(torrents: trId, deletingLocalData: false, withPriority: .veryHigh, completionHandler: { error in
            DispatchQueue.main.async {
                if error != nil {
                    self.message.type = .error
                    self.message.message = error!.localizedDescription
                    
                } else  {
                    self.message.type = .info
                    self.message.message = "Torrent removed sucessfully"
                    if trId.contains(self.torrent.trId) {
                        self.torrent = self.categorization.itemsForSelectedCategory.first ?? (self.categorization.items.first ?? Torrent())
                    }
                    self.refreshData()
                }
            }
        })
    }
    
    func removeWithDataTorrent(trId: [TrId]) {
        self.session?.remove(torrents: trId, deletingLocalData: true, withPriority: .veryHigh, completionHandler: { error in
            DispatchQueue.main.async {
                if error != nil {
                    self.message.type = .error
                    self.message.message = error!.localizedDescription
                } else  {
                    self.message.type = .info
                    self.message.message = "Torrent removed sucessfully"
                    if trId.contains(self.torrent.trId) {
                        self.torrent = self.categorization.itemsForSelectedCategory.first ?? (self.categorization.items.first ?? Torrent())
                    }
                    self.refreshData()
                }
            }
        })
    }
    
    
    func setLocation(trId: [TrId], location: String, move: Bool) {
        self.session?.setLocation(forTorrent: trId, location: location, move: move, withPriority: .veryHigh, completionHandler: { error in
            DispatchQueue.main.async {
                if error != nil {
                    self.message.type = .error
                    self.message.message = error!.localizedDescription
                    
                }  else  {
                    self.message.type = .info
                    self.message.message = "Location changed sucessfully"
                    self.getInfo(for: trId)
                }
            }
        })
    }
    
    func getFiles(trId: [TrId]? = nil) //->FSDirectory
    {
        let trId = trId ?? [self.torrent.trId]
        self.session?.getAllFiles(forTorrent: trId, completionHandler: { fsDirs, error in
            DispatchQueue.main.async(qos: .userInteractive) {
                if error == nil {
                    for fsDir in fsDirs {
                        if let torrent = self.categorization.items.first(where: { $0.trId == fsDir.id }) {
                            torrent.files = fsDir
                        }
                    }
                } else {
                    self.message.type = .error
                    self.message.message = error!.localizedDescription
                }
            }
        })
        
    }
    
    func getFileStats(trId: [TrId]? = nil) //->FSDirectory
    {
        let trId = trId ?? [self.torrent.trId]
        self.session?.getAllFileStats(forTorrent: trId, withPriority: .veryHigh, completionHandler: { fileStats, error in
            DispatchQueue.main.async(qos: .userInitiated) {
                if error != nil {
                    self.message.type = .error
                    self.message.message = error!.localizedDescription
                } else {
                    for fileStat in fileStats {
                        self.categorization.items.first(where: { $0.trId == fileStat.trId })?.files.updateFSDir(usingStats: fileStat.fileStats)
                    }
                }
            }
        })
    }
    
    
    public func setFields(_ fields: JSONObject, forTorrents trIds: [TrId]) {
        self.session?.setFields(fields, forTorrents: trIds, withPriority: .veryHigh) { error in
            DispatchQueue.main.async(qos: .userInitiated) {
                let otherFields = [JSONKeys.trackerAdd,JSONKeys.trackerRemove,JSONKeys.files_wanted, JSONKeys.files_unwanted, JSONKeys.priority_low, JSONKeys.priority_normal, JSONKeys.priority_high]
                if error != nil {
                    self.message.type = .error
                    self.message.message = error!.localizedDescription
                } else {
                    if fields.keys.contains(where: { $0 == JSONKeys.files_wanted || $0 == JSONKeys.files_unwanted || $0 == JSONKeys.priority_low || $0 == JSONKeys.priority_normal || $0 == JSONKeys.priority_high }) {
                        self.getFileStats(trId: trIds)
                    } else {
                        if !(fields.keys.contains(where: {otherFields.contains($0)})) {
                            self.getInfo(for: trIds)
                        }
                    }
                }
            }
        }
    }
    

    func addTorrent(withBandwithPriority bandPriority: Int? = 0, addPaused paused: Bool) {
        self.session?.addTorrent(usingFile: self.torrentFile!, andBandwithPriority: bandPriority, addPaused: paused,  withPriority: .veryHigh, completionHandler: { trId, error in
            DispatchQueue.main.async {
                if error != nil {
                    self.message.type = .error
                    self.message.message = error!.localizedDescription
                } else {
                    self.message.type = .info
                    self.message.message = "Torrent \(self.torrentFile?.name ?? "") suscessfully added"
                }
            }
        })
    }
    
    
    func renameFile(_ filename: String,forFSItem item: FSItem, usingName name: String) {
        let trId = self.torrent.trId
        self.session?.renameFile(filename, forTorrent: trId, usingName: name, withPriority: .veryHigh, completionHandler: { error in
            DispatchQueue.main.async {
                if error != nil {
                    item.name = name
                    self.message.type = .error
                    self.message.message = error!.localizedDescription
                } else {
                    self.getFiles(trId: [trId])
                    self.getInfo(for: [trId])
                }
            }
        })
    }
    
    public func getPeers() {
        self.session?.getPeers(forTorrent: self.torrent.trId) { (peers, peerStat, error) in
            if error != nil {
                DispatchQueue.main.async(qos: .userInitiated) {
                    self.message.type = .error
                    self.message.message = error!.localizedDescription
                }
            } else {
                
                let ipConnector = GeoIpConnector()
                peers!.forEach  { peer in
                    ipConnector.getInfoForIp(peer.ipAddress, responseHandler: { (error, dict) in
                        if error == nil {
                            if dict != nil && (dict!["status"] as! String) == "success" {
                                DispatchQueue.main.async {
                                    peer.countryName = dict!["country"] as? String == nil ? "-" : dict!["country"] as! String
                                    peer.countryCode = dict!["countryCode"] as? String == nil ? "-" : dict!["countryCode"] as! String
                                    if let index1 = self.peers.firstIndex(of: peer) {
                                        self.peers[index1] = peer
                                    } else {
                                        self.peers.append(peer)
                                    }
                                }
                            }
                        } else {
                            print(error ?? "")
                        }
                    })
                }
                DispatchQueue.main.async {
                    self.peers.removeAll(where: { !(peers!.contains($0)) })
                    self.peerStat = peerStat!
                }
            }
        }
    }
    
    
    
    
    func saveSessionConfig()->Bool {
        
        if self.sessionConfig.downloadDir.count < 1 {
            self.message.type = .error
            self.message.message = NSLocalizedString("You shoud set download directory", comment: "")
            return false
        }
        
        
        if sessionConfig.speedLimitDown <= 0 || sessionConfig.speedLimitDown >= 1000000 {
            self.message.type = .error
            self.message.message =  NSLocalizedString("Wrong download rate limit", comment: "")
            return false
        }
        
        if self.sessionConfig.incompletedDirEnabled && self.sessionConfig.incompletedDir.count < 1 {
            self.message.type = .error
            self.message.message =  NSLocalizedString("You shoud set incompleted directory", comment: "")
            return false
        }
        
        if sessionConfig.speedLimitUp <= 0 || sessionConfig.speedLimitDown >= 1000000 {
            self.message.type = .error
            self.message.message =  NSLocalizedString("Wrong upload rate limit", comment: "")
            return false
        }
        
        if sessionConfig.altSpeedDown <= 0 || sessionConfig.altSpeedDown >= 1000000 {
            self.message.type = .error
            self.message.message =  NSLocalizedString("Wrong alternative download rate limit", comment: "")
            return false
        }
        
        
        if sessionConfig.altSpeedUp <= 0 || sessionConfig.altSpeedUp >= 1000000 {
            self.message.type = .error
            self.message.message =  NSLocalizedString("Wrong alternative upload rate limit", comment: "")
            return false
        }
        
        
        if sessionConfig.seedRatioLimit <= 0 {
            self.message.type = .error
            self.message.message =  NSLocalizedString("Wrong seed ratio limit factor", comment: "")
            return false
        }
        
        
        if sessionConfig.idleSeedingLimit <= 0 {
            self.message.type = .error
            self.message.message =  NSLocalizedString("Wrong seed idle timeout number", comment: "")
            return false
        }
        
        
        if sessionConfig.peerLimitGlobal <= 0 {
            self.message.type = .error
            self.message.message =  NSLocalizedString("Wrong total peers count", comment: "")
            return false
        }
        
        
        if sessionConfig.peerLimitPerTorrent > sessionConfig.peerLimitGlobal {
            self.message.type = .error
            self.message.message = NSLocalizedString("Wrong peers per torrent count", comment: "")
            return false
        }
        
        
        if sessionConfig.peerPort <= 0 || sessionConfig.peerPort > 65535 {
            self.message.type = .error
            self.message.message = NSLocalizedString("Wrong port number", comment: "")
            return false
        }
        
        self.session?.setSessionConfig(usingConfig: self.sessionConfig, andCompletionHandler: { error in
            DispatchQueue.main.async {
                if error != nil {
                    self.message.type = .error
                    self.message.message = error!.localizedDescription
                } else {
                    self.message.type = .info
                    self.message.message = "Session Configuration updated successfully"
                    self.getSessionConfig()
                }
            }
        })
        
        return true
    }
    
    func moveTorrent(_ trId: [TrId], to movement: QueueMovements) {
        self.session?.move(torrents: trId, to: movement, withPriority: .veryHigh) { error in
            if error != nil {
                self.message.type = .error
                self.message.message = error!.localizedDescription
            } else {
                self.getInfo(for: trId)
            }
        }
    }
    
    func getSessionConfig() {
        self.session?.getSessionConfig(andCompletionHandler: {sessionConfig, error in
            DispatchQueue.main.async {
                if error != nil {
                    self.message.type = .error
                    self.message.message = error!.localizedDescription
                } else if let sessionConfig = sessionConfig {
                    self.sessionConfig.update(with: sessionConfig)
                } else {
                    self.message.type = .error
                    self.message.message = "Error obtaining Session Configuration"
                }
            }
        })
    }
    
    func searchFiles(_ searchText: String)->Void {
        var predicate: ((FSItem)->Bool)?
        if searchText.count > 0 {
            let andWords = searchText.split(whereSeparator: { $0 == "&" })
            let orWords = searchText.split(whereSeparator: { $0 == "|" })
            predicate = {element in
                var result = true
                if !andWords.isEmpty {
                    for word in andWords {
                        result = result && element.name.localizedCaseInsensitiveContains(word.trimmingCharacters(in: .whitespaces))
                    }
                }
                if !orWords.isEmpty {
                    for word in orWords {
                        result = result || element.name.localizedCaseInsensitiveContains(word.trimmingCharacters(in: .whitespaces))
                    }
                }
                if orWords.isEmpty && andWords.isEmpty {
                    result = result && element.name.localizedCaseInsensitiveContains(searchText)
                }
                return result
            }
        } else {
            predicate = nil
        }
        self.objectWillChange.send()
        self.torrent.files.filterPredicate = predicate
    }
    
    
    
    func searchTorrents(_ searchText: String)->Void {
        var predicate: TorrentCategory.Predicate
        if searchText.count > 0 {
            let andWords = searchText.split(whereSeparator: { $0 == "&" })
            let orWords = searchText.split(whereSeparator: { $0 == "|" })
            predicate = {element in
                var result = true
                if !andWords.isEmpty {
                    for word in andWords {
                        result = result && element.name.localizedCaseInsensitiveContains(word.trimmingCharacters(in: .whitespaces))
                    }
                }
                if !orWords.isEmpty {
                    for word in orWords {
                        result = result || element.name.localizedCaseInsensitiveContains(word.trimmingCharacters(in: .whitespaces))
                    }
                }
                if orWords.isEmpty && andWords.isEmpty {
                    result = result && element.name.localizedCaseInsensitiveContains(searchText)
                }
                return result
            }
        } else {
            predicate = {element in return true }
        }
        self.categorization.filterPredicate = predicate
        
    }
    
    func scheduleAppRefresh(_ type: BgTaskType) {
        do {
            switch type {
                case .notify:
                    let request = BGAppRefreshTaskRequest(identifier: "johnnyvega.TransmissionRemoteSwiftUI.Notify")
                    if self.isDownloading {
                        request.earliestBeginDate = Date(timeIntervalSinceNow: 180)
                    } else {
                        request.earliestBeginDate = Date(timeIntervalSinceNow: 120) //120*60
                    }
                    try BGTaskScheduler.shared.submit(request)
                    os_log("TransmissionRemoteSwiftUI: Background Task scheduled to start after %{time_t}d",time_t(request.earliestBeginDate!.timeIntervalSince1970))
                case .updateData:
                    let request = BGProcessingTaskRequest(identifier: "johnnyvega.TransmissionRemoteSwiftUI.UpdateData")
                    if self.haveActivity {
                        request.earliestBeginDate = Date(timeIntervalSinceNow: 300)
                    } else {
                        request.earliestBeginDate = Date(timeIntervalSinceNow: 180) //180*60
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
    
    func cancelAppRefresh() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: "johnnyvega.TransmissionRemoteSwiftUI.Notify")
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: "johnnyvega.TransmissionRemoteSwiftUI.UpateData")
    }
    
    func handleAppNotify(bgTask: BGAppRefreshTask) {
        
        self.scheduleAppRefresh(.notify)
        os_log("TransmissionRemoteSwiftUI: Starting Processing of Backgroud Task")
        
        /*do {
            try self.session?.restart()
        } catch {
            return
        }*/
        
        let torrentsDownloading = self.categorization.items.filter({ $0.status == .download || $0.status == .downloadWait }).map({$0.trId})
        if !(torrentsDownloading.isEmpty) {
            let fields = [JSONKeys.id, JSONKeys.name, JSONKeys.status, JSONKeys.activityDate, JSONKeys.percentDone, JSONKeys.startDate, JSONKeys.addedDate]
            var arguments = JSONObject()
            arguments[JSONKeys.fields] = fields
            arguments[JSONKeys.ids] = torrentsDownloading
            
            let request = RPCRequest(forMethod: JSONKeys.torrent_get, withArguments: arguments, usingSession: self.session!, andPriority: .veryHigh, dataCompletion:  { (data, error) in
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
                        DispatchQueue.main.async {
                            self.categorization.items.first(where: {$0.trId == torrent.trId })!.status = torrent.status
                            self.categorization.items.first(where: {$0.trId == torrent.trId })!.activityDate = torrent.activityDate
                        }
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
            self.session?.addTorrentRequest(request)
        } else {
            bgTask.setTaskCompleted(success: true)
        }
    }
    
    func handleUpdateData(bgTask: BGProcessingTask) {
        
        scheduleAppRefresh(.updateData)
        os_log("TransmissionRemoteSwiftUI: Starting Processing of Backgroud Task")
        
        do {
            try self.session?.restart()
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
        
        let request = RPCRequest(forMethod: JSONKeys.torrent_get, withArguments: arguments, usingSession: self.session!, andPriority: .veryHigh, dataCompletion:  { (data, error) in
            
            let lastUpdate = Date(timeIntervalSinceNow: -10)
            var torrents: Array<Torrent>?
            
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
            if let torrentsToUpdate = torrents?.filter({$0.activityDate ?? Date(timeIntervalSince1970: 0) >= self.lastUpdate }),
                !torrentsToUpdate.isEmpty {
                var bagnumber = 0
                DispatchQueue.main.async {
                    bagnumber = UIApplication.shared.applicationIconBadgeNumber
                }
                for torrent in torrentsToUpdate.filter({$0.percentDone >= 1}) {
                    if self.categorization.items.contains(where: {$0.trId == torrent.trId && $0.percentDone < 1 && torrent.percentDone >= 1}) {
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
                self.categorization.setItems(torrentsToUpdate)
            }
            self.lastUpdate = lastUpdate
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
        self.session?.addTorrentRequest(request)
    }
    
    func updateTorrents() {
        let sema = DispatchSemaphore(value: 0)
        var arguments = JSONObject()
        arguments[JSONKeys.fields] =  [JSONKeys.id, JSONKeys.name, JSONKeys.activityDate, JSONKeys.startDate, JSONKeys.addedDate, JSONKeys.percentDone, JSONKeys.status]
        
        var activeIds = Set<TrId>()
        DispatchQueue.global(qos: .userInteractive).async {
            activeIds = Set(self.categorization.items.filter({$0.isDownloading || $0.isSeeding || $0.isWaiting || $0.isChecking }).map({$0.trId}))
        }
        
        let request = RPCRequest(forMethod: JSONKeys.torrent_get, withArguments: arguments, usingSession: self.session!, andPriority: .veryHigh, dataCompletion:  { (data, error) in
            
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
                let updatedIds = Set(torrents.filter({ $0.activityDate ?? Date(timeIntervalSince1970: 0) >= self.lastUpdate - 180 || $0.startDate ?? Date(timeIntervalSince1970: 0) >= self.lastUpdate - 180 || $0.addedDate ?? Date(timeIntervalSince1970: 0) >= self.lastUpdate - 180 }).map({$0.trId}))
                let trIds = Array(updatedIds.union(activeIds))
                if !(trIds.isEmpty) {
                    self.session?.getInfo(forTorrents: trIds, withPriority: .veryHigh, andCompletionHandler: { torrents, _, error in
                        let lastUpdate = Date(timeIntervalSinceNow: -10)
                        if error != nil {
                            os_log("TransmissionRemoteSwiftUI: %@",error!.localizedDescription)
                        }
                        else {
                            guard let torrents = torrents
                                else { sema.signal(); return }
                            DispatchQueue.main.async {
                                self.categorization.updateItems(with: torrents)
                                self.lastUpdate = lastUpdate
                            }
                        }
                        sema.signal()
                    })
                } else {
                    sema.signal()
                }
            }
        })
        self.session?.addTorrentRequest(request)
        sema.wait()
    }
}


