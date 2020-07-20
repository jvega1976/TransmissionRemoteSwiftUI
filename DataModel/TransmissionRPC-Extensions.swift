//
//  TransmissionRPC-Extensions.swift
//  Transmission Remote
//
//  Created by  on 7/14/19.
//

#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit
#else
import Cocoa
#endif

import TransmissionRPC
import Categorization
import SwiftUI

extension Torrent {

    var iconType: TorrentIconType {
        if isError {
            return .Error
        }
        else if isDownloading {
            return .Download
        }
        else if isSeeding {
            return .Upload
        }
        else if isStopped {
            return .Pause
        }
        else if isWaiting {
            return .Wait
        }
        else if isChecking {
            return .Verify
        }
        else if isFinished {
            return .Completed
        }
        return .All
    }

    var statusColor: Color {
       if isDownloading {
            return Color.colorDownload
        }
        else if isSeeding {
            return Color.colorUpload
        }
        else if isWaiting {
            return Color.colorWait
        }
        else if isChecking {
            return Color.colorVerify
        }
       else if isError {
        return Color.colorError
       }
       else if isStopped {
        return Color.colorPaused
       }
        else if isFinished {
            return Color.colorCompleted
        }
        return Color.systemFill
    }
    
    public convenience init(status: TorrentStatus) {
        self.init()
        self.status = status
        self.CommonInit()
    }
}

struct TorrentActive: Codable, Identifiable  {
    public var name: String = ""
    public var trId: TrId
    public var status: TorrentStatus = .unknown
    public var activityDate: Date?
    public var startDate: Date?
    public var addedDate: Date?
    public var percentDone: Double = 0.0
    
    var id: Int {
        return trId
    }
    
    private enum CodingKeys: String, CodingKey {
        case trId = "id"
        case name = "name"
        case status = "status"
        case activityDate = "activityDate"
        case startDate = "startDate"
        case addedDate = "addedDate"
        case percentDone = "percentDone"
    }
}

struct JSONTorrentActiveArguments: Codable {
    
    public var torrents: [TorrentActive]
    public var removed: [trId]?
    private enum CodingKeys: String, CodingKey {
        case torrents
        case removed
    }
}

struct JSONTorrentsActive: Codable {
    public var arguments: JSONTorrentActiveArguments
    public var result: String
    
    private enum CodingKeys: String, CodingKey {
        case arguments
        case result
    }
}

var countryNameContext = 1
var countryCodeContext = 0
extension Peer {
    
    var countryName: String {
        get {
            return objc_getAssociatedObject(self, &countryNameContext) as? String ?? ""
        }
        set {
            objc_setAssociatedObject(self, &countryNameContext, newValue , objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var countryCode: String {
        get {
            return objc_getAssociatedObject(self, &countryCodeContext) as? String ?? ""
        }
        set {
            objc_setAssociatedObject(self, &countryCodeContext, newValue , objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


