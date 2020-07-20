//
//  TorrentRowView.swift
//  TransmissionRemoteSwiftUI
//
//  Created by  on 2/15/20.
//

import SwiftUI
import TransmissionRPC

struct TorrentRowView: View {
    
    @ObservedObject var torrent: Torrent
    @EnvironmentObject var message: Message
    @EnvironmentObject var connector: RPCConnector
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var alertManager: AlertManager
    
    @State private var displayDetail: Bool = false
    @State private var buttonPlayStopDisabled: Bool = false
    
    @State private var newLocation: String = ""
    @Binding var displayAlert: Bool
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    
    var body: some View {
        HStack {
            VStack {
                if self.appState.sizeIsCompact || ( self.appState.detailViewIsDisplayed) {
                    TorrentIcon(torrent: torrent)
                        .equatable()
                        .frame(width: self.appState.isiPhone ? 45 : TrIconPadSlideSize.width , height: self.appState.isiPhone ? 45 : TrIconPadSlideSize.height , alignment: .center)
                } else {
                    TorrentIcon(torrent: torrent)
                        .equatable()
                        .frame(width: TrIconPadSize.width , height:  TrIconPadSize.height , alignment: .center)
                }
                Image(torrent.isStopped || torrent.isFinished ? "Play" : "Stop")
                    .resizable()
                    .foregroundColor(self.buttonPlayStopDisabled ? .gray : .primary)
                    .formatPlayIcon()
                    .onTapGesture {
                        if self.torrent.isStopped || self.torrent.isFinished {
                            self.connector.startTorrent(trId: [self.torrent.trId])
                        } else {
                            self.connector.stopTorrent(trId: [self.torrent.trId])
                        }
                        self.buttonPlayStopDisabled = true
                    }
                    .disabled(self.buttonPlayStopDisabled)
                    .onReceive(self.torrent.$status) { value in
                        if value != self.torrent.status {
                            self.buttonPlayStopDisabled = false
                        }
                    }
            }
            .paddingTorrent(.trailing)
            VStack {
                if self.appState.sizeIsCompact || !self.appState.detailViewIsDisplayed {
                    NavigationLink(destination: TorrentDetails(displayDetail: $displayDetail),isActive: self.$displayDetail) {
                            RowView(torrent: self.torrent)
                    }.clipped()
                } else {
                    Button(action: {
                        self.connector.torrent = self.torrent
                    }) {
                        RowView(torrent: self.torrent)
                    }
                }
            }.onTapGesture {
                self.connector.torrent = self.torrent
                if self.appState.sizeIsCompact || !self.appState.detailViewIsDisplayed {
                    self.displayDetail = true
                }
            }
            .paddingTorrent(.trailing)
        }.contextMenu {
            Group {
                Button(action: { self.connector.startTorrent(trId: [self.torrent.trId]) }) {
                    Label("Start", systemImage: "arrowtriangle.right.circle")
                }
                
                Button(action: { self.connector.startNowTorrent(trId: [self.torrent.trId])
                }) {
                    Label("Start Now", systemImage: "arrowtriangle.up.circle")
                        .opacity(0.8)
                }
                
                Button(action: { self.connector.stopTorrent(trId: [self.torrent.trId])
                }) {
                    Label("Stop", systemImage: "pause.circle")
                }
                
                Button(action: { self.connector.verifyTorrent(trId: [self.torrent.trId])
                }) {
                    Label("Verify", systemImage: "checkmark.circle")
                }
                
                Button(action: { self.connector.reannounceTorrent(trId: [self.torrent.trId])
                }) {
                    Label("Reannounce", systemImage: "arrow.clockwise.circle")
                }
            }
            Group {
                Button(action: {
                    self.newLocation = self.torrent.downloadDir
                    let moveAction: AlertTextField.Button = .custom(label: "Move", action: { self.connector.setLocation(trId:  [self.torrent.trId],location: self.newLocation, move: true) })
            
                    let searchAction: AlertTextField.Button = .custom(label: "Search", action: { self.connector.setLocation(trId:  [self.torrent.trId],location: self.newLocation, move: false) })
                    
                    let alert = AlertTextField(title: Text("Enter New Location:"), textField: self.$newLocation, buttons: [moveAction, searchAction, .cancel()])
                    self.alertManager.alert = alert
                    self.alertManager.display = true
                }) {
                    Label("Change Location", systemImage: "folder")
                }
                
                Button(action: { self.connector.removeTorrent(trId: [self.torrent.trId])
                }) {
                    Label("Remove", systemImage: "trash.circle")
                }
                
                Button(action: { self.connector.removeWithDataTorrent(trId: [self.torrent.trId])
                }) {
                    Label("Remove with Files", systemImage: "trash.circle.fill")
                }
                Button(action: { self.connector.moveTorrent([self.torrent.trId], to: .down)
                }) {
                    Label("Move Up", systemImage: "arrow.up")
                }
                Button(action: { self.connector.moveTorrent([self.torrent.trId], to: .bottom)
                }) {
                    Label("Move to Top", systemImage: "arrow.up.to.line.alt")
                }
                Button(action: { self.connector.moveTorrent([self.torrent.trId], to: .up)
                }) {
                    Label("Move Down", systemImage: "arrow.down")
                }
                Button(action: { self.connector.moveTorrent([self.torrent.trId], to: .top)
                }) {
                    Label("Move to Bottom", systemImage: "arrow.down.to.line.alt")
                }
            }
        }.imageScale(.large)
        .padding()
        .background(self.colorScheme == .light ? Color(.sRGB, white: 0.95, opacity: 0.95) : Color(.sRGB, white: 0.05, opacity: 0.95))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15).stroke(Color.primary.opacity(0.7), lineWidth: 1)
                    )
    }
}


struct RowView: View {
    
    @ObservedObject var torrent: Torrent
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(torrent.name)
                .font(appState.sizeIsCompact || appState.detailViewIsDisplayed ? .callout :  .headline)
                .minimumScaleFactor(0.75)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
            Text(torrent.detailStatus)
                .font(appState.sizeIsCompact || appState.detailViewIsDisplayed ? .caption : .callout)
                .minimumScaleFactor(0.65)
                .foregroundColor(torrent.errorString.count > 0 ? .red : .primary)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
            HStack(alignment: .center) {
                ProgressBar(progress: CGFloat(self.torrent.percentsDone))
                    .frame(height: appState.sizeIsCompact || appState.detailViewIsDisplayed ? 4.0 : 5.0, alignment: .center)
                    .foregroundColor(torrent.statusColor)
                Text(String(format: (torrent.percentsDone * 100).truncatingRemainder(dividingBy: 1) == 0 ? "%.f%%" : "%.1f%%", torrent.percentsDone * 100))
                    .font(appState.sizeIsCompact || appState.detailViewIsDisplayed ? .caption : .callout)
            }.frame(height: appState.sizeIsCompact || appState.detailViewIsDisplayed ? 5.0 : 7.0, alignment: .center)
                .padding(.vertical, 3.0)
            Text(torrent.totalSizeString)
                .font(appState.sizeIsCompact || appState.detailViewIsDisplayed ? .caption : .footnote)
                 .minimumScaleFactor(0.75)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
            HStack(alignment: .center) {
                Text(torrent.peersDetail)
                    .font(appState.sizeIsCompact || appState.detailViewIsDisplayed ? .caption: .footnote)
                     .minimumScaleFactor(0.65)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                Spacer()
                HStack(alignment: .center, spacing: 10.0) {
                    if torrent.uploadLimited {
                        Image("turtleUpload")
                            .resizable()
                            .formatDetailIcon()
                    }
                    if torrent.downloadLimited {
                        Image("turtleDownload")
                            .resizable()
                            .formatDetailIcon()
                    }
                    if torrent.uploadRatio > 1 {
                        Image("pig")
                            .resizable()
                            .formatDetailIcon()
                            .foregroundColor(.systemGreen)
                    }
                    if torrent.bandwidthPriority == 1 {
                        Image("exclamation")
                            .resizable()
                            .formatDetailIcon()
                            .foregroundColor(Color(.yellow))
                    }
                    if torrent.isError  {
                        Image("exclamationmark.octagon")
                            .resizable()
                            .formatDetailIcon()
                            .foregroundColor(.systemRed)
                    }
                }.frame(alignment: .trailing)
            }
        }
    }
}


struct TorrentRowView_Previews: PreviewProvider {
    static var torrent: Torrent = {
        var torrent = Torrent()
        torrent.name = "Este es un Torrent con un largo nombre"
        torrent.downloadRate = 2411724
        torrent.uploadRate = 131072
        torrent.status = .download
        torrent.percentDone = 0.23
        torrent.totalSize = 10240000000
        torrent.peersSendingToUs = 10
        torrent.peersGettingFromUs = 3
        torrent.uploadedEver = 20480
        torrent.downloadedEver = 524288000
        torrent.uploadRatio = 0.1
        torrent.CommonInit()
        return torrent
    }()
    
    @State static var alertMessage: String = ""
    @State static var alertType: MessageType = .info
    @State static var tab: Int = 1
    @State static var displayAlert: Bool = false
    
    static var appState = AppState()
    static var previews: some View {
        Group {
            TorrentRowView(torrent: torrentsPreview().first!, displayAlert: $displayAlert)
                .previewDevice("iPhone 8 Plus")
                .preferredColorScheme(.dark)
                .environmentObject(appState)
                .frame(height: 400, alignment: .center)
                .environment(\.colorScheme, .dark)
                
            
            TorrentRowView(torrent: torrentsPreview()[5], displayAlert: $displayAlert)
            .preferredColorScheme(.dark)
            .environmentObject(appState)
            .frame(height: 400, alignment: .center)
            .device(.dark)
        }
    }
}
