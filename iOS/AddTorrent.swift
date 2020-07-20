//
//  AddTorrent.swift
//  TransmissionRemoteSwiftUI
//
//  Created by  on 2/18/20.
//

import SwiftUI
import TransmissionRPC


struct AddTorrent: View {
    @State private var selectedServer: RPCServerConfig? = ServerConfigDB.shared.defaultConfig
    @State private var bandwidthPriority: Int = 0
    @State private var startTorrent: Bool = true
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var connector: RPCConnector
    @Environment(\.colorScheme) var colorScheme
    @Binding var displayView: Bool
    @State var editMode: EditMode = .inactive
    
    var body: some View {
        
        GeometryReader { geometry in
            NavigationView {
                VStack(alignment: .leading, spacing: 20) {
                    List {
                        HStack(alignment: .center, spacing: 15) {
                            Image("transmission")
                                .resizable()
                                .formatPlayIcon(.blue)
                            Text(self.connector.torrentFile?.name ?? "")
                                .font(self.appState.sizeIsCompact ? .subheadline : .title)
                                .minimumScaleFactor(0.60)
                                .opacity(0.8)
                        }.padding(.top).padding([.leading,.bottom], self.appState.sizeIsCompact ? 1 : nil)
                        Section(header: Text("Servers")) {
                            ForEach(ServerConfigDB.shared.db) {serverConfig in
                                Button(action: {  self.selectedServer = serverConfig }) {
                                    ServerConfigRow(serverConfig: serverConfig, selectedServer: self.$selectedServer)
                                        .padding(.horizontal, self.appState.sizeIsCompact ? 1 : nil)
                                }
                            }
                        }
                        Section(header: Text("Options")) {
                            VStack(alignment: .leading) {
                                if self.appState.sizeIsCompact {
                                    Text("Bandwith Priority:")
                                        .font(.footnote)
                                }
                                HStack {
                                    Image("iconScale36x36")
                                        .resizable()
                                        .formatPlayIcon(.blue)
                                    if !self.appState.sizeIsCompact {
                                        Text("Bandwith Priority")
                                            .padding(.leading)
                                    }
                                    Spacer()
                                    Picker("Bandwith Priority", selection: self.$bandwidthPriority) {
                                        Text( self.appState.sizeIsCompact ? "L" : "Low").tag(-1)
                                        Text( self.appState.sizeIsCompact ? "N" : "Normal").tag(0)
                                        Text( self.appState.sizeIsCompact ? "H" : "High").tag(1)
                                    }.pickerStyle(SegmentedPickerStyle())
                                        .frame(width: self.appState.sizeIsCompact ? 100 : 300)
                                }
                                .padding(.all,self.appState.sizeIsCompact ? 1 : nil)
                            }
                            HStack {
                                Image("iconRunningMan36x36")
                                    .resizable()
                                    .formatPlayIcon(.blue)
                                Toggle(isOn: self.$startTorrent, label: {
                                    Text("Start Torrent:")
                                        .font(self.appState.sizeIsCompact ? .footnote : .body)
                                })
                                    .padding(.leading, self.appState.sizeIsCompact ? 1 : nil)
                            }
                            .padding(.all, self.appState.sizeIsCompact ? 1 : nil)
                        }
                        Section(header: Text("Files")) {
                            NavigationLink(destination: FilesView()) {
                                HStack {
                                    Image("files")
                                        .resizable()
                                        .formatPlayIcon(.blue)
                                    Text("Select files to download")
                                        .font(self.appState.sizeIsCompact ? .footnote : .body)
                                        .padding(.leading)
                                }
                            }
                            .padding(.all, self.appState.sizeIsCompact ? 1 : nil)
                        }
                        Section(header: Text("Trackers")) {
                            ForEach(self.connector.torrentFile?.trackerList ?? []) { tracker in
                                HStack {
                                    Image("trackers")
                                        .resizable()
                                        .formatPlayIcon(.blue)
                                    Text(tracker)
                                        .font(self.appState.sizeIsCompact ? .footnote : .body)
                                        .padding(.leading)
                                }
                                .padding(.leading, self.appState.sizeIsCompact ? 1 : nil)
                            }
                        }
                    }
                }
                .navigationBarItems(trailing: HStack(spacing: 20) {
                    Button(action: {
                        self.displayView = false
                    }) {
                        Text("Cancel")
                            .font(.headline)
                    }
                    Button(action: {
                        if let serverConfig = self.selectedServer {
                            self.connector.serverConfig = serverConfig
                            self.connector.addTorrent(withBandwithPriority: self.bandwidthPriority, addPaused: !self.startTorrent)
                            self.displayView = false
                        }
                        self.displayView = false
                    }) {
                        Text("Add")
                            .font(.headline)
                    }
                })
                    .navigationBarTitle("", displayMode: .inline)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .cornerRadius(25)
            .shadow(color: Color(.sRGB, white: self.colorScheme == .light ? 0 : 1 , opacity: 0.33), radius: 10)
            .opacity(0.97)
            .transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .bottom))).animation(.linear)
        }
    }
}





struct AddTorrent_Previews: PreviewProvider {
    @State  static var connector: RPCConnector = {
        let connector = RPCConnector()
        connector.torrentFile = try? TorrentFile(fileURL: URL(fileURLWithPath: "/Users/jvega/Downloads/OnlyFans - Alam Wernick.torrent"))
        connector.fsDir = connector.torrentFile!.fileList
        for item in connector.fsDir.rootItem.items ?? [] {
            item.parent = nil
        }
        return connector
        
    }()
    static let appState: AppState = AppState()
    @State static var displayView: Bool = true

    static var previews: some View {
        AddTorrent(displayView: $displayView).environmentObject(appState).environmentObject(RPCConnector.shared)
            .device()
    }
}



struct ServerConfigRow: View {
    @State private var isEditing: Bool = false
    @ObservedObject var serverConfig: RPCServerConfig
    @Binding var selectedServer: RPCServerConfig?
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack {
            ServerConfig(serverConfig: serverConfig, isEditing: self.$isEditing)
            Spacer()
            if self.selectedServer == self.serverConfig {
                Image("checkmark")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.blue)
                    .frame(width: self.appState.sizeIsCompact ? 18 : 25, height: self.appState.sizeIsCompact ? 18 : 25, alignment: .center)
            }
        }
        .padding([.top, .bottom, .trailing])
    }
}

struct FilesView: View {
    @State private var displaySearch: Bool = false
    @State private var displaySort: Bool = false
    @EnvironmentObject var connector: RPCConnector
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            if displaySearch {
                SearchBarView(displayed: self.$displaySearch, perform: self.connector.searchFiles)
            }
            TorrentFiles(haveToRefresh: false)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
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
                            TorrentFileSort(fsDir: connector.fsDir)
                                .environmentObject(self.connector)
                    }
                }
            }
        }
    }
}
