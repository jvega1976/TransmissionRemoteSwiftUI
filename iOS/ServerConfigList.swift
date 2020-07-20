//
//  ContentView.swift
//  Transmission Remote SwiftUI
//
//  Created by  on 1/20/20.
//

import SwiftUI

struct ServerConfigList: View {
    @EnvironmentObject var connector: RPCConnector
    @EnvironmentObject var appState: AppState
    @ObservedObject var serverConfigDB: ServerConfigDB = ServerConfigDB.shared
    @State var isEditing: Bool = false
    @Binding var displayServers: Bool
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        NavigationView {
            List{
                ForEach(serverConfigDB.db) { serverConfig in
                    if self.isEditing {
                        NavigationLink(destination: AddServerConfig(serverConfig: serverConfig, isEditing: self.$isEditing)
                        ) {
                            ServerConfig(serverConfig: serverConfig, isEditing: self.$isEditing)
                                .padding(10.0)
                        }
                    } else {
                        Button(action: {
                            self.connector.connectSession(serverConfig: serverConfig)
                            self.displayServers.toggle()
                        }) {
                            ServerConfig(serverConfig: serverConfig, isEditing: self.$isEditing)
                                .padding(10.0)
                        }
                    }
                }
            }
            .navigationBarItems(leading: HStack {
                if self.isEditing {
                    NavigationLink(destination: AddServerConfig(serverConfig: RPCServerConfig(), isEditing: self.$isEditing)) {
                        Image(systemName: "plus")
                            .resizable()
                            .imageScale(.large)
                            .scaledToFit()
                            .frame(width:self.appState.sizeIsCompact ? 20 : 22, height: self.appState.sizeIsCompact ? 20 : 22, alignment: .trailing)
                            .padding(.leading)
                    }
                }
            }, trailing:
                HStack(alignment: .center, spacing: 20) {
                    Button(self.isEditing ? "Done" : "Edit") {
                        self.isEditing.toggle()
                    }
                    Button("Cancel") {
                        self.displayServers.toggle()
                    }
                }
                .font(self.appState.sizeIsCompact ? .body : .title2)
            )
            .navigationBarTitle(Text("Servers"))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .gesture(DragGesture().onEnded {
            if $0.translation.width < -100 {
                withAnimation { self.displayServers = false }
            }
        })
    }
}


struct ServerConfigList_Previews: PreviewProvider {
    @State static var displayServers: Bool = true
    static var connector = RPCConnector(serverConfig: RPCServerConfig())
    static var previews: some View {
        Group {
            ServerConfigList(displayServers: $displayServers)
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 8 Plus")
                .environmentObject(connector)
                .environment(\.colorScheme, .dark)
            ServerConfigList(displayServers: $displayServers)
                .preferredColorScheme(.dark)
                .previewDevice("iPad Pro (10.5-inch)")
                .environmentObject(connector)
                .environment(\.colorScheme, .dark)
        }
    }
}
