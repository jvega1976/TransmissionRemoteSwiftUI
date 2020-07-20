//
//  TorrentPeers.swift
//  TransmissionRemoteSwiftUI
//
//  Created by  on 2/23/20.
//

import SwiftUI
import TransmissionRPC

struct TorrentPeers: View {
    @EnvironmentObject var connector: RPCConnector
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var message: String = ""
    @State private var messageType: MessageType = .info
    
    
    var body: some View {
        ScrollView  {
            GroupBox(label: Text("Peers").font(self.appState.sizeIsCompact ? .title2 : .largeTitle)) {
                if self.connector.peers.isEmpty {
                    Text("No Peers available")
                        .multilineTextAlignment(.center)
                        .padding([.leading, .bottom, .trailing])
                } else {
                    ForEach (self.connector.peers, id: \.ipAddress) { peer  in
                        if self.appState.sizeIsCompact {
                            Divider()
                            PeerCompactRowView(peer: peer)
                        } else {
                            PeerRowView(peer: peer)
                                .padding(.horizontal)
                            Divider()
                        }
                    }
                }
            }.groupBoxStyle(InfoGroupBoxStyle(colorScheme: self.colorScheme))
            GroupBox(label: Text("Statistics").font(self.appState.sizeIsCompact ? .title2 :.largeTitle)) { () -> PeerStatsView in
                let labelSize: CGFloat = appState.sizeIsCompact ? 45 : 60
                let imageSize: CGFloat = appState.sizeIsCompact ? 30 : 50
                let textSize: CGFloat = appState.sizeIsCompact ? 30 : 20
                let columns: [GridItem] = [
                        .init(.fixed(imageSize), spacing: self.appState.sizeIsCompact ? 5 : 10, alignment: .center),
                        .init(.fixed(labelSize), spacing: 5, alignment: .leading),
                        .init(.fixed(textSize), spacing: self.appState.sizeIsCompact ? 20 : 30, alignment: .trailing),
                        .init(.fixed(imageSize), spacing: self.appState.sizeIsCompact ? 5 : 10, alignment: .center),
                        .init(.fixed(labelSize + 10), spacing: 5, alignment: .leading),
                        .init(.fixed(textSize), spacing: 10, alignment: .trailing)
                    ]
                PeerStatsView(columns: columns)
            }
            .groupBoxStyle(InfoGroupBoxStyle(colorScheme: self.colorScheme))
            VStack {
                Text("Flags Descriptions")
                    .font(self.appState.sizeIsCompact ? .subheadline : .title3)
                    .padding(.bottom, 7.0)
                Text("O - Optimistic unchoke")
                Text("D - Downloading from this peer")
                Text("d - We would download from this peer if they'd let us")
            }.font( self.appState.sizeIsCompact ? .caption : .footnote)
        }
        .font( self.appState.sizeIsCompact ? .footnote : .body)
        .onAppear {
            self.connector.startPeersRefresh()
        }
        .onDisappear {
            self.connector.stopPeersRefresh()
        }
    }
}

struct TorrentPeers_Previews: PreviewProvider {
    static let connector: RPCConnector = {
        let serverConfig = RPCServerConfig()
        let connector = RPCConnector(serverConfig: serverConfig)
        connector.session = try? RPCSession(withURL: serverConfig.configURL!, andTimeout: serverConfig.requestTimeout)
        connector.torrent.trId = 103
        return connector
    }()
    static let appState: AppState = {
        let appState = AppState()
        appState.sizeIsCompact = false
        appState.isLandscape = false
        appState.detailViewIsDisplayed = false
        appState.isiPhone = false
        appState.horizontalSizeClass = .regular
        appState.verticalSizeClass = .regular
        return appState
    }()
    
    static var previews: some View {
        Group {
            TorrentPeers()
                .preferredColorScheme(.dark)
                .environmentObject(connector).environmentObject(appState)
                .environment(\.colorScheme, .dark)
                .previewDevice("iPhone 8 Plus")
            
            TorrentPeers()
            .preferredColorScheme(.dark)
            .environmentObject(connector).environmentObject(appState)
            .device()
        }
       
    }
}

struct PeerRowView: View {
    @ObservedObject var peer: Peer
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center, spacing: 10) {
                Text("IP Address:")
                 .foregroundColor(Color.blue)
                Text(peer.ipAddress)                
                Spacer()
                Text("Port:")
                 .foregroundColor(Color.blue)
                Text(String(peer.port))
                Spacer()
                Text("Country:")
                 .foregroundColor(Color.blue)
                Text(peer.countryName)
                    .lineLimit(1)
                Image(peer.countryCode)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20, alignment: .center)
            }
            HStack(alignment: .center, spacing: 10)  {
                Text("Client:")
                 .foregroundColor(Color.blue)
                Text(peer.clientName)
                Image(String(peer.clientName.split(separator: " ").first ?? " "))
                    .resizable()
                    .scaledToFill()
                    .frame(width:  20, height: 20, alignment: .center)
                Spacer()
                HStack {
                    Image( peer.isEncrypted ? "lock" : "lock.open")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18, alignment: .center)
                    if peer.isUTP {
                        Image("utp")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 18, height: 18, alignment: .center)
                    }
                    Text(peer.flagString)
                }.frame(height: 18, alignment: .center)
            }
            HStack(alignment: .center, spacing: 10)  {
                Text("Have:")
                 .foregroundColor(Color.blue)
                Text(peer.progressString)
                Spacer()
                Text("↓ Download rate")
                 .foregroundColor(Color.blue)
                Text(peer.rateToClientString)
                Spacer()
                Text("↑ Upload rate:")
                 .foregroundColor(Color.blue)
                Text(peer.rateToPeerString)
            }
        }.font(.body)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }
}

struct PeerCompactRowView: View {
    @ObservedObject var peer: Peer
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center, spacing: 10) {
                Text("IP Address:")
                    .foregroundColor(Color.blue)
                Text(peer.ipAddress)
                    .layoutPriority(0.5)
                Spacer()
                Text("Port:")
                 .foregroundColor(Color.blue)
                Text(String(peer.port))
            }
            HStack(alignment: .center, spacing: 5) {
                Text("Country:")
                 .foregroundColor(Color.blue)
                Text(peer.countryName)
                if !peer.countryCode.isEmpty {
                    Image(peer.countryCode)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 15, height: 15, alignment: .center)
                }
                Spacer()
                Text("Have:")
                 .foregroundColor(Color.blue)
                Text(peer.progressString)
            }
            HStack(alignment: .center, spacing: 10)  {
                Text("Client:")
                 .foregroundColor(Color.blue)
                Text(peer.clientName)
                Image(String(peer.clientName.split(separator: " ").first ?? " "))
                    .resizable()
                    .scaledToFill()
                    .frame(width:  15, height: 15, alignment: .center)
                Spacer()
                HStack {
                    Image( peer.isEncrypted ? "lock" : "lock.open")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15, alignment: .center)
                    if peer.isUTP {
                        Image("utp")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 15, height: 15, alignment: .center)
                    }
                    Text(peer.flagString)
                }.frame(height: 18, alignment: .center)
            }
            HStack(alignment: .center, spacing: 5)  {
                Text("↓ DL:")
                    .foregroundColor(Color.blue)
                Text(peer.rateToClientString)
                Spacer()
                Text("↑ UL:")
                 .foregroundColor(Color.blue)
                Text(peer.rateToPeerString)
            }
        }.font(.caption)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        
    }
}

struct PeerStatsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var connector: RPCConnector
    
    var columns: [GridItem]
    
    var body: some View {
        LazyVGrid(columns: self.columns, alignment: .center, spacing: 15, pinnedViews: [], content: {
            Group {
                Image(systemName: "person.2")
                    .formatImage(self.appState)
                Text("Peers:")
                Text(String(self.connector.peerStat.fromTracker))
                Image(systemName: "person.2")
                    .formatImage(self.appState)
                Text("Cache:")
                Text(String(self.connector.peerStat.fromCache))
            }
            Group {
                Image(systemName: "person.2")
                    .formatImage(self.appState)
                Text("DHT:")
                Text(String(self.connector.peerStat.fromDht))
                Image(systemName: "person.2")
                    .formatImage(self.appState)
                Text("LPD:")
                Text(String(self.connector.peerStat.fromLpd))
            }
            Group {
                Image(systemName: "person.2")
                    .formatImage(self.appState)
                Text("PEX:")
                Text(String(self.connector.peerStat.fromPex))
                Image(systemName: "person.2")
                    .formatImage(self.appState)
                Text("Seeding:")
                Text(String(self.connector.peerStat.fromIncoming))
            }
        })
        .font( self.appState.sizeIsCompact ? .footnote : .body)
        .minimumScaleFactor(0.8)
        .lineLimit(1)
        .padding(.bottom)
    }
}
