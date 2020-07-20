//
//  TorrentListView.swift
//  Transmission Remote SwiftUI
//
//  Created by  on 1/21/20.
//

import SwiftUI
import UniformTypeIdentifiers
import TransmissionRPC

struct TorrentList: View {
    
    @State private var displayCategories = false
    @State private var displaySearchBar = false
    @State private var displaySort: Bool = false
    @Binding var displayAddTorrent: Bool
    @Binding var displayStats: Bool
    @Binding var displayServers: Bool
    @State private var displayPicker: Bool = false
    @Binding var displaySessionConfig: Bool
    @State private var presentActions: Bool = false
    @Environment(\.importFiles) var importFiles
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @EnvironmentObject var connector: RPCConnector
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var categorization: TorrentCategorization
    @EnvironmentObject var message: Message
    @EnvironmentObject var alertManager: AlertManager
    
    @State private var changeLocationTextField: String = ""
    @State private var displayAlert: Bool = false
    @State private var searchText: String = ""
    @State private var newLocation: String = ""
    
    var body: some View {
        NavigationView {
            ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                VStack(alignment: .center, spacing: 5) {
                    TransferSpeeds(sessionStats: self.connector.sessionStats, sessionConfig: self.connector.sessionConfig)
                        .padding(.horizontal)
                    if self.displaySearchBar {
                        Divider()
                        SearchBarView(displayed: self.$displaySearchBar, perform: self.connector.searchTorrents)
                        Divider()
                    }
                    if self.displayCategories  {
                        CategoriesView()
                            .equatable()
                            .frame(height: self.appState.sizeIsCompact || self.appState.detailViewIsDisplayed ? 75: 90, alignment: .center)
                            .transition(.slide).animation(.linear)
                    }
                    List(selection: self.$connector.selectedTorrents) {
                        ForEach(self.connector.categorization.itemsForSelectedCategory, id: \.trId) { torrent in
                            TorrentRowView(torrent: torrent, displayAlert: $displayAlert)
                        }
                        .onDelete(perform: {index in
                            if  let index = index.first {
                                let torrent = self.connector.categorization.itemsForSelectedCategory[index]
                                self.connector.removeTorrent(trId: [torrent.trId])
                            }
                        }).onMove { sourceIndexes, destIndex in
                            var trIds = [TrId]()
                            var destPos: Int?
                            for index in sourceIndexes {
                                trIds.append(self.connector.categorization.itemsForSelectedCategory[index].trId)
                            }
                            if sourceIndexes.first! < destIndex {
                                destPos = self.categorization.itemsForSelectedCategory[destIndex - 1].queuePosition
                            } else {
                                destPos = self.categorization.itemsForSelectedCategory[destIndex].queuePosition
                            }
                            self.connector.categorization.moveItems(from: sourceIndexes, to: destIndex)
                            if destPos != nil {
                                let jsonMsg = [JSONKeys.queuePosition: destPos!]
                                self.connector.setFields(jsonMsg, forTorrents: trIds)
                            }
                        }
                    }
                }
                .environment(\.editMode, self.$connector.editMode)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(alignment: .center, spacing: 15) {
                            if self.connector.editMode.isEditing {
                                Button(action: {self.presentActions.toggle() }) {
                                    Text("Actions")
                                        .font(.title2)
                                }.actionSheet(isPresented: self.$presentActions) {
                                    ActionSheet(title: Text("Actions"), message: Text("Select the action to apply to all selected Torrents"), buttons: [
                                        .default(Text("Start"), action: {
                                            self.connector.startTorrent(trId: Array(self.connector.selectedTorrents))
                                            self.connector.selectedTorrents = []
                                            self.connector.editMode = .inactive
                                        }),
                                        .default(Text("Start Now"), action: {
                                            self.connector.startNowTorrent(trId: Array(self.connector.selectedTorrents))
                                            self.connector.selectedTorrents = []
                                            self.connector.editMode = .inactive
                                        }),
                                        .default(Text("Stop"), action: {
                                            self.connector.stopTorrent(trId: Array(self.connector.selectedTorrents))
                                            self.connector.selectedTorrents = []
                                            self.connector.editMode = .inactive
                                        }),
                                        .default(Text("Verify"), action: {
                                            self.connector.verifyTorrent(trId: Array(self.connector.selectedTorrents))
                                            self.connector.selectedTorrents = []
                                            self.connector.editMode = .inactive
                                        }),
                                        .default(Text("Reannounce"), action: {
                                            self.connector.reannounceTorrent(trId: Array(self.connector.selectedTorrents))
                                            self.connector.selectedTorrents = []
                                            self.connector.editMode = .inactive
                                        }),
                                        .default(Text("Change Location"), action: {
                                            let moveAction: AlertTextField.Button = .custom(label: "Move", action: { self.connector.setLocation(trId:  Array(self.connector.selectedTorrents),location: self.newLocation, move: true) })
                                            
                                            let searchAction: AlertTextField.Button = .custom(label: "Search", action: { self.connector.setLocation(trId:  Array(self.connector.selectedTorrents),location: self.newLocation, move: false) })
                                            
                                            let alert = AlertTextField(title: Text("Enter New Location:"), textField: self.$newLocation, buttons: [moveAction, searchAction, .cancel()])
                                            self.alertManager.alert = alert
                                            self.alertManager.display = true
                                            self.connector.selectedTorrents = []
                                            self.connector.editMode = .inactive
                                        }),
                                        .default(Text("Remove"), action: {
                                            self.connector.removeTorrent(trId: Array(self.connector.selectedTorrents))
                                            self.connector.selectedTorrents = []
                                            self.connector.editMode = .inactive
                                        }),
                                        .default(Text("Remove with Files"), action: {
                                            self.connector.removeWithDataTorrent(trId: Array(self.connector.selectedTorrents))
                                            self.connector.selectedTorrents = []
                                            self.connector.editMode = .inactive
                                        }),
                                        .default(Text("Move Up"), action: {
                                            self.connector.moveTorrent(Array(self.connector.selectedTorrents),to: .down)
                                            self.connector.selectedTorrents = []
                                            self.connector.editMode = .inactive
                                        }),
                                        .default(Text("Move Down"), action: {
                                            self.connector.moveTorrent(Array(self.connector.selectedTorrents),to: .up)
                                            self.connector.selectedTorrents = []
                                            self.connector.editMode = .inactive
                                        }),
                                        .default(Text("Move to Top"), action: {
                                            self.connector.moveTorrent(Array(self.connector.selectedTorrents),to: .bottom)
                                            self.connector.selectedTorrents = []
                                            self.connector.editMode = .inactive
                                        }),
                                        .default(Text("Move to Bottom"), action: {
                                            self.connector.moveTorrent(Array(self.connector.selectedTorrents),to: .top)
                                            self.connector.selectedTorrents = []
                                            self.connector.editMode = .inactive
                                        }),
                                        .cancel()
                                    ])
                                }
                            }
                            Button(action: { self.displayStats.toggle() }) {
                                Image(systemName: "chart.pie")
                                    .formatIcon(self.appState)
                                    .popover(isPresented: self.$displayStats) {
                                        SessionStatsView()
                                            .environmentObject(self.connector.sessionStats)
                                            .environmentObject(self.appState)
                                    }
                            }
                            if !self.appState.sizeIsCompact {
                                Button(action: {
                                    withAnimation {
                                        self.appState.detailViewIsDisplayed.toggle()
                                    }
                                }) {
                                    Image(systemName: "sidebar.left")
                                        .resizable()
                                        .imageScale(.large)
                                        .scaledToFit()
                                        .frame(width: 35, height: 35, alignment: .center)
                                        .foregroundColor(self.appState.detailViewIsDisplayed ? .blue : .tertiaryLabel)
                                        .scaleEffect(1.2)
                                }
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            Button(action: {self.displayServers = true }) {
                                Image(systemName: "rectangle.connected.to.line.below")
                                    .formatIcon(self.appState)
                                //.scaleEffect(0.9)
                            }
                            if !self.appState.sizeIsCompact || self.appState.isiPhone {
                                Button(action: { self.displaySessionConfig = true }) {
                                    Image(systemName: "gearshape")
                                        .formatIcon(self.appState)
                                }
                            }
                            
                        }
                    }
                    
                }
                HStack(alignment:.center, spacing: 20) {
                    Spacer()
                    Button(action: {
                        self.importFiles(singleOfType: [.torrent, .fileURL,.text, .data,.content,.plainText]) { result in
                            switch result {
                            case .success(let file):
                                do {
                                    RPCConnector.shared.torrentFile = try TorrentFile(fileURL: file)
                                    RPCConnector.shared.message = self.message
                                    self.displayAddTorrent = true
                                } catch {
                                    self.message.type = .error
                                    self.message.message = error.localizedDescription
                                }
                            case .failure(let error):
                                print(error.localizedDescription)
                            case .none:
                                break
                            }
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .formatIcon(self.appState)
                    }
                    Button(action: { if !self.connector.editMode.isEditing {
                        self.connector.editMode = .active
                    }
                    else {
                        self.connector.selectedTorrents = []
                        self.connector.editMode = .inactive
                    }
                    })  {
                        
                        Image(systemName: self.connector.editMode.isEditing ? "xmark.circle.fill" : "pencil.circle.fill")
                            .formatIcon(self.appState)
                    }
                    
                    
                    Button(action: { self.connector.startTorrent() }) {
                        Image(systemName: "play.circle.fill")
                            .formatIcon(self.appState)
                    }
                    
                    Button(action: { self.connector.stopTorrent() }) {
                        Image(systemName: "pause.circle.fill")
                            .formatIcon(self.appState)
                    }
                    
                    Button(action: {
                        self.displaySort.toggle()
                    }) {
                        Image(systemName: "arrow.up.arrow.down.circle.fill")
                            .formatIcon(self.appState)
                    }.popover(isPresented: self.$displaySort, arrowEdge: .bottom) {
                        TorrentSort(connector: self.connector)
                    }
                    
                    Button(action: { self.displaySearchBar.toggle() }) {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .formatIcon(self.appState)
                    }
                    
                    Button(action: {
                        withAnimation { self.displayCategories.toggle() }
                    }) {
                        Image(systemName: "line.horizontal.3.decrease.circle.fill")
                            .formatIcon(self.appState)
                    }
                    Spacer()
                }
                .padding(.vertical, 10.0)
                .padding(.horizontal)
                .background(Color(.sRGB, white: self.colorScheme == .light ? 0.98 : 0.1, opacity: 1))
                .opacity(0.98)
            }
            .edgesIgnoringSafeArea(.bottom)
            .overlay( Group {
                if !self.message.message.isEmpty {
                    MessageView(inTorrentList: true)
                }
            }, alignment: .bottom)
            .blur(radius: self.displaySort || self.presentActions ? 3.0 : 0.0)
            .navigationBarTitle("Torrents")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


struct TorrentList_Previews: PreviewProvider {
    
    @ObservedObject static var connector: RPCConnector = {
        let connector = RPCConnector()
        let torrents = torrentsPreview()
        connector.categorization.setItems(torrents)
        return connector
    }()
    @State static var displayServers: Bool = false
    @State static var displayStats: Bool = false
    @State static var displaySession: Bool = false
    @State static var displayAddTorrent: Bool = false
    @State static var tab: Int = 1
    
    static let appState: AppState = {
        let appState = AppState()
        appState.isiPhone = true
        appState.sizeIsCompact = true
        appState.detailViewIsDisplayed = false
        appState.isLandscape = false
        return appState
    }()
    
    static let appStateLarge: AppState = {
        let appState = AppState()
        appState.isiPhone = false
        appState.sizeIsCompact = false
        appState.detailViewIsDisplayed = false
        appState.isLandscape = false
        return appState
    }()
    
    static var previews: some View {
        Group {
            TorrentList(displayAddTorrent: self.$displayAddTorrent, displayStats: $displayStats, displayServers: $displayServers, displaySessionConfig: $displaySession)
                .environmentObject(connector)
                .environmentObject(connector.categorization)
                .environmentObject(appState)
                .environmentObject(connector.message)
                .environment(\.editMode, $connector.editMode)
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 11 Pro Max")
                .environment(\.colorScheme, .dark)
            
            TorrentList(displayAddTorrent: self.$displayAddTorrent, displayStats: $displayStats, displayServers: $displayServers, displaySessionConfig: $displaySession)
                .environmentObject(connector)
                .environmentObject(connector.categorization)
                .environmentObject(appStateLarge    )
                .environmentObject(connector.message)
                .environment(\.editMode, $connector.editMode)
                .preferredColorScheme(.dark)
                .previewDevice("iPad Pro (10.5-inch)")
                .environment(\.colorScheme, .dark)
        }
        
    }
}


#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit
#endif

let iconSize: CGSize = {
    #if os(iOS) || targetEnvironment(macCatalyst)
    if UIDevice.current.userInterfaceIdiom == .pad {
        if AppState.current.sizeIsCompact {
            return CGSize(width: 40, height: 40)
        } else {
            return CGSize(width: 60, height: 60)
        }
    } else {
        return CGSize(width: 50, height: 50)
    }
    #else
    return CGSize(width: 60, height: 60)
    #endif
}()

let filterHeight: CGFloat = {
    #if os(iOS) || targetEnvironment(macCatalyst)
    if UIDevice.current.userInterfaceIdiom == .pad {
        if AppState.current.sizeIsCompact {
            return 75.0
        } else {
            return 90.0
        }
    } else {
        return 80.0
    }
    #else
    return 90
    #endif
}()

let halfCloudSize: CGFloat = {
    #if os(iOS) || targetEnvironment(macCatalyst)
    if UIDevice.current.userInterfaceIdiom == .pad {
        return 60.0
    } else {
        return 40.0
    }
    #else
    return 60
    #endif
}()

let halfCloudHeight: CGFloat = {
    #if os(iOS) || targetEnvironment(macCatalyst)
    if UIDevice.current.userInterfaceIdiom == .pad {
        return 60.0
    } else {
        return 45.0
    }
    #else
    return 60
    #endif
}()

