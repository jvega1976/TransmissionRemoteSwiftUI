//
//  HalfCloudIcon.swift
//  TransmissionRemoteSwiftUI
//
//  Created by  on 2/8/20.
//

import SwiftUI

enum IconHalfCloudType : Int, Codable {
    case upload
    case download
    case none
    
    func stringValue() -> String {
        switch self {
            case .upload: return "Upload"
            case .download: return "Download"
            case .none: return "None"
        }
    }
    
    init(stringVal string: String) {
        switch string {
            case "Upload": self = .upload
            case "Download": self = .download
            default: self = .none
        }
    }
}

struct HalfCloud: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.maxX
        let h = rect.maxY
        var cloudPath = Path()
        
        cloudPath.move(to: CGPoint(x: 0.87551 * w, y: 0.06000 * h))
        cloudPath.addCurve(to: CGPoint(x: 0.67878 * w, y: 0.00694 * h), control1: CGPoint(x: 0.81673 * w, y: 0.02531 * h), control2: CGPoint(x: 0.75143 * w, y: 0.00694 * h))
        cloudPath.addCurve(to: CGPoint(x: 0.40939 * w, y: 0.11918 * h), control1: CGPoint(x: 0.57429 * w, y: 0.00694 * h), control2: CGPoint(x: 0.48449 * w, y: 0.04449 * h))
        cloudPath.addCurve(to: CGPoint(x: 0.29714 * w, y: 0.39184 * h), control1: CGPoint(x: 0.33429 * w, y: 0.19388 * h), control2: CGPoint(x: 0.29714 * w, y: 0.28490 * h))
        cloudPath.addCurve(to: CGPoint(x: 0.30367 * w, y: 0.40980 * h), control1: CGPoint(x: 0.29714 * w, y: 0.40082 * h), control2: CGPoint(x: 0.30000 * w, y: 0.40612 * h))
        cloudPath.addLine(to: CGPoint(x: 0.29714 * w, y: 0.40980 * h))
        cloudPath.addCurve(to: CGPoint(x: 0.09020 * w, y: 0.49551 * h), control1: CGPoint(x: 0.21633 * w, y: 0.40980 * h), control2: CGPoint(x: 0.14735 * w, y: 0.43837 * h))
        cloudPath.addCurve(to: CGPoint(x: 0.00449 * w, y: 0.70245 * h), control1: CGPoint(x: 0.03306 * w, y: 0.55265 * h), control2: CGPoint(x: 0.00449 * w, y: 0.62163 * h))
        cloudPath.addCurve(to: CGPoint(x: 0.09020 * w, y: 0.90939 * h), control1: CGPoint(x: 0.00449 * w, y: 0.78327 * h), control2: CGPoint(x: 0.03306 * w, y: 0.85224 * h))
        cloudPath.addCurve(to: CGPoint(x: 0.29714 * w, y: 0.99510 * h), control1: CGPoint(x: 0.14735 * w, y: 0.96653 * h), control2: CGPoint(x: 0.21633 * w, y: 0.99510 * h))
        cloudPath.addLine(to: CGPoint(x: 0.87551 * w, y: 0.99510 * h))
        
        return cloudPath
    }
}

struct ArrowUpPath: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var arrowUpPath = Path()
        arrowUpPath.move(to: CGPoint(x: 0.49877 * w, y: 0.00611 * h))
        arrowUpPath.addLine(to: CGPoint(x: 0.49893 * w, y: 0.98167 * h))
        arrowUpPath.move(to: CGPoint(x: 0.01720 * w, y: 0.23002 * h))
        arrowUpPath.addLine(to: CGPoint(x: 0.49877 * w, y: 0.00611 * h))
        arrowUpPath.move(to: CGPoint(x: 0.98042 * w, y: 0.22998 * h))
        arrowUpPath.addLine(to: CGPoint(x: 0.49877 * w, y: 0.00611 * h))
        return arrowUpPath
    }
}

struct ArrowDownPath: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var arrowDownPath = Path()
        arrowDownPath.move(to: CGPoint(x: 0.49884 * w, y: 0.98167 * h))
        arrowDownPath.addLine(to: CGPoint(x: 0.49868 * w, y: 0.00611 * h))
        arrowDownPath.move(to: CGPoint(x: 0.98042 * w, y: 0.75776 * h))
        arrowDownPath.addLine(to: CGPoint(x: 0.49884 * w, y: 0.98167 * h))
        arrowDownPath.move(to: CGPoint(x: 0.01720 * w, y: 0.75780 * h))
        arrowDownPath.addLine(to: CGPoint(x: 0.49884 * w, y: 0.98167 * h))
        return arrowDownPath
    }
}


struct HalfCloudIcon: View, Equatable {
    
    static func == (lhs: HalfCloudIcon, rhs: HalfCloudIcon) -> Bool {
        lhs.speed == rhs.speed && lhs.start == rhs.start
    }
    
    @EnvironmentObject var appState: AppState
    public var type: IconHalfCloudType
    @Binding var speed: Int
    @State private var start: Bool = false
    
    public init(type: IconHalfCloudType, speed: Binding<Int>) {
        self.type = type
        self._speed = speed
        
    }
    
    var body: some View {
        ZStack {
            HalfCloud()
                .stroke(lineWidth: self.appState.sizeIsCompact ? 2.0 : 3.0)
            if self.type == .download {
                GeometryReader { geometry in
                    ArrowDownPath()
                        .stroke(lineWidth: self.appState.sizeIsCompact ? 2.0 : 3.0)
                        .position(x: geometry.size.width / 1.2, y: geometry.size.height / 2)
                        .frame(width: floor(geometry.size.width * 1.11837 + 0.5) - floor(geometry.size.width * 0.76327 + 0.5), height: floor(geometry.size.height * 0.92245 + 0.5) - floor(geometry.size.height * 0.18776 + 0.5))
                        .offset(x: 0, y: self.start ? 8 : 0)
                        .opacity(self.start ? 0.6 : 1)
                        .animation(Animation.linear(duration: 1).repeatWhile(self.start))
                }
            } else {
                GeometryReader { geometry in
                    ArrowUpPath()
                        .stroke(lineWidth: self.appState.sizeIsCompact ? 2.0 : 3.0)
                        .position(x: geometry.size.width / 1.2, y: geometry.size.height / 1.9)
                        .frame(width: floor(geometry.size.width * 1.11837 + 0.5) - floor(geometry.size.width * 0.76327 + 0.5), height: floor(geometry.size.height * 0.92245 + 0.5) - floor(geometry.size.height * 0.18776 + 0.5))
                        
                        .offset(x: 0, y: self.start ? -8 : 0)
                        .opacity(self.start ? 0.6 : 1)
                        .animation(Animation.linear(duration: 1).repeatWhile(self.start))
                }
            }
        }.scaleEffect(0.75)
        .aspectRatio(1, contentMode: .fill)
        .onChange(of: self.speed) { value in
            withAnimation {
                self.start = value > 0
            }
        }
    }
}


struct HalfCloudIcon_Previews: PreviewProvider {
    
    @State static var speed: Int = 0
    
    static var appState: AppState = {
       let appState = AppState()
        appState.sizeIsCompact = true
        appState.isLandscape = false
        return appState
    }()
    
    static var previews: some View {

            HalfCloudIcon(type: .upload, speed: $speed)
                .foregroundColor(.white)
                .frame(width: 100, height: 100, alignment: .center)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            speed = 10
                        }
                    }
                }
                .preferredColorScheme(.dark)
                .environmentObject(appState)
                .previewDevice(PreviewDevice(rawValue: "iPhone 8 Plus"))
                .environment(\.colorScheme, .dark)
    }
}
