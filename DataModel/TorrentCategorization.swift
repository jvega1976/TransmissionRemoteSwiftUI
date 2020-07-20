//
//  TorrentCategorization.swift
//  Transmission Remote
//
//  Created by  on 7/14/19.
//

import Categorization
import TransmissionRPC
import SwiftUI



let TR_GL_TITLE_ALL = NSLocalizedString("All", comment: "StatusCategory title")
let TR_GL_TITLE_DOWN = NSLocalizedString("Downloading", comment: "StatusCategory title")
let TR_GL_TITLE_UPL = NSLocalizedString("Seeding", comment: "StatusCategory title")
let TR_GL_TITLE_PAUSE = NSLocalizedString("Stopped", comment: "StatusCategory title")
let TR_GL_TITLE_ACTIVE = NSLocalizedString("Active", comment: "StatusCategory title")
let TR_GL_TITLE_VERIFY = NSLocalizedString("Verifying", comment: "StatusCategory title")
let TR_GL_TITLE_WAIT = NSLocalizedString("Waiting", comment: "StatusCategory title")
let TR_GL_TITLE_ERROR = NSLocalizedString("Error", comment: "StatusCategory title")
let TR_GL_TITLE_COMPL = NSLocalizedString("Completed", comment: "StatusCategory title")

let TR_CAT_IDX_ALL = 0
let TR_CAT_IDX_DOWN = 1
let TR_CAT_IDX_UPL = 2
let TR_CAT_IDX_ACTIVE = 3
let TR_CAT_IDX_WAIT = 4
let TR_CAT_IDX_COMPL = 5
let TR_CAT_IDX_PAUSED = 6
let TR_CAT_IDX_ERROR = 7
let TR_CAT_IDX_VERIFY = 8

public typealias TorrentCategory = CategoryDef<Torrent>
//typealias TorrentPredicate = Predicate<Torrent>

@objc(TorrentCategorization)
open class TorrentCategorization: Categorization<Torrent> {
    
    
    public static var shared = TorrentCategorization()
    
    override public init () {
        var categoryList = Array<TorrentCategory>()
        var c: TorrentCategory
        var p: Predicate
        
        
        // Fill Categories
        p = {_ in return true}
        c = Category(withTitle: TR_GL_TITLE_ALL, filterPredicate: p, sortIndex: 999, isAlwaysVisible: true)
        categoryList.append(c)
        
        var downCat = [TorrentCategory]()
        p = { torrent in return torrent.isDownloading } //NSPredicate(format: "isDownloading == YES")
        c = Category(withTitle: TR_GL_TITLE_DOWN, filterPredicate: p, sortIndex: 0, isAlwaysVisible: true)
        downCat.append(c)
    
        p = {torrent in return torrent.status == .downloadWait } //NSPredicate(format: "isWaiting == YES")
        c = Category(withTitle: TR_GL_TITLE_WAIT, filterPredicate: p, sortIndex: 0, isAlwaysVisible: true)
        downCat.append(c)
        
        c = CompoundCategory(withTitle: TR_GL_TITLE_DOWN, subCategories: downCat, sortBySubCategories: true, allowingDuplicates: false) 
        categoryList.append(c)
        
        p = { torrent in return torrent.isSeeding } //NSPredicate(format: "isSeeding == YES")
        c = Category(withTitle: TR_GL_TITLE_UPL, filterPredicate: p, sortIndex: 5, isAlwaysVisible: true)
        categoryList.append(c)
        
        p = {torrent in return torrent.downloadRate > 0 || torrent.uploadRate > 0 } //NSPredicate(format: "downloadRate > 0 OR uploadRate > 0")
        c = Category(withTitle: TR_GL_TITLE_ACTIVE, filterPredicate: p, sortIndex: 999, isAlwaysVisible: false)
        categoryList.append(c)
        
        p = {torrent in return torrent.isWaiting } //NSPredicate(format: "isWaiting == YES")
        c = Category(withTitle: TR_GL_TITLE_WAIT, filterPredicate: p, sortIndex: 1, isAlwaysVisible: false)
        categoryList.append(c)
        
        p = {torrent in return torrent.isFinished } //NSPredicate(format: "isFinished == YES")
        c = Category(withTitle: TR_GL_TITLE_COMPL, filterPredicate: p, sortIndex: 6, isAlwaysVisible: true)
        categoryList.append(c)
        
        p = {torrent in return torrent.isStopped }  //NSPredicate(format: "isStopped == YES")
        c = Category(withTitle: TR_GL_TITLE_PAUSE, filterPredicate: p, sortIndex: 2, isAlwaysVisible: false)
        categoryList.append(c)
        
        p = {torrent in return torrent.isError } //NSPredicate(format: "isError == YES")
        c = Category(withTitle: TR_GL_TITLE_ERROR, filterPredicate: p, sortIndex: 3, isAlwaysVisible: false)
        categoryList.append(c)
        
        p = {torrent in return torrent.isChecking } //NSPredicate(format: "isChecking == YES")
        c = Category(withTitle: TR_GL_TITLE_VERIFY, filterPredicate: p, sortIndex: 4, isAlwaysVisible: false)
        categoryList.append(c)
        super.init(withItems: [Torrent](), withCategories: categoryList)
        self.visibleCategoryPredicate = { category in return category.isAlwaysVisible || self.numberOfItemsInCategory(withTitle: category.title) > 0 }
        self.isSorted = true
        self.sortPredicate = { tl,tr in  tl > tr }
    }
    
    public func restart() {
        self.setItems([])
        self.filterPredicate = {element in return true}
        self.sortPredicate = { tr,tl in  tr > tl } 
    }

}


extension TorrentCategory {
    
    var iconType: TorrentIconType {
        if(title == TR_GL_TITLE_ERROR) {
            return .Error
        }
        else if(self.title == TR_GL_TITLE_DOWN) {
            return .Download
        }
        else if(title == TR_GL_TITLE_UPL) {
            return .Upload
        }
        else if(title == TR_GL_TITLE_PAUSE) {
            return .Pause
        }
        else if(title == TR_GL_TITLE_WAIT) {
            return .Wait
        }
        else if(title == TR_GL_TITLE_VERIFY) {
            return .Verify
        }
        else if(title == TR_GL_TITLE_ACTIVE) {
            return .Active
        }
        else if(title == TR_GL_TITLE_ALL) {
            return .All
        }
        else if(title == TR_GL_TITLE_COMPL) {
            return .Completed
        }
        return .None
    }
    
    var icon : TorrentIcon {
        let icon = TorrentIcon(type: self.iconType, color: self.iconColor)
        return icon
    }
    
    var iconColor: Color {
        if(title == TR_GL_TITLE_ERROR) {
            return Color.colorError
        }
        else if(self.title == TR_GL_TITLE_DOWN) {
            return Color.colorDownload
        }
        else if(title == TR_GL_TITLE_UPL) {
            return Color.colorUpload
        }
        else if(title == TR_GL_TITLE_PAUSE) {
            return Color.colorPaused
        }
        else if(title == TR_GL_TITLE_WAIT) {
            return Color.colorWait
        }
        else if(title == TR_GL_TITLE_VERIFY) {
            return Color.colorVerify
        }
        else if(title == TR_GL_TITLE_ACTIVE) {
            return Color.colorActive
        }
        else if(title == TR_GL_TITLE_ALL) {
            return Color.colorAll
        }
        else if(title == TR_GL_TITLE_COMPL) {
            return Color.colorCompleted
        }
        return Color.systemFill
    }
    
}


extension Torrent: CategoryItem {
 /*   public func update(with torrent: Torrent) {
        self.trId = torrent.trId
        self.name = torrent.name
        self.status = torrent.status
        self.percentDone = torrent.percentDone
        self.dateDone = torrent.dateDone
        self.errorString = torrent.errorString
        self.activityDate = torrent.activityDate
        self.totalSize = torrent.totalSize
        self.downloadedEver = torrent.downloadedEver
        self.secondsDownloading = torrent.secondsDownloading
        self.secondsSeeding = torrent.secondsSeeding
        self.uploadRate = torrent.uploadRate
        self.downloadRate = torrent.downloadRate
        self.peersConnected = torrent.peersConnected
        self.peersSendingToUs = torrent.peersSendingToUs
        self.peersGettingFromUs = torrent.peersGettingFromUs
        self.uploadedEver = torrent.uploadedEver
        self.uploadRatio = torrent.uploadRatio
        self.hashString = torrent.hashString
        self.piecesCount = torrent.piecesCount
        self.pieceSize = torrent.pieceSize
        self.comment = torrent.comment
        self.downloadDir = torrent.downloadDir
        self.errorNumber = torrent.errorNumber
        self.creator = torrent.creator
        self.dateCreated = torrent.dateCreated
        self.dateAdded = torrent.dateAdded
        self.haveValid = torrent.haveValid
        self.recheckProgress = torrent.recheckProgress
        self.bandwidthPriority = torrent.bandwidthPriority
        self.honorsSessionLimits = torrent.honorsSessionLimits
        self.peerLimit = torrent.peerLimit
        self.uploadLimited = torrent.uploadLimited
        self.uploadLimit = torrent.uploadLimit
        self.downloadLimited = torrent.downloadLimited
        self.downloadLimit = torrent.downloadLimit
        self.seedIdleMode = torrent.seedIdleMode
        self.seedIdleLimit = torrent.seedIdleLimit
        self.seedRatioMode = torrent.seedRatioMode
        self.seedRatioLimit = torrent.seedRatioLimit
        self.queuePosition = torrent.queuePosition
        self.eta = torrent.eta
        self.haveUnchecked = torrent.haveUnchecked
        self.CommonInit()
    } */
}
