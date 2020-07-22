//
//  TorrentDetails.swift
//  TransmissionRemoteSwiftUI
//
//  Created by  on 1/30/20.
//

import SwiftUI
import TransmissionRPC

struct TorrentDetails: View {
    
    @Binding var displayDetail: Bool
    
    @State private var tabSelection: Int = 1
    
    @EnvironmentObject var connector: RPCConnector
    @EnvironmentObject var message: Message
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var alertManager: AlertManager
    
    @Environment(\.scenePhase) var scenePhase
    
    @State private var newTracker: String = ""
    @State private var displaySearch: Bool = false
    @State private var displayFileActions: Bool = false
    @State private var displaySort: Bool = false
    
    var navigationBarTitle: String {
        switch self.tabSelection {
        case 1: return "Details"
        case 2: return "Trackers"
        case 3: return "Peers"
        case 4: return "Files"
        case 5: return "Pieces"
        default: return "Details"
        }
    }
    
    init(displayDetail: Binding<Bool>) {
        self._displayDetail = displayDetail
    }
    
    var body: some View {
        
        VStack(alignment:.leading, spacing: 0) {
            VStack(alignment:.leading) {
                Divider()
                Text(self.connector.torrent.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .padding(.horizontal)
                    .minimumScaleFactor(0.75)
                Divider()
            }
            TabView(selection: $tabSelection) {
                TorrentInfo()
                    .tabItem {
                        Text("Info")
                        Image("info")
                    }.tag(1)
                TorrentTrackers()
                    .tabItem {
                        Text("Trackers")
                        Image("trackers")
                    }.tag(2)
                TorrentPeers()
                    .tabItem {
                        Text("Peers")
                        Image("peers")
                    }.tag(3)
                VStack {
                    if displaySearch {
                        SearchBarView(displayed: $displaySearch, perform: self.connector.searchFiles)
                    }
                    TorrentFiles()
                        .id(connector.torrent.trId)
                        .environment(\.editMode, self.$connector.fileEditMode)
                }.tabItem {
                    Text("Files")
                    Image("files")
                }.tag(4)
                TorrentPieces()
                    .tabItem {
                        Text("Pieces")
                        Image("pieces")
                    }.tag(5)
            }.overlay( Group {
                if !self.message.message.isEmpty && !self.appState.detailViewIsDisplayed {
                    MessageView(inTorrentList: false)
                }
            }, alignment: .bottom)
        }
        .navigationBarTitle(self.navigationBarTitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if tabSelection == 1 {
                        Button(action: {
                            self.connector.startTorrent(trId: [self.connector.torrent.trId])
                        }){
                            Image(systemName: "arrowtriangle.right.circle")
                                .formatIcon(self.appState)
                        }
                        
                        Button(action: {
                            self.connector.startNowTorrent(trId: [self.connector.torrent.trId])
                        }){
                            Image(systemName: "arrowtriangle.up.circle")
                                .formatIcon(self.appState)
                        }
                        
                        Button(action: {
                            self.connector.stopTorrent(trId: [self.connector.torrent.trId])
                        }){
                            Image(systemName: "pause.circle")
                                .formatIcon(self.appState)
                        }
                        
                        Button(action: {
                            self.connector.verifyTorrent(trId: [self.connector.torrent.trId])
                        }){
                            Image(systemName: "checkmark.circle")
                                .formatIcon(self.appState)
                        }
                        
                        Button(action: {
                            self.connector.reannounceTorrent(trId: [self.connector.torrent.trId])
                        }){
                            Image(systemName: "arrow.clockwise.circle")
                                .formatIcon(self.appState)
                        }
                    }
                    if self.tabSelection == 4 {
                        if self.connector.fileEditMode.isEditing {
                            Button("Actions") {
                                self.displayFileActions.toggle()
                            }
                            .padding(.leading)
                            .font(self.appState.sizeIsCompact ? .headline : .title2)
                            .actionSheet(isPresented: self.$displayFileActions) {
                                ActionSheet(title: Text("File Actions"), message: Text(""), buttons: [
                                    .default(Text("Download file(s)"), action: {
                                        var rpcIdx = Array<Int>()
                                        for name in Array(self.connector.selectedFiles) {
                                            if let item = self.connector.fsDir.item(withName: name) {
                                                rpcIdx.append(contentsOf: item.rpcIndexes)
                                            }
                                        }
                                        let rpcMessage = [JSONKeys.files_wanted:rpcIdx]
                                        self.connector.setFields(rpcMessage, forTorrents: [self.connector.torrent.trId])
                                        self.connector.selectedFiles = []
                                        self.connector.fileEditMode = .inactive
                                    }),
                                    .default(Text("Not Download files"), action: {
                                        var rpcIdx = Array<Int>()
                                        for name in Array(self.connector.selectedFiles) {
                                            if let item = self.connector.fsDir.item(withName: name) {
                                                rpcIdx.append(contentsOf: item.rpcIndexes)
                                            }
                                        }
                                        let rpcMessage = [JSONKeys.files_unwanted:rpcIdx]
                                        self.connector.setFields(rpcMessage, forTorrents: [self.connector.torrent.trId])
                                        self.connector.selectedFiles = []
                                        self.connector.fileEditMode = .inactive
                                    })
                                    ,.cancel()
                                ])
                            }
                        }
                        
                        Button(action: {
                            if !self.connector.fileEditMode.isEditing  {
                                self.connector.fileEditMode = .active
                            } else {
                                self.connector.fileEditMode = .inactive
                            }
                        }) {
                            Image(systemName: self.connector.fileEditMode.isEditing ? "xmark.circle" : "pencil.circle")
                                .formatIcon(self.appState)
                        }
                        
                        Button(action: {
                            self.displaySearch.toggle()
                        }) {
                            Image(systemName: "magnifyingglass.circle")
                                .formatIcon(self.appState)
                        }
                        
                        Button(action: { self.displaySort.toggle() }) {
                            Image(systemName: "arrow.up.arrow.down.circle")
                                .formatIcon(self.appState)
                        }
                        .popover(isPresented: self.$displaySort, arrowEdge: .top) {
                            TorrentFileSort(fsDir: self.connector.torrent.files)
                                .environmentObject(self.connector)
                        }
                        
                    }
                    if self.tabSelection == 2 {
                        Button(action: {
                            let addAction: AlertTextField.Button = .custom(label: "Add", action: {
                                                                            var fields = JSONObject()
                                                                            fields[JSONKeys.trackerAdd] = [self.newTracker]
                                                                            self.connector.setFields(fields, forTorrents: [self.connector.torrent.trId]) })
                            let alert = AlertTextField(title: Text("Enter announce URL :"), textField: self.$newTracker, buttons: [addAction, .cancel()])
                            self.alertManager.alert = alert
                            self.alertManager.display = true
                        }) {
                            Image(systemName:"antenna.radiowaves.left.and.right")
                                .formatIcon(self.appState)
                        }
                    }
                }
            }
        }
    }
}

struct TorrentDetails_Previews: PreviewProvider {
    
    private static let sema = DispatchSemaphore(value: 0)
    
    @ObservedObject static var connector: RPCConnector = {
        let connector = RPCConnector()
        connector.torrent = torrentsPreview().first!
        return connector
    }()
    
    @ObservedObject static var appState: AppState = {
        let appState = AppState()
        appState.sizeIsCompact = true
        appState.detailViewIsDisplayed = false
        return appState
    }()
    
    
    @State static var displayDetail :Bool = true
    @State static var tab :Int = 1
    
    static var previews: some View {
            TorrentDetails(displayDetail: $displayDetail)
                .environmentObject(self.connector)
                .environmentObject(self.appState)
                .environmentObject(self.connector.message)
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 8 Plus")
                .environment(\.colorScheme, .dark)
                
    }
}
