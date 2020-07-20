//
//  SwiftUI-Extensions.swift
//  TransmissionRemoteSwiftUI
//
//  Created by  on 1/28/20.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var torrent: UTType {
        UTType(exportedAs: "net.johnnyvega.TransmissionRemote.torrent")
    }
}

extension Animation  {
    func repeatWhile(_ condition: Bool = false, autoreverses: Bool = true) -> Animation {
        if condition {
            return self.repeatForever(autoreverses: autoreverses)
        } else {
            return self
        }
    }
}

struct ToolbarLabelStyle : LabelStyle {
    var appState: AppState
   
    func makeBody(configuration: Configuration) -> some View {
        if self.appState.detailViewIsDisplayed {
            return Label(configuration)
                .labelStyle(IconOnlyLabelStyle())
                .font(.title2)
                .imageScale(.large)
                .scaledToFit()
              //  .frame(width: 35, height: 32, alignment: .center)
                
        } else if self.appState.sizeIsCompact  {
            return Label(configuration)
                .labelStyle(IconOnlyLabelStyle())
                .font(.headline)
                .imageScale(.medium)
                .scaledToFit()
              //  .frame(width: 22, height: 22, alignment: .center)
        }
        else {
            return Label(configuration)
                .labelStyle(IconOnlyLabelStyle())
                .font(.title3)
                .imageScale(.medium)
                .scaledToFit()
               // .frame(width: 35, height: 35, alignment: .center)
        }
    }
}

#if os(macOS)
public extension View {
    func device(_ color: ColorScheme = .dark) -> some View {
        return self.previewDevice(PreviewDevice(stringLiteral: "Mac"))
            .environment(\.colorScheme, color)
    }
    
    func messageColor(_ type: MessageType) -> some View {
        self.modifier(MessageColor(type: type))
    }
}


#endif

extension Color {
    #if os(iOS) || targetEnvironment(macCatalyst)
    public static let tertiaryLabel = Color(.tertiaryLabel)
    public static let secondaryLabel = Color(.secondaryLabel)
    public static let quaternaryLabel = Color(.quaternaryLabel)
    public static let systemBackground = Color(.systemBackground)
    public static let secondarySystemBackground = Color(.secondarySystemBackground)
    public static let tertiarySystemBackground = Color(.tertiarySystemBackground)
    public static let systemBlue = Color(.systemBlue)
    public static let systemYellow = Color(.systemYellow)
    public static let systemRed = Color(.systemRed)
    public static let systemGreen = Color(.systemGreen)
    public static let systemPurple = Color(.systemPurple)
    public static let systemOrange = Color(.systemOrange)
    public static let systemIndigo = Color(.systemIndigo)
    public static let systemPink = Color(.systemPink)
    public static let systemTeal = Color(.systemTeal)
    public static let lightGray = Color(.lightGray)
    public static let darkGray = Color(.darkGray)
    public static let link = Color(.systemBlue)
    public static let colorDownload = Color(.systemGreen)
    public static let colorAll = Color.secondary
    public static let colorError = Color.red
    public static let colorUpload = Color.purple // Color(.systemPurple) // Color("UploadColor")
    public static let colorActive = Color(.systemOrange)
    public static let colorCompleted = Color.blue
    public static let colorWait = Color("WaitColor1")
    public static let colorVerify =  Color(UIColor(named: "StopColor")!)
    public static let colorPaused = Color(.systemGray)
    public static let progressBarTrack = Color("ProgressBarTrackColor")
    public static let systemFill = Color(.systemFill)
    #else
    public static let secondaryLabel = Color(.secondaryLabelColor)
    public static let tertiaryLabel = Color(.tertiaryLabelColor)
    public static let quaternaryLabel = Color(.quaternaryLabelColor)
    public static let link = Color(.linkColor)
    public static let systemBlue = Color(.systemBlue)
    public static let systemYellow = Color(.systemYellow)
    public static let systemRed = Color(.systemRed)
    public static let systemGreen = Color(.systemGreen)
    public static let systemPurple = Color(.systemPurple)
    public static let systemOrange = Color(.systemOrange)
    public static let systemIndigo = Color(.systemIndigo)
    public static let systemPink = Color(.systemPink)
    public static let systemTeal = Color(.systemTeal)
    public static let lightGray = Color(.lightGray)
    public static let darkGray = Color(.darkGray)
    public static let colorVerify =  Color(NSColor(named: "StopColor")!)
    public static let systemFill = Color(.controlColor)
    #endif
}


public struct DeviceFont: ViewModifier {
    @EnvironmentObject var appState: AppState
    
    public func body(content: Content) -> some View {
        #if !os(macOS) || targetEnvironment(macCatalyst)
        if !appState.sizeIsCompact {
            return content
                    .font(.body)
        } else {
            return content
                    .font(.footnote)
        }
        #else
        return content
            .font(.body)
        #endif
    }
}


public struct SpeedLimitColor: ViewModifier {
    var limited: Bool
    
    public func body(content: Content) -> some View {
        if limited {
            return content
                .foregroundColor(.red)
        } else {
            return content
                .foregroundColor(.secondaryLabel)
        }
    }
    
}


public struct MessageColor: ViewModifier {
    var type: MessageType
    
    public func body(content: Content) -> some View {
        if type == .info {
            return content
                .background(Color.green)
        } else {
            return content
                .background(Color.red)
        }
    }
}

#if !os(macOS) || targetEnvironment(macCatalyst)
public struct PriorityFormat: ViewModifier {
    var priority: Int
    
    public func body(content: Content) -> some View {
        if priority == -1 {
            return content
                .foregroundColor(Color("lowPriority"))
                .frame(width: 25, height: 25, alignment: .center)
        } else if priority == 1 {
            return content
                .foregroundColor(.systemRed)
                .frame(width: 25, height: 25, alignment: .center)
        } else {
            return content
                .foregroundColor(Color("DownloadColor"))
                .frame(width: 25, height: 25, alignment: .center)
        }
    }
}

public struct TextEditing: ViewModifier {
    var isEditing: Bool
    
    public func body(content: Content) -> some View {
        if self.isEditing {
            return content
                    .textFieldStyle(RoundedBorderTextFieldStyle())
        } else {
            return content
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    //.textFieldStyle(PlainTextFieldStyle())
        }
    }
}


public struct PaddingTorrentIcon: ViewModifier {
    
    var edges: Edge.Set = .all
    #if !os(macOS) || targetEnvironment(macCatalyst)
     @EnvironmentObject var appState: AppState
    #endif
    
    public func body(content: Content) -> some View {
        #if !os(macOS) || targetEnvironment(macCatalyst)
        if !appState.sizeIsCompact  {
            return content
                .padding(edges)
        } else if appState.sizeIsCompact {
            return content
                .padding(edges, 5)
        }
        #endif
        return content
                .padding(edges, 0)
    }
}


public struct FormatIcon: ViewModifier {
     @EnvironmentObject var appState: AppState
    public func body(content: Content) -> some View {
        #if !os(macOS) || targetEnvironment(macCatalyst)
        if self.appState.detailViewIsDisplayed {
            return content
                .scaledToFit()
                .foregroundColor(.blue)
                .frame(width: 28, height: 28, alignment: .center)
        } else if self.appState.sizeIsCompact  {
            return content
                .scaledToFit()
                .foregroundColor(.blue)
                .frame(width: 25, height: 25, alignment: .center)
        }
        else {
            return content
                .scaledToFit()
                .foregroundColor(.blue)
                .frame(width: 35, height: 35, alignment: .center)
        }
        #else
            return content
                .scaledToFit()
                .foregroundColor(.link)
                .frame(width: 35, height: 35, alignment: .center)
        #endif
    }
}




public struct FormatDetailIcon: ViewModifier {
     @EnvironmentObject var appState: AppState
    public func body(content: Content) -> some View {
         #if !os(macOS) || targetEnvironment(macCatalyst)
         if appState.isiPhone {
            return content
                .scaledToFill()
                .frame(width: 22, height: 22, alignment: .center)
        } else {
            if appState.sizeIsCompact {
                return content
                    .scaledToFill()
                    .frame(width: 15, height: 15, alignment: .center)
            } else {
                return content
                    .scaledToFill()
                    .frame(width: 25, height: 25, alignment: .center)
            }
        }
        #else
        return content
            .scaledToFill()
            .frame(width: 25, height: 25, alignment: .center)
        #endif
    }
}


struct FormatTorrentIcon: ViewModifier {
    @EnvironmentObject var appState: AppState
    
     typealias Body = TorrentIcon
    
     func body(content: Content) -> TorrentIcon {
         #if !os(macOS) || targetEnvironment(macCatalyst)
         if appState.isiPhone  {
            return content
                .scaledToFill()
                //.clipped()
                .frame(width: TrIconPhoneSize.width, height: TrIconPhoneSize.height, alignment: .center) as! TorrentIcon
        } else {
            if  appState.sizeIsCompact || self.appState.detailViewIsDisplayed {
                return content
                    .scaledToFill()
                    //.clipped()
                    .frame(width: TrIconPadSlideSize.width, height: TrIconPadSlideSize.height, alignment: .center) as! TorrentIcon
            } else {
                return content
                    .scaledToFill()
                        //.clipped()
                    .frame(width: TrIconPadSize.width, height: TrIconPadSize.height, alignment: .center) as! TorrentIcon
            }
        }
        #else
        return content
            .scaledToFill()
            .clipped()
            .frame(width: TrIconPadSize.width, height: TrIconPadSize.height, alignment: .center)
        #endif
    }
}

public struct FormatCategoryIcon: ViewModifier {
     @EnvironmentObject var appState: AppState

    public func body(content: Content) -> some View {
        #if !os(macOS) || targetEnvironment(macCatalyst)
        if appState.isiPhone {
            return content
                //.scaledToFill()
                .frame(width: TrIconPhoneSize.width, height: TrIconPhoneSize.height, alignment: .center)
        } else {
            if appState.sizeIsCompact || self.appState.detailViewIsDisplayed {
                return content
                    //.scaledToFill()
                    .frame(width: TrIconPadSlideSize.width, height: TrIconPadSlideSize.height, alignment: .center)
            } else {
                return content
                    //.scaledToFill()
                    .frame(width: TrIconPadSize.width, height: TrIconPadSize.height, alignment: .center)
            }
        }
        #else
        return content
            .scaledToFill()
            .clipped()
            .frame(width: TrIconPadSize.width, height: TrIconPadSize.height, alignment: .center)
        #endif
    }
}

public struct ServerConfigListFormat: ViewModifier {
    
    var width: CGFloat
    var height: CGFloat
    var appState: AppState
    var colorScheme: ColorScheme
    
    public func body(content: Content) -> some View {
        if appState.sizeIsCompact {
            return content
                .frame(width: width/1.1, height: height/1.05, alignment: .leading)
                .cornerRadius(25)
                .shadow(color: Color(.sRGB, white: colorScheme == .light ? 0 : 1 , opacity: 0.33), radius: 10)
                .opacity(0.9)
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))).animation(.linear(duration: 0.5))
               
        } else {
            return content
                .frame(width: width/1.5, height: height/1.2, alignment: .center)
                .cornerRadius(25)
                .shadow(color: Color(.sRGB, white: colorScheme == .light ? 0 : 1 , opacity: 0.33), radius: 10)
                .opacity(0.9)
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))).animation(.linear(duration: 0.5))
                
        }
    }
}


public struct FormatHalfCloudIcon: ViewModifier {
    @EnvironmentObject var appState: AppState
    
    public func body(content: Content) -> some View {
        #if !os(macOS) || targetEnvironment(macCatalyst)

            if appState.sizeIsCompact || self.appState.detailViewIsDisplayed {
                return content
                    .scaledToFit()
                    .clipped()
                    .frame(width: 40, height: 40, alignment: .center)
                    .padding(.vertical)
            } else {
                return content
                    .scaledToFit()
                    .clipped()
                    .frame(width: 50, height: 50, alignment: .center)
                    .padding(.vertical)
            }
        #else
        return content
                .scaledToFill()
                .clipped()
                .frame(width: 45, height: 45, alignment: .center)
                .padding(.vertical)
        #endif
    }
}



public struct FormatPlayIcon: ViewModifier {
    var color: Color?
    @EnvironmentObject var appState: AppState
    
    public func body(content: Content) -> some View {
        #if !os(macOS) || targetEnvironment(macCatalyst)
        if appState.isiPhone  {
            return content
                .scaledToFill()
                .clipped()
                .foregroundColor(color)
                .frame(width: 40, height: 40, alignment: .center)
        } else {
            if appState.sizeIsCompact || self.appState.detailViewIsDisplayed {
                return content
                    .scaledToFill()
                    .clipped()
                    .foregroundColor(color)
                    .frame(width: 30, height: 30, alignment: .center)
                
            } else {
                return content
                    .scaledToFill()
                    .clipped()
                    .foregroundColor(color)
                    .frame(width: 50, height: 50, alignment: .center)
            }
        }
        #else
        return content
            .scaledToFill()
            .clipped()
            .foregroundColor(color)
            .frame(width: 60, height: 60, alignment: .center)
        #endif
    }
}


public struct AlertAction {
    var title: String
    var handler: (UITextField)->Void
    
    static func cancel()->AlertAction {
        return AlertAction(title: "Cancel")
    }
    
    public init(title: String, handler: ((UITextField)->Void)? =  {_ in }) {
        self.title = title
        self.handler = handler ??  {_ in }
    }
}

public extension View {
    
    func navigationStyle(_ isLandscape:Bool) -> some View {
        if isLandscape {
            return AnyView(self.navigationViewStyle(DoubleColumnNavigationViewStyle()))
        } else {
            return AnyView(self.navigationViewStyle(StackNavigationViewStyle()))
        }
    }
    
    /*func displayAlert( title: String, fieldLabel: String?, message: String?, actions: [AlertAction]) {
        guard let controller = (UIApplication.shared.connectedScenes.filter({$0.activationState == .foregroundActive}).first as? UIWindowScene)?.windows.filter({ $0.isKeyWindow}).first?.rootViewController else { return }
        let width = controller.view.frame.size.width
        let alertController = UIAlertController(title: title, message: fieldLabel, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {textField in
            textField.text = message
            textField.frame.size.width = width * 0.75
        })
        
        for action in actions {
            if action.title == "Cancel" {
                let alertAction = UIAlertAction(title: "Cancel", style: .cancel)
                alertController.addAction(alertAction)
            } else {
                let alertAction = UIAlertAction(title: action.title, style: .default, handler: {alertAction in action.handler((alertController.textFields?.first)!) })
                alertController.addAction(alertAction)
            }
        }
        controller.present(alertController, animated: true)
    }*/
    
    func deviceFont() -> some View {
        self.modifier(DeviceFont())
    }
    
    func speedLimitColor(_ limited: Bool) -> some View {
        self.modifier(SpeedLimitColor(limited: limited))
    }
    
    #if !os(macOS) || targetEnvironment(macCatalyst)
    func paddingTorrent(_ edges: Edge.Set = .all) -> some View {
        self.modifier(PaddingTorrentIcon(edges: edges))
    }
    #else
    func paddingTorrent(_ edges: Edge.Set = .all) -> some View {
        self.modifier(PaddingTorrentIcon(edges: edges))
    }
    #endif
    
  //  func formatIcon() -> some View {
  //      self.modifier(FormatIcon())
 //   }
    
    func formatCategoryIcon() -> some View {
        self.modifier(FormatCategoryIcon())
    }
    
    func formatDetailIcon() -> some View {
        self.modifier(FormatDetailIcon())
    }
    
   /* func formatFilesIcon() -> some View {
        self.modifier(FormatFilesIcon())
    }
   */
    
    func formatHalfCloudIcon() -> some View {
        self.modifier(FormatHalfCloudIcon())
    }
    
    
    func formatPlayIcon(_ color: Color? = nil) -> some View {
        self.modifier(FormatPlayIcon(color: color))
    }
    
    
    internal func formatServerConfig(width: CGFloat, height: CGFloat, appState: AppState, colorScheme: ColorScheme)-> some View {
        self.modifier(ServerConfigListFormat(width: width, height: height, appState: appState, colorScheme: colorScheme))
    }
    
    func messageColor(_ type: MessageType) -> some View {
        self.modifier(MessageColor(type: type))
    }
    
    #if !os(macOS) || targetEnvironment(macCatalyst)
    func priorityFormat(_ priority: Int) -> some View {
        self.modifier(PriorityFormat(priority: priority))
    }
    
    #endif
    
    func device(_ color: ColorScheme = .dark) -> some View {
        return self.previewDevice(PreviewDevice(stringLiteral: "iPad Pro (10.5-inch)"))
        .environment(\.colorScheme, color)
    }
    
}

extension Image {
    
    func formatImage(_ appState: AppState, color: Color? = .blue)-> some View {
        return self.resizable()
            .imageScale(.large)
            .scaledToFit()
            .foregroundColor(color)
            .frame(width: appState.sizeIsCompact ? 30 : 50 , height: appState.sizeIsCompact ? 30 : 50, alignment: .center)
    }
    
    func formatFilesIcon(_ appState: AppState) -> some View {
            #if !os(macOS) || targetEnvironment(macCatalyst)
            if appState.isiPhone || appState.detailViewIsDisplayed {
                return self.resizable()
                    .imageScale(.large)
                    .scaledToFill()
                    .frame(width: 25, height: 25, alignment: .center)
            } else {
                if appState.sizeIsCompact {
                    return self.resizable()
                        .imageScale(.large)
                        .scaledToFill()
                        .frame(width: 22, height: 22, alignment: .center)
                } else {
                    return self.resizable()
                        .imageScale(.large)
                        .scaledToFill()
                        .frame(width: 30, height: 30, alignment: .center)
                }
            }
            #else
            return content
                .scaledToFill()
                .frame(width: 25, height: 25, alignment: .center)
            #endif
        }
    
    func formatIcon(_ appState: AppState) -> some View {
        if appState.detailViewIsDisplayed {
            return self
                .resizable()
                .imageScale(.large)
                .scaledToFit()
                .foregroundColor(.blue)
                .frame(width: 35, height: 35, alignment: .center)
                .fixedSize()
        } else if appState.sizeIsCompact  {
            return self
                .resizable()
                .imageScale(.large)
                .scaledToFit()
                .foregroundColor(.blue)
                .frame(width: 30, height: 30, alignment: .center)
                .fixedSize()
        }
        else {
            return self
                .resizable()
                .imageScale(.large)
                .scaledToFit()
                .foregroundColor(.blue)
                .frame(width: 40, height: 40, alignment: .center)
                .fixedSize()
        }
    }
}
#endif

extension Font {
    static let system17 = Font.system(size: 24, design: .rounded)
}

struct InfoGroupBoxStyle: GroupBoxStyle {
    var colorScheme: ColorScheme
    
    typealias Body = GroupBox
    
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .padding([.top, .leading, .trailing])
            configuration.content
                .padding(.all)
        }.background(self.colorScheme == .light ? Color(.sRGB, white: 0.95, opacity: 0.95) : Color(.sRGB, white: 0.05, opacity: 0.95))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15).stroke(Color.primary.opacity(0.7), lineWidth: 1)
                    )
        //.border(Color.primary.opacity(0.7), width: 1)
        .padding(.all)
    }
    
    
}
