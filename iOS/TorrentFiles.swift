//
//  TorrentFiles.swift
//  TransmissionRemoteSwiftUI
//
//  Created by  on 2/7/20.
//

import SwiftUI
import TransmissionRPC

struct TorrentFiles: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var connector: RPCConnector
    
    var haveToRefresh: Bool = true
    
    var body: some View {
        VStack {
            if haveToRefresh {
                List(connector.torrent.files.rootItem.items ?? [], children: \.items, selection: self.$connector.selectedFiles) {item in
                    FileRowView(item: item, haveToRefresh: self.haveToRefresh)
                }
            } else {
                List(connector.fsDir.rootItem.items ?? [], children: \.items, selection: self.$connector.selectedFiles) {item in
                    FileRowView(item: item, haveToRefresh: self.haveToRefresh)
                }
            }
        }.environment(\.editMode, self.$connector.fileEditMode)
    }
}

struct TorrentFiles_Previews: PreviewProvider {
    
    @ObservedObject static var connector: RPCConnector = {
        let connector: RPCConnector = RPCConnector(serverConfig: RPCServerConfig())
        connector.session = try? RPCSession(withURL: connector.serverConfig!.configURL!, andTimeout: connector.serverConfig!.requestTimeout)
        connector.torrent.trId = 40
        connector.getFiles()
        return connector
    }()
    
    static var appState: AppState = {
        let appState = AppState()
        appState.sizeIsCompact = false
        appState.detailViewIsDisplayed = false
        return appState
    }()
    
    static var appStateCompact: AppState = {
        let appState = AppState()
        appState.sizeIsCompact = true
        appState.detailViewIsDisplayed = false
        return appState
    }()
    
    @State static var editMode: EditMode = .inactive
    @State static var display: Bool = true
    
    static var previews: some View {
        Group {
            TorrentFiles()
                .environmentObject(connector)
                .environmentObject(appStateCompact)
                .environment(\.editMode, $connector.fileEditMode)
                .previewDevice(PreviewDevice(stringLiteral: "iPhone 8 Plus"))
            //.environment(\.colorScheme, .dark)
            
            TorrentFiles()
                .environmentObject(connector)
                .environmentObject(appState)
                .environment(\.editMode, self.$connector.fileEditMode)
                .device()
        }
    }
}

struct FileRowView: View, Equatable {
    
    @ObservedObject var item: FSItem
    @EnvironmentObject var connector: RPCConnector
    @EnvironmentObject var appState: AppState
    @State private var isEditing: Bool = false
    @State private var oldName: String = ""
    @State private var displayPriorityOptions: Bool = false
    var haveToRefresh: Bool = true
    @Environment(\.colorScheme) var colorScheme: ColorScheme
   
    
    var body: some View {
        HStack(alignment: .center, spacing: self.appState.sizeIsCompact ? 15 : 20) {
            Group {
                if self.item.isFolder {
                    if let isWanted = self.item.isWanted {
                        if isWanted {
                            Image(systemName: "folder.fill")
                                .formatFilesIcon(appState)
                                .foregroundColor(.blue)
                        } else {
                            Image(systemName: "folder")
                                .formatFilesIcon(appState)
                                .foregroundColor(.secondary)
                                .opacity(0.7)
                        }
                    } else {
                        Image(systemName: "folder.badge.questionmark")
                            .formatFilesIcon(appState)
                            .opacity(0.7)
                    }
                } else {
                    if self.item.isWanted ?? false {
                        Image(systemName: "arrow.down.doc.fill")
                            .formatFilesIcon(appState)
                            .opacity(0.7)
                    } else {
                        Image(systemName: "doc")
                            .formatFilesIcon(appState)
                            .foregroundColor(.secondary)
                            .opacity(0.7)
                    }
                }
            }.onTapGesture {
                if self.haveToRefresh {
                    let rpcIdx = self.item.rpcIndexes
                    let rpcMessage = (self.item.isWanted ?? false) ? [JSONKeys.files_unwanted:rpcIdx] : [JSONKeys.files_wanted:rpcIdx]
                    self.connector.setFields(rpcMessage, forTorrents: [self.connector.torrent.trId])
                } else {                    
                    if self.item.isFolder {
                        let wanted = !(self.item.isWanted ?? false)
                        for item in self.item.items ?? [] {
                            item.isWanted = wanted
                        }
                    } else {
                        self.item.isWanted?.toggle()
                    }
                }
            }
            VStack(alignment: .leading) {
                VStack {
                    if self.isEditing {
                        TextField("Name", text: self.$item.name,  onEditingChanged: {_ in
                                    self.oldName = self.item.name}
                                  , onCommit:  {
                                    if self.oldName != self.item.name {
                                        self.connector.renameFile(self.item.fullName, forFSItem: self.item, usingName: self.item.name)
                                    }
                                    self.isEditing.toggle()
                                  })  .font(self.appState.sizeIsCompact ? .caption : .headline)
                            .background(Color.secondary)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .shadow(color: Color.secondary.opacity(0.7), radius: 10)
                            .minimumScaleFactor(0.8)
                            .multilineTextAlignment(.leading)
                            .disabled(!self.isEditing)
                    }
                    else {
                        Text(self.item.name)
                            .font(self.appState.sizeIsCompact ? .caption : .headline)
                            .minimumScaleFactor(0.8)
                            .multilineTextAlignment(.leading)
                            .disabled(self.isEditing)
                    }
                }
                if self.haveToRefresh {
                    ProgressView(value: item.downloadProgress, total: item.downloadProgress > 1.0 ? item.downloadProgress : 1.0)
                        .foregroundColor(.link)
                        .frame(height: self.appState.sizeIsCompact ? 3 : 5)
                        .progressViewStyle(LinearProgressViewStyle())
                    HStack {
                        Text(item.bytesCompletedString + " of " + item.sizeString)
                            .foregroundColor(.secondaryLabel)
                            .font(self.appState.sizeIsCompact ? .caption2 : .subheadline)
                            .minimumScaleFactor(0.6)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Text(item.downloadProgressString)
                            .font(self.appState.sizeIsCompact ? .caption2 : .subheadline)
                            .multilineTextAlignment(.trailing)
                    }
                    
                } else {
                    Spacer()
                    Text(item.sizeString)
                        .font(self.appState.sizeIsCompact ? .caption2 : .subheadline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.60)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.secondary)
                }
            }.contextMenu /*@START_MENU_TOKEN@*/{
                if self.haveToRefresh {
                    Button(action: { self.isEditing.toggle() }, label: {
                        Label("Rename file...",systemImage:"doc.badge.ellipsis")
                    })
                }
                Button(action: { self.connector.fileEditMode = .active }, label: {
                    Label("Select multiple files...", systemImage: "doc.badge.plus")
                })
            }/*@END_MENU_TOKEN@*/
            
            if self.appState.sizeIsCompact {
                Image("circlePriority")
                    .resizable()
                    .fixedSize()
                    .priorityFormat(self.item.priority)
                    .frame(width: 35, height: 35, alignment: .center)
                    .border(Color.secondaryLabel, width: 1)
                    .onTapGesture {
                        self.displayPriorityOptions.toggle()
                    }
                    .actionSheet(isPresented: self.$displayPriorityOptions) {
                        ActionSheet(title: Text("File Priority"), message: Text("Select download priority"), buttons: [
                            .default(Text(Image(systemName: "l.circle")) + Text(" Low"), action: {
                                self.item.priority = -1
                                let rpcIdx = self.item.rpcIndexes
                                var rpcMessage = JSONObject()
                                rpcMessage[JSONKeys.priority_low] = rpcIdx
                                self.connector.setFields(rpcMessage, forTorrents: [self.connector.torrent.trId])
                            }),
                            .default(Text("Normal ") + Text(Image(systemName: "n.circle")), action: {
                                self.item.priority = 0
                                let rpcIdx = self.item.rpcIndexes
                                var rpcMessage = JSONObject()
                                rpcMessage[JSONKeys.priority_normal] = rpcIdx
                                self.connector.setFields(rpcMessage, forTorrents: [self.connector.torrent.trId])
                            }),
                            .default(Text(Image(systemName: "h.circle")) + Text(" High"), action: {
                                self.item.priority = 1
                                let rpcIdx = self.item.rpcIndexes
                                var rpcMessage = JSONObject()
                                rpcMessage[JSONKeys.priority_high] = rpcIdx
                                self.connector.setFields(rpcMessage, forTorrents: [self.connector.torrent.trId])
                            }),
                            .cancel()
                        ])
                    }
            } else {
                if !self.haveToRefresh {
                    Spacer()
                }
                Picker("", selection: self.$item.priority) {
                    Text("L").font(self.appState.sizeIsCompact ? .footnote : .title).tag(-1)
                    Text("N").font(self.appState.sizeIsCompact ? .footnote : .title).tag(0)
                    Text("H").font(self.appState.sizeIsCompact ? .footnote : .title).tag(1)
                }.pickerStyle(SegmentedPickerStyle())
                .frame(width: self.appState.sizeIsCompact ? 60 : 100, height: self.appState.sizeIsCompact ? 20 : nil)
                .fixedSize()
                .clipped()
                .onChange(of: self.item.priority) { value in
                        let rpcIdx = self.item.rpcIndexes
                        var rpcMessage = JSONObject()
                        switch value {
                        case -1:
                            rpcMessage[JSONKeys.priority_low] = rpcIdx
                        case 0:
                            rpcMessage[JSONKeys.priority_normal] = rpcIdx
                        case 1:
                            rpcMessage[JSONKeys.priority_high] = rpcIdx
                        default:
                            break
                        }
                        self.connector.setFields(rpcMessage, forTorrents: [self.connector.torrent.trId])
                        if self.item.isFolder {
                            for child in self.item.items ?? [] {
                                child.priority = value
                            }
                        }
                }
            }
        }.onChange(of: self.item.isWanted) { newValue in
            if !self.haveToRefresh && self.item.isFolder && (newValue != self.item.isWanted) {
                for item in self.item.items ?? [] {
                    item.isWanted = newValue
                }
            }
        }
        //.padding(.horizontal, appState.sizeIsCompact ? 5 : 10)
        .padding()
        .background(self.colorScheme == .light ? Color(.sRGB, white: 0.95, opacity: 0.95) : Color(.sRGB, white: 0.05, opacity: 0.95))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15).stroke(Color.primary.opacity(0.7), lineWidth: 1)
                    )
    }
    
    static func == (lhs: FileRowView, rhs: FileRowView) -> Bool {
        lhs.item.isEqual(rhs.item)
    }
}
