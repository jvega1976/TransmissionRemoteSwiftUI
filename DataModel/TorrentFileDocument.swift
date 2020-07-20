//
//  TorrentFileDocument.swift
//  TransmissionRemoteSwiftUI
//
//  Created by Johnny Vega Sosa on 6/26/20.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var torrentFile: UTType {
        UTType(exportedAs: "net.johnnyvega.TransmissionRemote.torrent")
    }
}

struct TorrentFileDocument: FileDocument {

    static var readableContentTypes: [UTType] { [.torrentFile] }

    var data: Data?
    
    init() {
        self.data = nil
    }
    
    init(fileWrapper: FileWrapper, contentType: UTType) throws {
        self.data = fileWrapper.regularFileContents
    }
    
    func write(to fileWrapper: inout FileWrapper, contentType: UTType) throws {
        return
    }
}
