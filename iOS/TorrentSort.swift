//
//  TorrentSort.swift
//  TransmissionRemoteSwiftUI
//
//  Created by  on 2/11/20.
//

import SwiftUI

struct TorrentSort: View {
    @State private var descendant: Bool = false
    @Environment(\.presentationMode) var presentation
    @ObservedObject var connector: RPCConnector
    
    private var sortOptions = ["Name", "Size","Progress %","Status","Date Added","Date Completed", "ETA","Download Speed", "Upload Speed", "Peers","Seeders","Queue Position"]
    
    init(connector: RPCConnector)
    {
        self.connector = connector
    }
    
    var body: some View {
        List {
            Section(header: Toggle(isOn: $descendant) {
                Text("Descending: ")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.top)
                
            }) {
                ForEach(sortOptions) { option in
                    Button(action: {
                        self.connector.objectWillChange.send()
                        switch (option,self.descendant) {
                            case ("Date Added",false):
                                self.connector.categorization.sortPredicate = { $0.dateAdded! < $1.dateAdded! }
                            case ("Date Added",true):
                                self.connector.categorization.sortPredicate = { $0.dateAdded! > $1.dateAdded! }
                            case ("Date Completed",false):
                                self.connector.categorization.sortPredicate = { $0.dateDone! < $1.dateDone! }
                            case ("Date Completed",true):
                                self.connector.categorization.sortPredicate = { $0.dateDone! > $1.dateDone! }
                            case ("Name",false):
                                self.connector.categorization.sortPredicate = { $0.name < $1.name }
                            case ("Name",true):
                                self.connector.categorization.sortPredicate = { $0.name > $1.name }
                            case ("ETA",false):
                                self.connector.categorization.sortPredicate = { $0.eta < $1.eta }
                            case ("ETA",true):
                                self.connector.categorization.sortPredicate = { $0.eta > $1.eta }
                            case ("Size",false):
                                self.connector.categorization.sortPredicate = { $0.totalSize < $1.totalSize }
                            case ("Size",true):
                                self.connector.categorization.sortPredicate = { $0.totalSize > $1.totalSize }
                            case ("Progress %",false):
                                self.connector.categorization.sortPredicate = { $0.percentsDone < $1.percentsDone }
                            case ("Progress %",true):
                                self.connector.categorization.sortPredicate = { $0.percentsDone > $1.percentsDone }
                            case ("Download Speed",false):
                                self.connector.categorization.sortPredicate = { $0.downloadRate < $1.downloadRate }
                            case ("Download Speed",true):
                                self.connector.categorization.sortPredicate = { $0.downloadRate > $1.downloadRate }
                            case ("Upload Speed",false):
                                self.connector.categorization.sortPredicate = { $0.uploadRate < $1.uploadRate }
                            case ("Upload Speed",true):
                                self.connector.categorization.sortPredicate = { $0.uploadRate > $1.uploadRate }
                            case ("Seeders",false):
                                self.connector.categorization.sortPredicate = { $0.peersGettingFromUs < $1.peersGettingFromUs }
                            case ("Seeders",true):
                                self.connector.categorization.sortPredicate = { $0.peersGettingFromUs > $1.peersGettingFromUs }
                            case ("Peers",false):
                                self.connector.categorization.sortPredicate = { $0.peersSendingToUs < $1.peersSendingToUs }
                            case ("Peers",true):
                                self.connector.categorization.sortPredicate = { $0.peersSendingToUs > $1.peersSendingToUs }
                            case ("Queue Position",false):
                                self.connector.categorization.sortPredicate = { $0.queuePosition < $1.queuePosition }
                            case ("Queue Position",true):
                                self.connector.categorization.sortPredicate = { $0.queuePosition > $1.queuePosition }
                            default:
                            break
                        }
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        Text(option)
                            .foregroundColor(.primary)
                    }

                }.padding([.top, .leading, .bottom])
            }
        }
        .listStyle(GroupedListStyle())
        .frame(width: 250, height: 500)
    }
}

struct TorrentSort_Previews: PreviewProvider {
    private static var connector: RPCConnector = {
        let serverConfig = RPCServerConfig()
        let session: RPCConnector = RPCConnector(serverConfig: serverConfig)
        return session
    }()
    
    static var previews: some View {
        Group {
            TorrentSort(connector: connector)
                .previewDevice(PreviewDevice(rawValue: "iPhone 8 Plus"))
                .environment(\.colorScheme, .dark)
            
            TorrentSort(connector: connector)
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch)"))
                .environment(\.colorScheme, .dark)
        }
    }
}
