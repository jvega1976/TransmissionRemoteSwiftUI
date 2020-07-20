	//
//  SwiftUIView.swift
//  TransmissionRemoteSwiftUI
//
//  Created by  on 1/26/20.
//

import SwiftUI
import Combine

public enum MessageType {
    case error
    case info
}

    
public class Message: ObservableObject {
    @Published var message: String = ""
    @Published var type: MessageType = .info
}
    

struct MessageView: View {
    @EnvironmentObject var message: Message
    @EnvironmentObject var appState: AppState
    @State private var display: Bool = false
    private var torrentList: Bool = true
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    private let background = AnyView(Rectangle().fill(RadialGradient(gradient: Gradient(colors: [Color.darkGray, Color.gray, Color.black]), center: .center, startRadius: 10, endRadius:800)))
    
    public init(inTorrentList torrentList: Bool) {
        self.torrentList = torrentList
    }
    
    
    var body: some View {
            VStack(alignment: .center, spacing: 5.0) {
                HStack {
                    Image(systemName: self.message.type == .info ? "info.circle" : "exclamationmark.triangle").imageScale(.large)
                    Text( self.message.message)
                }.font(self.appState.sizeIsCompact || self.appState.detailViewIsDisplayed ? .footnote : .body)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
            }.padding(.vertical, 8)
            .messageColor(self.message.type)
            .foregroundColor(colorScheme == .light ? .white : .black)
            .cornerRadius(5)
            .shadow(color: Color(.sRGB, white: colorScheme == .light ? 0 : 1 , opacity: 0.5), radius: 5)
            .padding(.horizontal)
            .offset(x: 0, y: -55)
            .onReceive(self.message.$message) { value in
                self.display = !(value.isEmpty)
                if self.display {
                    Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
                            self.message.message = ""
                        })
                }
            }
            .transition(.move(edge: .bottom))
            .animation(.linear)
        }
}

struct MessageView_Previews: PreviewProvider {
    
    static let message: Message = {
        let message = Message()
        message.type = .error
        message.message = "This is a very looonnnnnnnnggggg lonnnnnnnnnnggg loonnnngg message"
        return message
    }()
    
    static var appState: AppState = {
        let appState = AppState()
        appState.sizeIsCompact = true
        return appState
    }()
    
    static var previews: some View {
        MessageView(inTorrentList: true)
            .preferredColorScheme(.dark)
            .environmentObject(self.message)
            .environmentObject(self.appState)
            .previewDevice(PreviewDevice(stringLiteral: "iPhone 8 Plus"))
            .environment(\.colorScheme, .dark)
    }
}
