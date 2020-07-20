        //
//  SessionStats.swift
//  TransmissionRemoteSwiftUI
//
//  Created by  on 6/21/20.
//

import SwiftUI
import TransmissionRPC
struct SessionStatsView: View {
    @EnvironmentObject var connector: RPCConnector
    @EnvironmentObject var sessionStats: SessionStats
    @EnvironmentObject var appState: AppState
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Statistics")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding([.top, .leading, .bottom])
        List {
            Section(header: Text("Speed")) {
                HStack(spacing: 20) {
                    Image("halfCloudDown")
                        .resizable()
                        .formatPlayIcon(.link)
                    Text("Download Speed:")
                    Spacer()
                    Text(self.sessionStats.downloadSpeedString)
                        .multilineTextAlignment(.trailing)
                }
            HStack(spacing: 20) {
                    Image("halfCloudUpload")
                        .resizable()
                        .formatPlayIcon(.link)
                    Text("Upload Speed:")
                    Spacer()
                    Text(self.sessionStats.uploadSpeedString)
                        .multilineTextAlignment(.trailing)
            }.padding(.bottom)
        }.padding(.horizontal)
        Section(header: Text("Counts")) {
                HStack(spacing: 20) {
                    Image(systemName: "number.circle")
                        .resizable()
                        .formatPlayIcon(.link)
                    Text("Active Torrents: ")
                    Spacer()
                    Text(String(self.sessionStats.activeTorrentCount))
                        .multilineTextAlignment(.trailing)
                }
                HStack(spacing: 20) {
                    Image(systemName: "number.square")
                        .resizable()
                        .formatPlayIcon(.link)
                    Text("Paused Torrents:")
                    Spacer()
                    Text(String(self.sessionStats.pausedTorrentCount))
                        .multilineTextAlignment(.trailing)
                }
            HStack(spacing: 20) {
                Image(systemName: "number.circle.fill")
                    .resizable()
                    .formatPlayIcon(.link)
                Text("Total Torrents:")
                Spacer()
                Text(String(self.sessionStats.pausedTorrentCount))
                    .multilineTextAlignment(.trailing)
            }.padding(.bottom)
            }.padding(.horizontal)
        Section(header: Text("Current")) {
                HStack(spacing: 20) {
                    Image("iconTotalDownloaded")
                        .resizable()
                        .formatPlayIcon(.link)
                    Text("Bytes Downloaded")
                    Spacer()
                    Text(String(self.sessionStats.currentdownloadedBytesString))
                        .multilineTextAlignment(.trailing)
                }
                HStack(spacing: 20) {
                    Image("iconTotalUploaded")
                        .resizable()
                        .formatPlayIcon(.link)
                    Text("Bytes Uploaded:")
                    Spacer()
                    Text(String(self.sessionStats.currentUploadedBytesString))
                        .multilineTextAlignment(.trailing)
                }
                HStack(spacing: 20) {
                    Image("files")
                        .resizable()
                        .formatPlayIcon(.link)
                    Text("Added Files:")
                    Spacer()
                    Text(String(self.sessionStats.currentFilesAdded))
                        .multilineTextAlignment(.trailing)
                }
            HStack(spacing: 20) {
                Image("iconClock")
                    .resizable()
                    .formatPlayIcon(.link)
                Text("Active Time:")
                Spacer()
                Text(self.sessionStats.currentSecondsActiveString)
                    .multilineTextAlignment(.trailing)
            }
            HStack(spacing: 20) {
                Image("iconComputer")
                    .resizable()
                    .formatPlayIcon(.link)
                Text("Sessions:")
                Spacer()
                Text(String(self.sessionStats.currentsessionCount))
                    .multilineTextAlignment(.trailing)
            }.padding(.bottom)
            }.padding(.horizontal)
            Section(header: Text("Cummulative")) {
                HStack(spacing: 20) {
                    Image("iconTotalDownloaded")
                        .resizable()
                        .formatPlayIcon(.link)
                    Text("Bytes Downloaded")
                    Spacer()
                    Text(String(self.sessionStats.cumulativedownloadedBytesString))
                        .multilineTextAlignment(.trailing)
                }
                HStack(spacing: 20) {
                    Image("iconTotalUploaded")
                        .resizable()
                        .formatPlayIcon(.link)
                    Text("Bytes Uploaded:")
                    Spacer()
                    Text(String(self.sessionStats.cumulativeUploadedBytesString))
                        .multilineTextAlignment(.trailing)
                }
                HStack(spacing: 20) {
                    Image("files")
                        .resizable()
                        .formatPlayIcon(.link)
                    Text("Added Files:")
                    Spacer()
                    Text(String(self.sessionStats.cumulativeFilesAdded))
                        .multilineTextAlignment(.trailing)
                }
                HStack(spacing: 20) {
                    Image("iconClock")
                        .resizable()
                        .formatPlayIcon(.link)
                    Text("Active Time:")
                    Spacer()
                    Text(self.sessionStats.cumulativeSecondsActiveString)
                        .multilineTextAlignment(.trailing)
                }
                HStack(spacing: 20) {
                    Image("iconComputer")
                        .resizable()
                        .formatPlayIcon(.link)
                    Text("Sessions:")
                    Spacer()
                    Text(String(self.sessionStats.cumulativesessionCount))
                        .multilineTextAlignment(.trailing)
                }.padding(.bottom)
            }.padding(.horizontal)
        }
        }.font(self.appState.sizeIsCompact ? .footnote : nil)
            .frame(width: !self.appState.sizeIsCompact ? 400 : nil, height: !self.appState.sizeIsCompact ? 800 : nil)
            .cornerRadius(25)
            .shadow(color: Color(.sRGB, white: self.colorScheme == .light ? 0 : 1 , opacity: 0.33), radius: 10)
            .opacity(0.97)
    }
}

struct SessionStatsView_Previews: PreviewProvider {
    static var connector: RPCConnector = {
        let serverConfig = RPCServerConfig()
        let connector = RPCConnector(serverConfig: serverConfig)
        connector.session =  try? RPCSession(withURL: serverConfig.configURL!, andTimeout: serverConfig.requestTimeout)
        return connector
    }()
    static var appState: AppState = {
        let appState = AppState()
        appState.sizeIsCompact = true
        return appState
    }()
    
    static var previews: some View {
        Group {
        SessionStatsView()
        .environmentObject(connector)
            .environmentObject(connector.sessionStats)
        .environmentObject(appState)
        .previewDevice(PreviewDevice(stringLiteral: "iPhone 8 Plus"))
            SessionStatsView()
                .environmentObject(connector)
                .environmentObject(connector.sessionStats)
                .environmentObject(appState)
            .device()
        }
    }
}
