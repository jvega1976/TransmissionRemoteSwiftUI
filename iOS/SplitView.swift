//
//  SplitView.swift
//  
//
//  Created by  on 2/16/20.
//

import SwiftUI
import TransmissionRPC

struct SplitView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var connector: RPCConnector
    @State private var displayServers: Bool = false
    @State private var displayStats: Bool = false
    @State private var displayDetail: Bool = false
    @State private var displayAddTorrent: Bool = false
    @State private var displaySessionConfig: Bool = false
    @State private var appRestarting: Bool = false
    @EnvironmentObject var alertManager: AlertManager
    
    var body: some View {        
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                    HStack(alignment: .center) {
                        TorrentList(displayAddTorrent: self.$displayAddTorrent, displayStats: self.$displayStats, displayServers: self.$displayServers, displaySessionConfig: self.$displaySessionConfig)
                            .environmentObject(self.connector.message)
                            .environmentObject(self.connector.categorization)
                            .environment(\.editMode, self.$connector.editMode)
                            .frame(width: !self.appState.sizeIsCompact && self.appState.detailViewIsDisplayed ? geometry.size.width/2.5 : geometry.size.width, height: geometry.size.height, alignment: .center)
                        Divider()
                        if !self.connector.categorization.itemsForSelectedCategory.isEmpty && !self.appState.sizeIsCompact && self.appState.detailViewIsDisplayed {
                            NavigationView {
                                TorrentDetails(displayDetail: self.$displayDetail)
                                    .environmentObject(self.connector.message)
                            }
                            .transition(.move(edge: .trailing))
                            .frame(width: geometry.size.width - (geometry.size.width/2.5) - 25, height: geometry.size.height , alignment: .leading)
                            .navigationViewStyle(StackNavigationViewStyle())
                        }
                    }.overlay( Group {
                        if self.alertManager.display {
                            AlertView(isPresented: self.$alertManager.display, alert: self.alertManager.alert)
                                .frame(width: self.appState.sizeIsCompact ? geometry.size.width * 0.9 :  geometry.size.width * (self.appState.isLandscape ? 0.5 : 0.6), alignment: .center)
                        }
                    }, alignment: .center)
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
                    .blur(radius: self.displayServers || self.displaySessionConfig || self.displayStats ? 5 : 0)
                if self.displayServers {
                    ServerConfigList(displayServers: self.$displayServers)
                        .formatServerConfig(width: geometry.size.width, height: geometry.size.height, appState: self.appState, colorScheme: self.colorScheme)
                        .zIndex(1)
                }
                if self.displayAddTorrent {
                    AddTorrent(displayView: self.$displayAddTorrent)
                        .environmentObject(RPCConnector.shared)
                        .frame(width: self.appState.sizeIsCompact ?  geometry.size.width/1.1 : geometry.size.width/1.4, height: self.appState.sizeIsCompact ? geometry.size.height/1.2 : geometry.size.height/1.4, alignment: .center)
                        .gesture(DragGesture().onEnded {
                            if $0.translation.width < -100 {
                                withAnimation { self.displayAddTorrent = false }
                            }
                        }).zIndex(1)
                }
                if self.displaySessionConfig {
                    SessionConfigView(displaySessionConfig: self.$displaySessionConfig)
                        .environmentObject(self.connector.sessionConfig)
                        .environmentObject(self.connector.message)
                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))).animation(.linear(duration: 0.5))
                        .frame(width: self.appState.sizeIsCompact ? geometry.size.width/1.1 : geometry.size.width/1.2, height: self.appState.sizeIsCompact ? geometry.size.height/1.1 :  geometry.size.height/1.2 , alignment: .center)
                        .gesture(DragGesture().onEnded {
                            if $0.translation.width < -100 {
                                self.displaySessionConfig = false
                            }
                        }).zIndex(1)
                }
            }
            .onAppear {
                if ServerConfigDB.shared.defaultConfig == nil {
                    self.displayServers.toggle()
                    return
                }
            }.onChange(of: verticalSizeClass) { value in
                self.appState.verticalSizeClass = value
            }
            .onChange(of: scenePhase) { phase in
                switch(phase) {
                    case .background:
                        self.connector.scheduleAppRefresh(.notify)
                        self.connector.scheduleAppRefresh(.updateData)
                    case .inactive:
                        self.connector.disconnectSesssion()
                        if self.appRestarting {
                            self.connector.cancelAppRefresh()
                            self.connector.reconnectSession()
                        }
                        self.appRestarting.toggle()
                    case .active:
                        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                        UIApplication.shared.applicationIconBadgeNumber = 0
                        self.appState.horizontalSizeClass = self.horizontalSizeClass
                        self.appState.verticalSizeClass = self.verticalSizeClass
                    @unknown default:
                        break
                }
            }.onOpenURL { file in
                do {
                    let torrentFile = try TorrentFile(fileURL: file)
                    RPCConnector.shared.torrentFile = torrentFile
                    RPCConnector.shared.message = self.connector.message
                    self.displayAddTorrent = true
                } catch {
                    self.connector.message.type = .error
                    self.connector.message.message = error.localizedDescription
                }
            }
        }
    }
}


struct SplitView_Previews: PreviewProvider {

    static let appState: AppState = {
        let appState = AppState()
        appState.sizeIsCompact = true
        appState.isLandscape = false
        //appState.detailViewIsDisplayed = true
        return appState
    }()
    
    static var connector: RPCConnector =  {
        let serverConfig = RPCServerConfig()
        let connector = RPCConnector(serverConfig: serverConfig)
        let torrents = torrentsPreview()
        connector.categorization.setItems(torrents)
        connector.firstTime = true
        return connector
    }()
    
    static  var alertManager: AlertManager = AlertManager()

    static var previews: some View {
        SplitView()
            .previewDevice("iPhone 8 Plus")
            .preferredColorScheme(.dark)
            .environment(\.colorScheme, .dark)
            .environmentObject(connector)
            .environmentObject(appState)
            .environmentObject(connector.categorization)
            .environmentObject(alertManager)
    }
}
