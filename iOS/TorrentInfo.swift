//
//  TorrentInfo.swift
//  TransmissionRemoteSwiftUI
//
//  Created by  on 1/31/20.
//

import SwiftUI
import TransmissionRPC

struct TorrentInfo: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var connector: RPCConnector

    var body: some View {
        Group {
            if self.appState.sizeIsCompact {
                CompactView(torrent: self.connector.torrent)
                    .equatable()
            } else {
                NormalView(torrent: self.connector.torrent)
                    .equatable()
            }
        }.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    self.connector.startTorrent(trId: [self.connector.torrent.trId])
                        }){
                    Image(systemName: "arrowtriangle.right.circle")
                        .formatIcon(self.appState)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            self.connector.startNowTorrent(trId: [self.connector.torrent.trId])
                        }){
                            Image(systemName: "arrowtriangle.up.circle")
                                .formatIcon(self.appState)
                        }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            self.connector.stopTorrent(trId: [self.connector.torrent.trId])
                        }){
                            Image(systemName: "pause.circle")
                                .formatIcon(self.appState)
                        }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            self.connector.verifyTorrent(trId: [self.connector.torrent.trId])
                        }){
                            Image(systemName: "checkmark.circle")
                                .formatIcon(self.appState)
                        }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            self.connector.reannounceTorrent(trId: [self.connector.torrent.trId])
                        }){
                            Image(systemName: "arrow.clockwise.circle")
                                .formatIcon(self.appState)
                        }
            }
        }
    }

}



struct TorrentInfo_Previews: PreviewProvider {
    
    static let connector: RPCConnector = {
        let connector = RPCConnector(serverConfig: RPCServerConfig())
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let data = Data("{\"arguments\":{\"torrents\":[{\"activityDate\":1594605188,\"addedDate\":1594597798,\"bandwidthPriority\":0,\"comment\":\"\",\"creator\":\"uTorrent/2210\",\"dateCreated\":1594243975,\"doneDate\":1594597922,\"downloadDir\":\"/volume4/video/Downloads\",\"downloadLimit\":100,\"downloadLimited\":false,\"downloadedEver\":440116730,\"error\":0,\"errorString\":\"\",\"eta\":-1,\"hashString\":\"03ab06ecf58a365369c7e55e3cbaca753cf3f21f\",\"haveUnchecked\":0,\"haveValid\":432460792,\"honorsSessionLimits\":true,\"id\":227,\"isFinished\":false,\"name\":\"[HIS Video] Chip Off the Old Block (1984).mp4\",\"peer-limit\":300,\"peersConnected\":0,\"peersGettingFromUs\":0,\"peersSendingToUs\":0,\"percentDone\":1,\"pieceCount\":825,\"pieceSize\":524288,\"queuePosition\":225,\"rateDownload\":0,\"rateUpload\":0,\"recheckProgress\":0,\"secondsDownloading\":134,\"secondsSeeding\":11442,\"seedIdleLimit\":1440,\"seedIdleMode\":0,\"seedRatioLimit\":1.2999,\"seedRatioMode\":0,\"startDate\":1594597798,\"status\":0,\"totalSize\":432460792,\"uploadLimit\":100,\"uploadLimited\":false,\"uploadRatio\":0.1332,\"uploadedEver\":58639850}]},\"result\":\"success\"}".utf8)
        let response = try? decoder.decode(JSONTorrents.self, from: data)
        let torrents = response?.arguments.torrents
        connector.torrent = (torrents?.first)!
        return connector
    }()
    
    static let appState: AppState = {
        let appState = AppState()
        appState.sizeIsCompact = true
        appState.detailViewIsDisplayed = false
        return appState
    }()
    
    static var previews: some View {
        TorrentInfo()
                .previewDevice("iPhone 8 Plus")
                .preferredColorScheme(.dark)
                .environmentObject(self.connector)
                .environmentObject(self.appState)
                .environment(\.colorScheme, .dark)
    }
}

struct NormalView: View, Equatable {
    
    static func == (lhs: NormalView, rhs: NormalView) -> Bool {
        lhs.torrent == rhs.torrent
    }
    
    @EnvironmentObject var connector: RPCConnector
    @EnvironmentObject var appState: AppState
    @ObservedObject var torrent: Torrent
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var changeLoc: Bool = false
    @State private var askChangeLoc: Bool = false
    @State private var newLoc: String = ""
    
    var body: some View {
        ScrollView {
            GroupBox(label: Text("General")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)) {
                VStack(alignment:.leading, spacing: 15) {
                    Group {
                        HStack(alignment: .top, spacing: 15) {
                            Image("iconBadge")
                                .resizable()
                                .formatPlayIcon(.link)
                            Text("Name: ")
                            Spacer()
                            Text(self.torrent.name)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.trailing)
                                .lineLimit(2)
                        }
                        HStack(alignment: .center, spacing: 15) {
                            Image("checkmark.seal")
                                .resizable()
                                .formatPlayIcon(.link)
                            Text("Status: ")
                            Spacer()
                            Text(self.torrent.statusString)
                        }
                        HStack(alignment: .center, spacing: 15) {
                            Image("iconPercents")
                                .resizable()
                                .formatPlayIcon(.link)
                            Text("Progress: ")
                            Spacer()
                            Text(String(format: "%03.2f%%",(self.torrent.percentsDone * 100)))
                        }
                        HStack(alignment: .center, spacing: 15) {
                            Image("iconFullSize36x36")
                                .resizable()
                                .formatPlayIcon(.link)
                            Text("Size: ")
                            Spacer()
                            Text(ByteCountFormatter.formatByteCount(self.torrent.totalSize))
                        }
                        HStack(alignment: .center, spacing: 15) {
                            Image("iconFullSize36x36")
                                .resizable()
                                .formatPlayIcon(.link)
                            Text("Have: ")
                            Spacer()
                            Text(ByteCountFormatter.formatByteCount(Int(self.torrent.haveValid)))
                        }
                        HStack(alignment: .center, spacing: 15) {
                            Image("iconTotalDownloaded")
                                .resizable()
                                .formatPlayIcon(.link)
                            Text("Downloaded: ")
                            Spacer()
                            Text(ByteCountFormatter.formatByteCount(self.torrent.downloadedEver))
                        }
                    }
                    Group {
                        HStack(alignment: .center, spacing: 15) {
                            Image("iconTotalUploaded")
                                .resizable()
                                .formatPlayIcon(.link)
                            Text("Uploaded: ")
                            Spacer()
                            Text(ByteCountFormatter.formatByteCount(self.torrent.uploadedEver))
                        }
                        HStack(alignment: .center, spacing: 15) {
                            Image("iconSpeedGuage36x36")
                                .resizable()
                                .formatPlayIcon(.link)
                            Text("Speed: ")
                            Spacer()
                            Text(self.torrent.speedString)
                        }
                        HStack(alignment: .center, spacing: 15) {
                            Image("iconPig")
                                .resizable()
                                .formatPlayIcon(.link)
                            Text("Ratio: ")
                            Spacer()
                            Text(String(format: "%02.2f",(self.torrent.uploadRatio)))
                        }
                        
                        HStack(alignment: .center, spacing: 15) {
                            Image("iconClockPie")
                                .resizable()
                                .formatPlayIcon(.link)
                            Text("Seeding Time: ")
                            Spacer()
                            Text(DateFormatter.formatHoursMinutes(self.torrent.secondsSeeding))
                        }
                        HStack(alignment: .center, spacing: 15) {
                            Image("iconClockPie")
                                .resizable()
                                .formatPlayIcon(.link)
                            Text("Downloading Time: ")
                            Spacer()
                            Text(DateFormatter.formatHoursMinutes(self.torrent.secondsDownloading))
                        }
                    }
                }
                
            }
            .groupBoxStyle(InfoGroupBoxStyle(colorScheme: self.colorScheme))
            GroupBox(label: Text("Comment")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)) {
                HStack(alignment: .center, spacing: 15) {
                    Image("iconFile")
                        .resizable()
                        .formatPlayIcon(.link)
                    Text("Comment: ")
                    Spacer()
                    Text(self.torrent.comment)
                }
            }
            .groupBoxStyle(InfoGroupBoxStyle(colorScheme: self.colorScheme))
            GroupBox(label: Text("Individual Settings")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
            ) {
                VStack(alignment: .trailing,spacing: 15) {
                    HStack(alignment: .center, spacing: 15) {
                        Image("iconPositionMark36x36")
                            .resizable()
                            .formatPlayIcon(.link)
                        Text("Queue Position: ")
                            .multilineTextAlignment(.leading)
                        Spacer()
                        TextField("1234", value: self.$torrent.queuePosition, formatter: NumberFormatter(),
                                  onEditingChanged: {_ in },
                                  onCommit: {
                                    var json = JSONObject()
                                    json[JSONKeys.queuePosition] = self.torrent.queuePosition
                                    self.connector.setFields(json, forTorrents: [self.torrent.trId])
                                  }).font(.body)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth:100)
                        
                        Stepper(value: self.$torrent.queuePosition, onEditingChanged: {_ in
                            var json = JSONObject()
                            json[JSONKeys.queuePosition] = self.torrent.queuePosition
                            self.connector.setFields(json, forTorrents: [self.torrent.trId])
                        }) {
                            Text("")
                        }.frame(width:100)
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("iconScale36x36")
                            .resizable()
                            .formatPlayIcon(.link)
                        Text("Bandwidth Priority: ")
                        Spacer()
                        Picker("", selection: self.$torrent.bandwidthPriority) {
                            Text("Low").tag(-1)
                            Text("Normal").tag(0)
                            Text("High").tag(1)
                        }
                        .font(.body)
                        .pickerStyle(SegmentedPickerStyle())
                        .fixedSize()
                        .onChange(of: self.torrent.bandwidthPriority, perform: {value in
                            var json = JSONObject()
                            json[JSONKeys.bandwidthPriority] = value
                            self.connector.setFields(json, forTorrents: [self.torrent.trId])
                        })
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("iconUploadRateLimit20x20")
                            .resizable()
                            .formatPlayIcon(.link)
                        Toggle("Upload Limit (Kb/s): ", isOn: self.$torrent.uploadLimited)
                            .onChange(of: self.torrent.uploadLimited) { value in
                                var json = JSONObject()
                                json[JSONKeys.uploadLimited] = value
                                self.connector.setFields(json, forTorrents: [self.torrent.trId])
                            }
                        TextField("1234", value: self.$torrent.uploadLimit, formatter: NumberFormatter(),
                                  onEditingChanged: {_ in },
                                  onCommit: {
                                    var json = JSONObject()
                                    json[JSONKeys.uploadLimit] = self.torrent.uploadLimit
                                    self.connector.setFields(json, forTorrents: [self.torrent.trId])
                                  }).font(.body)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                            .frame(width:70)
                            .disabled(!self.torrent.uploadLimited)
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("iconDownloadRateLimit20x20")
                            .resizable()
                            .formatPlayIcon(.link)
                        Toggle("Download Limit (Kb/s): ", isOn: self.$torrent.downloadLimited)
                            .onChange(of: self.torrent.downloadLimited) { value in
                                var json = JSONObject()
                                json[JSONKeys.downloadLimited] = value
                                self.connector.setFields(json, forTorrents: [self.torrent.trId])
                            }
                        TextField("1234", value: self.$torrent.downloadLimit, formatter: NumberFormatter(),
                                  onEditingChanged: {_ in },
                                  onCommit: {
                                    var json = JSONObject()
                                    json[JSONKeys.downloadLimit] = self.torrent.downloadLimit
                                    self.connector.setFields(json, forTorrents: [self.torrent.trId])
                                    
                                  }).font(.body)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                            .frame(width:70)
                            .disabled(!self.torrent.downloadLimited)
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("iconPig")
                            .resizable()
                            .formatPlayIcon(.link)
                        Text("Seed Ratio Limit: ")
                        Spacer()
                        Picker("", selection: self.$torrent.seedRatioMode) {
                            Text("Global").tag(0)
                            Text("Limited").tag(1)
                            Text("Unlimited").tag(2)
                        }.font(.body)
                        .pickerStyle(SegmentedPickerStyle())
                        .fixedSize()
                        .onChange(of: self.torrent.seedRatioMode, perform: {value in
                            var json = JSONObject()
                            json[JSONKeys.seedRatioMode] = value
                            self.connector.setFields(json, forTorrents: [self.torrent.trId])
                        })
                        TextField("1234", value: self.$torrent.seedRatioLimit, formatter: { let formatter = NumberFormatter()
                            formatter.numberStyle = .decimal
                            formatter.maximumFractionDigits = 3
                            return formatter
                        }(),
                        onEditingChanged: {_ in },
                        onCommit: {
                            var json = JSONObject()
                            json[JSONKeys.seedRatioLimit] = self.torrent.seedRatioLimit
                            self.connector.setFields(json, forTorrents: [self.torrent.trId])}
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.trailing)
                        .frame(width:70)
                        .disabled(!(torrent.seedRatioMode == 1))
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("iconClockPie")
                            .resizable()
                            .formatPlayIcon(.link)
                        Text("Seed Idle Limit: ")
                        Spacer()
                        Picker("", selection: self.$torrent.seedIdleMode) {
                            Text("Global").tag(0)
                            Text("Limited").tag(1)
                            Text("Unlimited")
                                .tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .fixedSize()
                        .onChange(of: self.torrent.seedIdleMode, perform: {value in
                            var json = JSONObject()
                            json[JSONKeys.seedIdleMode] = value
                            self.connector.setFields(json, forTorrents: [self.torrent.trId])
                        })
                        TextField("1234", value: self.$torrent.seedIdleLimit, formatter: NumberFormatter(),
                                  onEditingChanged: {_ in },
                                  onCommit: {
                                    var json = JSONObject()
                                    json[JSONKeys.seedIdleLimit] = self.torrent.seedIdleLimit
                                    self.connector.setFields(json, forTorrents: [self.torrent.trId])}
                        ).font(.body)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.trailing)
                        .frame(width:70)
                        .disabled(!(torrent.seedIdleMode == 1))
                    }
                }
                .padding(.top)
            }
            .groupBoxStyle(InfoGroupBoxStyle(colorScheme: self.colorScheme))
            GroupBox(label: Text("Details")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)) {
                VStack(alignment: .leading, spacing: 15) {
                    HStack(alignment: .center, spacing: 15) {
                        Image("transmission")
                            .resizable()
                            .formatPlayIcon(.link)
                        Text("Torrent Id: ")
                        Spacer()
                        Text(String(torrent.trId))
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("folder")
                            .resizable()
                            .formatPlayIcon(.link)
                        Text("Download Folder: ")
                            .scaledToFit()
                            .fixedSize()
                        Spacer()
                        if self.changeLoc {
                            TextField("Download Location", text: $newLoc, onEditingChanged: { _ in
                            }, onCommit: {
                                self.askChangeLoc.toggle()
                                self.changeLoc.toggle()
                            })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            Text(torrent.downloadDir)
                                .minimumScaleFactor(0.75)
                                .clipped()
                        }
                        Button(action: { self.newLoc = self.torrent.downloadDir
                                self.changeLoc.toggle() }) {
                            Image("folder.circle")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(.blue)
                        }.alert(isPresented: $askChangeLoc) {
                            Alert(title: Text("Do you want to move the file to the new Location?.  If you select No, the files will be searched in the new location"), primaryButton: .default(Text("Yes"), action: {
                                self.connector.setLocation(trId: [self.torrent.trId], location: self.newLoc, move: true)
                            }), secondaryButton: .cancel(Text("No"), action: {
                                self.connector.setLocation(trId: [self.torrent.trId], location: self.newLoc, move: false)
                            }))
                        }
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("iconClock")
                            .resizable()
                            .formatPlayIcon(.link)
                        Text("Added : ")
                        Spacer()
                        Text(DateFormatter.formatDate(torrent.dateAdded))
                            .fixedSize()
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("iconClock")
                            .resizable()
                            .formatPlayIcon(.link)
                        Text("Completed: ")
                        Spacer()
                        Text(DateFormatter.formatDate(torrent.dateDone))
                            .fixedSize()
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("iconClock")
                            .resizable()
                            .formatPlayIcon(.link)
                        Text("Last activity: ")
                        Spacer()
                        Text(DateFormatter.formatDate(torrent.activityDate))
                            .fixedSize()
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("iconClock")
                            .resizable()
                            .formatPlayIcon(.link)
                        Text("Created: ")
                        Spacer()
                        Text(DateFormatter.formatDate(torrent.dateCreated))
                            .fixedSize()
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("person")
                            .resizable()
                            .formatPlayIcon(.link)
                        Text("Creator: ")
                        Spacer()
                        Text(torrent.creator)
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("iconLock")
                            .resizable()
                            .formatPlayIcon(.link)
                        
                        Text("Hash: ")
                        Spacer()
                        Text(torrent.hashString)
                            .scaledToFit()
                            .minimumScaleFactor(0.75)
                            .clipped()
                    }
                }
            }
            .groupBoxStyle(InfoGroupBoxStyle(colorScheme: self.colorScheme))
        }
        .font(.body)
        .lineLimit(1)
        .minimumScaleFactor(0.85)
    }
}


struct CompactView: View, Equatable {
    
    static func == (lhs: CompactView, rhs: CompactView) -> Bool {
        lhs.torrent == rhs.torrent
    }
    
    @EnvironmentObject var connector: RPCConnector
    @EnvironmentObject var appState: AppState
    @ObservedObject var torrent: Torrent
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var changeLoc: Bool = false
    @State private var askChangeLoc: Bool = false
    @State private var newLoc: String = ""

    var body: some View {
        ScrollView {
            GroupBox(label: Text("General")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)) {
                VStack(alignment:.leading, spacing: 15) {
                    Group {
                        HStack(alignment: .center, spacing: 15) {
                            Image("iconBadge")
                                .resizable()
                                .formatPlayIcon(.link)
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Name: ")
                                Text(self.torrent.name)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.trailing)
                                    .minimumScaleFactor(0.8)
                            }
                        }
                        HStack(alignment: .center, spacing: 15) {
                            Image("checkmark.seal")
                                .resizable()
                                .formatPlayIcon(.link)
                            Text("Status: ")
                            Spacer()
                            Text(self.torrent.statusString)
                        }
                        HStack(alignment: .center, spacing: 15) {
                            Image("iconPercents")
                                .resizable()
                                .formatPlayIcon(.link)
                            Text("Progress: ")
                            Spacer()
                            Text(String(format: "%03.2f%%",(self.torrent.percentsDone * 100)))
                        }
                        HStack(alignment: .center, spacing: 15) {
                            Image("iconFullSize36x36")
                                .resizable()
                                .formatPlayIcon(.link)
                            Text("Size: ")
                            Spacer()
                            Text(ByteCountFormatter.formatByteCount(self.torrent.totalSize))
                        }
                        HStack(alignment: .center, spacing: 15) {
                            Image("iconFullSize36x36")
                                .resizable()
                                .formatPlayIcon(.link)
                            Text("Have: ")
                            Spacer()
                            Text(ByteCountFormatter.formatByteCount(Int(self.torrent.haveValid)))
                        }
                        HStack(alignment: .center, spacing: 15) {
                            Image("iconTotalDownloaded")
                                .resizable()
                                .formatPlayIcon(.link)
                            Text("Downloaded: ")
                            Spacer()
                            Text(ByteCountFormatter.formatByteCount(self.torrent.downloadedEver))
                        }
                    }
                    Group {
                        HStack(alignment: .center, spacing: 15) {
                            Image("iconTotalUploaded")
                                .resizable()
                                .formatPlayIcon(.link)
                            Text("Uploaded: ")
                            Spacer()
                            Text(ByteCountFormatter.formatByteCount(self.torrent.uploadedEver))
                        }
                        HStack(alignment: .center, spacing: 15) {
                            Image("iconSpeedGuage36x36")
                                .resizable()
                                .formatPlayIcon(.link)
                            Text("Speed: ")
                            Spacer()
                            Text(self.torrent.speedString)
                        }
                        HStack(alignment: .center, spacing: 15) {
                            Image("iconPig")
                                .resizable()
                                .formatPlayIcon(.link)
                            Text("Ratio: ")
                            Spacer()
                            Text(String(format: "%02.2f",(self.torrent.uploadRatio)))
                        }
                        
                        HStack(alignment: .center, spacing: 15) {
                            Image("iconClockPie")
                                .resizable()
                                .formatPlayIcon(.link)
                            Text("Seeding Time: ")
                            Spacer()
                            Text(DateFormatter.formatHoursMinutes(self.torrent.secondsSeeding))
                        }
                        HStack(alignment: .center, spacing: 15) {
                            Image("iconClockPie")
                                .resizable()
                                .formatPlayIcon(.link)
                            Text("Downloading Time: ")
                            Spacer()
                            Text(DateFormatter.formatHoursMinutes(self.torrent.secondsDownloading))
                        }
                    }
                }        
            }
            .groupBoxStyle(InfoGroupBoxStyle(colorScheme: self.colorScheme))
            GroupBox(label: Text("Comment")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)) {
                HStack(alignment: .center, spacing: 15) {
                    Image("iconFile")
                        .resizable()
                        .formatPlayIcon(.link)
                    Text("Comment: ")
                    Spacer()
                    Text(self.torrent.comment)
                }
            }
            .groupBoxStyle(InfoGroupBoxStyle(colorScheme: self.colorScheme))
            GroupBox(label: Text("Individual Settings")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
            ) {
                VStack(alignment: .leading,spacing: 15) {
                    HStack(alignment: .center, spacing: 15) {
                        Image("iconPositionMark36x36")
                            .resizable()
                            .formatPlayIcon(.link)
                        Text("Queue Pos: ")
                            .multilineTextAlignment(.leading)
                        TextField("", value: self.$torrent.queuePosition, formatter: NumberFormatter(),
                                  onEditingChanged: {_ in },
                                  onCommit: {
                                    var json = JSONObject()
                                    json[JSONKeys.queuePosition] = self.torrent.queuePosition
                                    self.connector.setFields(json, forTorrents: [self.torrent.trId])
                                  })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                        Stepper(value: self.$torrent.queuePosition, onEditingChanged: {_ in
                            var json = JSONObject()
                            json[JSONKeys.queuePosition] = self.torrent.queuePosition
                            self.connector.setFields(json, forTorrents: [self.torrent.trId])
                        }) {
                            Text("")
                        }.frame(width:80)
                        .fixedSize()
                        .padding(.trailing, 10)
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("iconScale36x36")
                            .resizable()
                            .formatPlayIcon(.link)
                        Text("Bandwidth Priority: ")
                        Spacer()
                        Picker("", selection: self.$torrent.bandwidthPriority) {
                                Text("L").tag(-1)
                                Text("N").tag(0)
                                Text("H").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .fixedSize()
                        .onChange(of: self.torrent.bandwidthPriority, perform: {value in
                            var json = JSONObject()
                            json[JSONKeys.bandwidthPriority] = value
                            self.connector.setFields(json, forTorrents: [self.torrent.trId])
                        })
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("iconUploadRateLimit20x20")
                            .resizable()
                            .formatPlayIcon(.link)
                        Toggle("Upload Limit (Kb/s): ", isOn: self.$torrent.uploadLimited)
                            .onChange(of: self.torrent.uploadLimited) { value in
                                var json = JSONObject()
                                json[JSONKeys.uploadLimited] = value
                                self.connector.setFields(json, forTorrents: [self.torrent.trId])
                            }
                        TextField("1234", value: self.$torrent.uploadLimit, formatter: NumberFormatter(),
                                  onEditingChanged: {_ in },
                                  onCommit: {
                                    var json = JSONObject()
                                    json[JSONKeys.uploadLimit] = self.torrent.uploadLimit
                                    self.connector.setFields(json, forTorrents: [self.torrent.trId])
                                  })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                            .frame(width:70)
                            .disabled(!self.torrent.uploadLimited)
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("iconDownloadRateLimit20x20")
                            .resizable()
                            .formatPlayIcon(.link)
                        Toggle("Download Limit (Kb/s): ", isOn: self.$torrent.downloadLimited)
                            .onChange(of: self.torrent.downloadLimited) { value in
                                var json = JSONObject()
                                json[JSONKeys.downloadLimited] = value
                                self.connector.setFields(json, forTorrents: [self.torrent.trId])
                            }
                        TextField("1234", value: self.$torrent.downloadLimit, formatter: NumberFormatter(),
                                  onEditingChanged: {_ in },
                                  onCommit: {
                                    var json = JSONObject()
                                    json[JSONKeys.downloadLimit] = self.torrent.downloadLimit
                                    self.connector.setFields(json, forTorrents: [self.torrent.trId])
                                    
                                  })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                            .frame(width:70)
                            .disabled(!self.torrent.downloadLimited)
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("iconPig")
                            .resizable()
                            .formatPlayIcon(.link)
                        Text("Seed Ratio Limit: ")
                        Picker("", selection: self.$torrent.seedRatioMode) {
                            Text("G").tag(0)
                            Text("L").tag(1)
                            Text("U").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .fixedSize()
                        .onChange(of: self.torrent.seedRatioMode, perform: {value in
                            var json = JSONObject()
                            json[JSONKeys.seedRatioMode] = value
                            self.connector.setFields(json, forTorrents: [self.torrent.trId])
                        })
                        TextField("1234", value: self.$torrent.seedRatioLimit, formatter: { let formatter = NumberFormatter()
                            formatter.numberStyle = .decimal
                            formatter.maximumFractionDigits = 3
                            return formatter
                        }(),
                        onEditingChanged: {_ in },
                        onCommit: {
                            var json = JSONObject()
                            json[JSONKeys.seedRatioLimit] = self.torrent.seedRatioLimit
                            self.connector.setFields(json, forTorrents: [self.torrent.trId])}
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.trailing)
                        .frame(width:60)
                        .disabled(!(torrent.seedRatioMode == 1))
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("iconClockPie")
                            .resizable()
                            .formatPlayIcon(.link)
                        Text("Seed Idle Limit: ")
                        Picker("", selection: self.$torrent.seedIdleMode) {
                            Text("G").tag(0)
                            Text("L").tag(1)
                            Text("U").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .fixedSize()
                        .onChange(of: self.torrent.seedIdleMode, perform: {value in
                            var json = JSONObject()
                            json[JSONKeys.seedIdleMode] = value
                            self.connector.setFields(json, forTorrents: [self.torrent.trId])
                        })
                        TextField("1234", value: self.$torrent.seedIdleLimit, formatter: NumberFormatter(),
                                  onEditingChanged: {_ in },
                                  onCommit: {
                                    var json = JSONObject()
                                    json[JSONKeys.seedIdleLimit] = self.torrent.seedIdleLimit
                                    self.connector.setFields(json, forTorrents: [self.torrent.trId])}
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.trailing)
                        .frame(width:70)
                        .disabled(!(torrent.seedIdleMode == 1))
                    }
                }
            }
            .groupBoxStyle(InfoGroupBoxStyle(colorScheme: self.colorScheme))
            GroupBox(label: Text("Details")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)) {
                VStack(alignment: .leading, spacing: 15) {
                    HStack(alignment: .center, spacing: 15) {
                        Image("transmission")
                            .resizable()
                            .formatPlayIcon(.link)
                        Text("Torrent Id: ")
                        Spacer()
                        Text(String(torrent.trId))
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("folder")
                            .resizable()
                            .formatPlayIcon(.link)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Download Folder: ")
                                .fontWeight(.semibold)
                            HStack {
                                if self.changeLoc {
                                    TextField("Download Location", text: $newLoc, onEditingChanged: { _ in
                                    }, onCommit: {
                                        self.askChangeLoc.toggle()
                                        self.changeLoc.toggle()
                                    })
                                    .padding(.leading)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                } else {
                                    Text(torrent.downloadDir)
                                        .padding(.leading)
                                        .minimumScaleFactor(0.75)
                                }
                                Spacer()
                                Button(action: { self.newLoc = self.torrent.downloadDir
                                        self.changeLoc.toggle() }) {
                                    Image("folder.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .imageScale(.large)
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.blue)
                                }.alert(isPresented: $askChangeLoc) {
                                    Alert(title: Text("Do you want to move the file to the new Location?.  If you select No, the files will be searched in the new location"), primaryButton: .default(Text("Yes"), action: {
                                        self.connector.setLocation(trId: [self.torrent.trId], location: self.newLoc, move: true)
                                    }), secondaryButton: .cancel(Text("No"), action: {
                                        self.connector.setLocation(trId: [self.torrent.trId], location: self.newLoc, move: false)
                                    }))
                                }
                            }
                        }
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("iconClock")
                            .resizable()
                            .formatPlayIcon(.link)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Added : ")
                                .fontWeight(.semibold)
                            Text(DateFormatter.formatDate(torrent.dateAdded))
                                .padding(.leading)
                                .scaledToFill()
                                .minimumScaleFactor(0.95)
                                .clipped()
                        }
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("iconClock")
                            .resizable()
                            .formatPlayIcon(.link)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Completed: ")
                                .fontWeight(.semibold)
                            Text(DateFormatter.formatDate(torrent.dateDone))
                                .padding(.leading)
                                .scaledToFill()
                                .minimumScaleFactor(0.95)
                                .clipped()
                        }
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("iconClock")
                            .resizable()
                            .formatPlayIcon(.link)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Last activity: ")
                                .fontWeight(.semibold)
                            Text(DateFormatter.formatDate(torrent.activityDate))
                                .padding(.leading)
                                .scaledToFill()
                                .minimumScaleFactor(0.95)
                                .clipped()
                        }
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("iconClock")
                            .resizable()
                            .formatPlayIcon(.link)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Created: ")
                                .fontWeight(.semibold)
                            Text(DateFormatter.formatDate(torrent.dateCreated))
                                .padding(.leading)
                                .scaledToFill()
                                .minimumScaleFactor(0.95)
                                .clipped()
                        }
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("person")
                            .resizable()
                            .formatPlayIcon(.link)
                        Text("Creator: ")
                        Spacer()
                        Text(torrent.creator)
                    }
                    HStack(alignment: .center, spacing: 15) {
                        Image("iconLock")
                            .resizable()
                            .formatPlayIcon(.link)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Hash: ")
                                .fontWeight(.semibold)
                            Text(torrent.hashString)
                                .padding(.leading)
                                .minimumScaleFactor(0.75)
                                .lineLimit(2)
                        }
                    }
                }
            }
            .groupBoxStyle(InfoGroupBoxStyle(colorScheme: self.colorScheme))
        }
        .font(.body)
        .minimumScaleFactor(0.85)
        .lineLimit(1)
    }
}
