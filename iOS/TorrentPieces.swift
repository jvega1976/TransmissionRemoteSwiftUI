//
//  TorrentPieces.swift
//  TransmissionRemoteSwiftUI
//
//  Created by  on 3/6/20.
//

import SwiftUI
import TransmissionRPC

struct TorrentPieces: View {
    
    @EnvironmentObject var connector: RPCConnector
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Image(systemName:"puzzlepiece")
                    .resizable()
                    .imageScale(.large)
                    .scaledToFit()
                    .foregroundColor(.blue)
                    .frame(width: self.appState.sizeIsCompact ? 50 : 70, height: self.appState.sizeIsCompact ? 50 : 70, alignment: .center)
                VStack(alignment: .leading) {
                    HStack {
                        Text("Pieces count: \(self.connector.torrent.piecesCount)")
                            .font(self.appState.sizeIsCompact ? .footnote : nil)
                        Spacer()
                        Text("Piece size: \(ByteCountFormatter.formatByteCount(self.connector.torrent.pieceSize))")
                            .font(self.appState.sizeIsCompact ? .footnote : nil)
                        Spacer()
                    }
                    HStack {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: self.appState.sizeIsCompact ? 20 : 30, height: self.appState.sizeIsCompact ? 20 : 30, alignment: .center)
                        Text("Piece is available")
                            .font(self.appState.sizeIsCompact ? .footnote : nil)
                            .padding(.leading)
                    }
                    HStack {
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: self.appState.sizeIsCompact ? 20 : 30, height: self.appState.sizeIsCompact ? 20 : 30, alignment: .center)
                        Text("Piece is unavailable")
                            .font(self.appState.sizeIsCompact ? .footnote : nil)
                            .padding(.leading)
                    }
                }
                .padding(.leading)
            }
            .padding([.leading, .bottom])
            Pieces(torrent: connector.torrent)
                //.id(self.connector.torrent.trId)
                .frame(width: self.appState.sizeIsCompact ? 200 : 300, height: self.appState.sizeIsCompact ? 200 : 300, alignment: .center)
                .imageScale(.large)
                .padding(40.0)
                .background(self.colorScheme == .light ? Color(.sRGB, white: 0.95, opacity: 0.95) : Color(.sRGB, white: 0.05, opacity: 0.95))
                .cornerRadius(15)
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.primary.opacity(0.7), lineWidth: 1))
        }.frame(alignment: .top)
    }
    
}

struct TorrentPieces_Previews: PreviewProvider {
    
    static let connector: RPCConnector = {
        let sema = DispatchSemaphore(value: 0)
        let connector = RPCConnector(serverConfig: RPCServerConfig())
        connector.torrent = Torrent()
        connector.torrent.trId = 4999
        connector.connectSession()
        return connector
    }()
    
    static let appState = AppState()
    
    static var previews: some View {
        TorrentPieces().environmentObject(connector).environmentObject(appState)
            .device()
    }
}
