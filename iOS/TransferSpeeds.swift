//
//  TransferSpeeds.swift
//  TransmissionRemoteSwiftUI
//
//  Created by  on 2/9/20.
//

import SwiftUI
import TransmissionRPC

struct TransferSpeeds: View {
    
    @ObservedObject var sessionStats: SessionStats
    @ObservedObject var sessionConfig: SessionConfig
    @EnvironmentObject var connector: RPCConnector
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(alignment: .center) {
            HalfCloudIcon(type: .download, speed: $sessionStats.downloadSpeed)
                .equatable()
                .foregroundColor(self.sessionConfig.speedLimitDownEnabled ? .systemRed : .secondaryLabel)
                    .formatHalfCloudIcon()
            Text(ByteCountFormatter.formatByteRate(self.sessionStats.downloadSpeed))
                .speedLimitColor(self.sessionConfig.speedLimitDownEnabled)
            Spacer()
            VStack {
                Image("freeSpace")
                    .resizable()
                    .scaledToFill()
                    .frame(width: self.appState.sizeIsCompact ? 25 : 35, height: self.appState.sizeIsCompact ? 25 : 35)
                Text(self.connector.freeSpace)
                    .foregroundColor(Color.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
                HalfCloudIcon(type: .upload, speed: $sessionStats.uploadSpeed)
                    .equatable()
                    .foregroundColor(self.sessionConfig.speedLimitUpEnabled ? .systemRed : .secondaryLabel)
                    .formatHalfCloudIcon()
            Text(ByteCountFormatter.formatByteRate(self.sessionStats.uploadSpeed))
                .speedLimitColor(self.sessionConfig.speedLimitUpEnabled)
        }
        .font(self.appState.sizeIsCompact && !self.appState.isiPhone ? .footnote : nil)
        .minimumScaleFactor(0.75)
        .lineLimit(1)
        .foregroundColor(.secondaryLabel)
        .padding(.horizontal, 20.0)
    }
}

struct TransferSpeeds_Previews: PreviewProvider {
    
    static let connector: RPCConnector = {
        let connector = RPCConnector()
        connector.freeSpace = "679 GB"
        return connector
    }()
    
    static let appState: AppState = {
        let appState = AppState()
        appState.sizeIsCompact = false
        appState.isLandscape = false
        return appState
    }()
    
    static var previews: some View {
        
        TransferSpeeds(sessionStats: connector.sessionStats, sessionConfig: connector.sessionConfig)
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 8 Plus")
            .environmentObject(connector)
            .environmentObject(appState)
            .environment(\.colorScheme, .dark)
    }
}
