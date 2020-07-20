//
//  TorrentFileSort.swift
//  TransmissionRemoteSwiftUI
//
//  Created by  on 2/10/20.
//

import SwiftUI
import TransmissionRPC

struct TorrentFileSort: View {
    @State private var descendant: Bool = false
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var connector: RPCConnector
    @ObservedObject var fsDir: FSDirectory
    
    init(fsDir: FSDirectory) {
        self.fsDir = fsDir
    }
    
    private var sortOptions = ["Name", "Download Progress","Size","Priority","Selected for Download"]
    
    var body: some View {
        List {
            Text("Sort Files")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.vertical, 7.0)
            Toggle(isOn: $descendant) {
                Text("Descending: ")
                    .font(.headline)
                    .fontWeight(.bold)
            }
                ForEach(sortOptions) { option in
                    Button(action: {

                        switch (option,self.descendant) {
                            case ("Name",false):
                                self.fsDir.sortPredicate = { fileL, fileR in
                                    fileL.name < fileR.name
                            }
                            case ("Name",true):
                                self.fsDir.sortPredicate = { fileL, fileR in
                                    fileL.name > fileR.name
                            }
                            case ("Size",false):
                                self.fsDir.sortPredicate = { fileL, fileR in
                                    fileL.size < fileR.size
                            }
                            case ("Size",true):
                                self.fsDir.sortPredicate = { fileL, fileR in
                                    fileL.size > fileR.size
                            }
                            case ("Download Progress",false):
                                self.fsDir.sortPredicate = { fileL, fileR in
                                    fileL.downloadProgress < fileR.downloadProgress
                            }
                            case ("Download Progress",true):
                                self.fsDir.sortPredicate = { fileL, fileR in
                                    fileL.downloadProgress > fileR.downloadProgress
                            }
                            case ("Priority",false):
                                self.fsDir.sortPredicate = { fileL, fileR in
                                    fileL.priority < fileR.priority
                            }
                            case ("Priority",true):
                                self.fsDir.sortPredicate = { fileL, fileR in
                                    fileL.priority > fileR.priority
                            }
                            case ("Selection",false):
                                self.fsDir.sortPredicate = { fileL, fileR in
                                    ((fileL.isWanted ?? false) ? 1 : 0) < ((fileR.isWanted ?? false) ? 1 : 0)
                            }
                            case ("Selection",true):
                                self.fsDir.sortPredicate = { fileL, fileR in
                                    ((fileL.isWanted ?? false) ? 1 : 0) > ((fileR.isWanted ?? false) ? 1 : 0)
                            }
                            default:
                             break
                        }
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        Text(option)
                            
                    }
                    .padding([.top, .bottom], 8.0)
                    .padding(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                }
        }
        .listStyle(GroupedListStyle())
        .frame(width: 300, height: 450)
    }
}

struct TorrentFileSort_Previews: PreviewProvider {
   
    private static let connector: RPCConnector = {
        let serverConfig = RPCServerConfig()
        let session: RPCConnector = RPCConnector(serverConfig: serverConfig)
        session.connectSession()
        return session
    }()
    
    static var previews: some View {
        TorrentFileSort(fsDir: connector.fsDir)
            .environmentObject(connector)
            .device(.dark)
    }
}

extension String: Identifiable {
    public var id: Int {
        return hashValue
    }
}
