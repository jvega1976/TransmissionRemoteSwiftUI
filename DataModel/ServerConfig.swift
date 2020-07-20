//
//  ServerConfig.swift
//  TransmissionRemoteSwiftUI
//
//  Created by  on 2/15/20.
//

import SwiftUI

struct ServerConfig: View {
    var serverConfig: RPCServerConfig
    @Binding var isEditing: Bool
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(alignment: .center, spacing: 15.0) {
            Image("World")
                .resizable()
                .scaledToFill()
                .frame(width: self.appState.sizeIsCompact ? 30 : 42, height: self.appState.sizeIsCompact ? 30 : 42)
                .foregroundColor(.link)
            VStack(alignment: .leading) {
                Text(serverConfig.name)
                    .font(self.appState.sizeIsCompact ? .subheadline : .headline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 5.0)
                Text(serverConfig.urlString)
                    .font(self.appState.sizeIsCompact ? .caption : .footnote)
                    .scaledToFit()
                    .minimumScaleFactor(0.75)
                    .allowsTightening(true)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
            }.frame(alignment:.center)
            if self.isEditing {
                Spacer()
                Image("info.circle")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 25, height: 25, alignment: .trailing)
                    .foregroundColor(.link)
            }
        }
    }
    
    func deleteServerConfig() {
        ServerConfigDB.shared.db.removeAll(where:{ $0 == serverConfig})
        do {
            try ServerConfigDB.shared.save()
        } catch {
            
        }
    }
}

            
            

struct ServerConfig_Previews: PreviewProvider {
    @State static var isEditing: Bool = false
    
    static var previews: some View {
        ServerConfig(serverConfig: RPCServerConfig(), isEditing: $isEditing)
        .device()
    }
}
