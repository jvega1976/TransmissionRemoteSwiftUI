    //
    //  TorrentTrackers.swift
    //  TransmissionRemoteSwiftUI
    //
    //  Created by  on 3/6/20.
    //
    
    import SwiftUI
    import TransmissionRPC
    
    struct TorrentTrackers: View {
        
        @EnvironmentObject var connector: RPCConnector
        @EnvironmentObject var appState: AppState
        @Environment(\.colorScheme) var colorScheme: ColorScheme
        
        var body: some View {
            ScrollView {
                GroupBox(label: Text("Trackers").font(self.appState.sizeIsCompact ? .title3 : .title)) {
                    ForEach(self.connector.torrent.trackers, id: \.trackerId) { tracker  in
                        VStack(alignment: .center, spacing: 20.0) {
                            HStack(alignment: .center, spacing: self.appState.sizeIsCompact ? 10 : 40) {
                                Image("trackers")
                                    .resizable()
                                    .scaledToFill()
                                    .foregroundColor(.blue)
                                    .frame(width: self.appState.sizeIsCompact ? 30 : 50, height: self.appState.sizeIsCompact ? 30 : 50, alignment: .center)
                                    .padding(.leading, self.appState.sizeIsCompact ? 0 : 25.0)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(tracker.host)
                                        .fontWeight(.semibold)
                                    (Text("State: ")
                                        .fontWeight(.semibold)
                                     + Text(tracker.announceString))
                                    ((Text("Last announce ") + Text(self.appState.sizeIsCompact && !self.appState.isiPhone ? ": " : "time: "))
                                        .fontWeight(.semibold)
                                        + Text(tracker.lastAnnounceTimeString))
                                    ((Text("Next announce ") + Text(self.appState.sizeIsCompact && !self.appState.isiPhone ? ": " : "time: "))
                                        .fontWeight(.semibold)
                                        + Text(tracker.nextAnnounceTimeString))
                                    ((Text("Last \(self.appState.sizeIsCompact ? "" : "announce ")scrapped ") + Text(self.appState.sizeIsCompact && !self.appState.isiPhone ? ": " : "time: "))
                                        .fontWeight(.semibold)
                                        + Text(tracker.lastScrapeTimeString))
                                    ((Text("Next \(self.appState.sizeIsCompact ? "" : "announce ")scrapped ") + Text(self.appState.sizeIsCompact && !self.appState.isiPhone ? ": " : "time: "))
                                        .fontWeight(.semibold)
                                        + Text(tracker.nextScrapeTimeString))
                                }
                                .font(self.appState.sizeIsCompact ? .footnote : .headline)
                                .minimumScaleFactor(0.85)
                                .lineLimit(1)
                                Spacer()
                            }
                            Divider()
                            HStack(alignment: .center, spacing: self.appState.sizeIsCompact ? 5 : 10) {
                                if !self.appState.sizeIsCompact {
                                    Spacer()
                                }
                                Text("Leechers: ")
                                    .fontWeight(.semibold)
                                Text(String(tracker.leecherCount))
                                Spacer()
                                Text("Seeders: ")
                                    .fontWeight(.semibold)
                                Text(String(tracker.seederCount))
                                Spacer()
                                Text("Downloaded: ")
                                    .fontWeight(.semibold)
                                Text(String(format: "%ld",tracker.downloadCount))
                                if !self.appState.sizeIsCompact {
                                    Spacer()
                                }
                            }
                            .font(self.appState.sizeIsCompact ? .footnote : .headline)
                            .multilineTextAlignment(self.appState.sizeIsCompact ? .center : .trailing )
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                        }
                    }
                    .onDelete { indexes in
                        var trackerIds = [Int]()
                        for index in indexes {
                            trackerIds.append(self.connector.torrent.trackers[index].trackerId)
                        }
                        var fields = JSONObject()
                        fields[JSONKeys.trackerRemove] = trackerIds
                        self.connector.setFields(fields, forTorrents: [self.connector.torrent.trId])
                    }
                }
                .groupBoxStyle(InfoGroupBoxStyle(colorScheme: self.colorScheme))
            }
        }
    }
    
    struct TorrentTrackers_Previews: PreviewProvider {
        static var connector: RPCConnector = {
            let connector = RPCConnector()
            let torrent = torrentsPreview().first
            connector.torrent = torrent!
            dump(torrent!.trackers)
            return connector
        }()
        
        static var appState :AppState = {
            let appState = AppState()
            appState.sizeIsCompact = true
            appState.isLandscape = false
            return appState
        }()
        
        static var previews: some View {
            TorrentTrackers()
                .previewDevice("iPhone 8 Plus")
                .preferredColorScheme(.dark)
                .environmentObject(self.connector)
                .environmentObject(self.appState)
                .environment(\.colorScheme, .dark)
        }
    }
    
    
    
