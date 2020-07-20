//
//  TorrentIcon.swift
//  Transmission Remote SwiftUI
//
//  Created by  on 1/24/20.
//

import SwiftUI
import TransmissionRPC

let TrIconPadSize = CGSize(width: 50, height: 55)
let TrIconPadSlideSize = CGSize(width: 35, height: 35)
let TrIconPhoneSize = CGSize(width: 40, height: 60)


public enum TorrentIconType : Int, Codable {
    case Download
    case Upload
    case Wait
    case Verify
    case Pause
    case Error
    case Active
    case All
    case None
    case Completed
    
    func stringValue() -> String {
        switch self {
            case .Download: return "Downloading"
            case .Upload: return "Uploading"
            case .Wait: return "Waiting"
            case .Verify: return "Verifying"
            case .Pause: return "Paused"
            case .Error: return "Error"
            case .Active: return "Active"
            case .All: return "All"
            case .None: return "None"
            case .Completed: return "Completed"
        }
    }
    
    
    init(stringVal string: String) {
        switch string {
            case "Downloading": self = .Download
            case "Uploading": self = .Upload
            case "Waiting": self = .Wait
            case "Verifying": self = .Verify
            case "Paused": self = .Pause
            case "Error": self = .Error
            case "Active": self = .Active
            case "All": self = .All
            case "Completed": self = .Completed
            default: self = .None
        }
    }
}


struct ArrowDown: View {
    var body: some View {
        GeometryReader { geometry in
             Path { arrowDownPath in
                let rect = geometry.frame(in: .local)
                let w = rect.maxX
                let h = rect.maxY
                arrowDownPath.move(to: CGPoint(x: 0.49491 * w, y: 0.90623 * h))
                arrowDownPath.addLine(to: CGPoint(x: 0.49491 * w, y: 0.09178 * h))
                arrowDownPath.move(to: CGPoint(x: 0.73398 * w, y: 0.64858 * h))
                arrowDownPath.addLine(to: CGPoint(x: 0.49491 * w, y: 0.92539 * h))
                arrowDownPath.addLine(to: CGPoint(x: 0.25583 * w, y: 0.64858 * h))
             }.stroke(lineWidth: 4)
            .scale(x: 0.5, y: 0.5, anchor: .bottom)
            .offset(x: 0, y: -7)
        }
    }
}


struct ArrowUp: View {

    var body: some View {
        GeometryReader { geometry in
            Path { arrowUpPath in
                let rect = geometry.frame(in: .local)
                let w = rect.maxX
                let h = rect.maxY
                arrowUpPath.move(to: CGPoint(x: 0.5 * w, y: 0.11094 * h))
                arrowUpPath.addLine(to: CGPoint(x: 0.5 * w, y: 0.92539 * h))
                arrowUpPath.move(to: CGPoint(x: 0.25583 * w, y: 0.36858 * h))
                arrowUpPath.addLine(to: CGPoint(x: 0.5 * w, y: 0.09178 * h))
                arrowUpPath.addLine(to: CGPoint(x: 0.73398 * w, y: 0.36858 * h))
            }.stroke(lineWidth: 4)
            .scale(x: 0.5, y: 0.5, anchor: .center)
            .offset(x: 0, y: 8)
        }
    }
}


struct LittleArrows: View {
    var body: some View {
        GeometryReader { geometry in
            Path { arrUpPath in
                let rect = geometry.frame(in: .local)
                let w = rect.maxX
                let h = rect.maxY
                arrUpPath.move(to: CGPoint(x: 0.40200 * w, y: 0.40074 * h))
                arrUpPath.addLine(to: CGPoint(x: 0.40200 * w, y: 0.78513 * h))
                arrUpPath.move(to: CGPoint(x: 0.30745 * w, y: 0.49071 * h))
                arrUpPath.addLine(to: CGPoint(x: 0.40200 * w, y: 0.39405 * h))
                arrUpPath.addLine(to: CGPoint(x: 0.50655 * w, y: 0.49071 * h))
                arrUpPath.move(to: CGPoint(x: 0.61200 * w, y: 0.77026 * h))
                arrUpPath.addLine(to: CGPoint(x: 0.61200 * w, y: 0.38587 * h))
                arrUpPath.move(to: CGPoint(x: 0.70655 * w, y: 0.68030 * h))
                arrUpPath.addLine(to: CGPoint(x: 0.61200 * w, y: 0.77695 * h))
                arrUpPath.addLine(to: CGPoint(x: 0.51745 * w, y: 0.68030 * h))
            } .stroke(lineWidth: 2.5)
            .scale(x: 0.75, y: 0.75, anchor: .center)
            .offset(x: 0, y: 5)
            
        }
    }
}


struct ValidMark: View {
    var body: some View {
        GeometryReader { geometry in
            Path { btnPath in
                let rect = geometry.frame(in: .local)
                let w = rect.maxX
                let h = rect.maxY
                btnPath.move(to: CGPoint(x: 0.15099 * w, y: 0.55099 * h))
                btnPath.addLine(to: CGPoint(x: 0.50299 * w, y: 0.90099 * h))
                btnPath.addLine(to: CGPoint(x: 0.95099 * w, y: 0.15079 * h))
            }.stroke(lineWidth: 6)
             .scale(x: 0.35, y: 0.35, anchor: .center)
            .offset(x: 0, y: 6)
        }
    }
}


struct WaitButton: View {
    @State private var start: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            Path { circleArrowsPath in
                let rect = geometry.frame(in: .local)
                let w = rect.maxX
                let h = rect.maxY
                circleArrowsPath.addArc(
                    center: CGPoint(x: w/2, y: h/2),
                    radius: w * 0.4,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360),
                    clockwise: false
                )
                circleArrowsPath.move(to: CGPoint(x: w / 2, y: h / 2))
                circleArrowsPath.addLine(to: CGPoint(x: 0.52 * w, y: 0.18 * h))
                circleArrowsPath.move(to: CGPoint(x: w / 2, y: h / 2))
                circleArrowsPath.addLine(to: CGPoint(x: 0.25 * w, y: 0.5 * h))
            }.stroke(lineWidth: 5)
            .scale(x: 0.4, y: 0.4, anchor: .center)
            .rotationEffect(.degrees( self.start ? 360 : 0), anchor: .center)
            .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false))
            .offset(x: 0, y: 8)
        }.onAppear {
            self.start.toggle()
        }
    }
}


struct CrossButton: View {
    var body: some View {
        GeometryReader { geometry in
            Path { errPath in
                let rect = geometry.frame(in: .local)
                let w = rect.maxX
                let h = rect.maxY
            errPath.addArc(
                center: CGPoint(x: w/2, y: h/2),
                radius: w * 0.4,
                startAngle: .degrees(0),
                endAngle: .degrees(360),
                clockwise: false
            )
            errPath.move(to: CGPoint(x: 0.34018 * w, y: 0.32990 * h))
            errPath.addLine(to: CGPoint(x: 0.64624 * w, y: 0.68345 * h))
            errPath.move(to: CGPoint(x: 0.35075 * w, y: 0.68345 * h))
            errPath.addLine(to: CGPoint(x: 0.65681 * w, y: 0.32990 * h))
            }.stroke(lineWidth: 5)
            .scale(x: 0.5, y: 0.5, anchor: .center)
            .offset(x: 0, y: 8)
        }
    }
}


struct StopButton: View {
    var body: some View {
        GeometryReader { geometry in
            Path { btnPath in
                let rect = geometry.frame(in: .local)
                let w = rect.maxX
                let h = rect.maxY
                btnPath.addArc(
                    center: CGPoint(x: w/2, y: h/2),
                    radius: w * 0.4,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360),
                    clockwise: false
                )
                btnPath.move(to: CGPoint(x: 0.40299 * w, y: 0.37069 * h))
                btnPath.addLine(to: CGPoint(x: 0.40299 * w, y: 0.66379 * h))
                btnPath.move(to: CGPoint(x: 0.56716 * w, y: 0.37069 * h))
                btnPath.addLine(to: CGPoint(x: 0.56716 * w, y: 0.66379 * h))
            }.stroke(lineWidth: 5)
            .scale(0.5, anchor: .center)
            .offset(x: 0, y: 8)
        }
    }
}


struct CheckButton: View {
    @State private var start: Bool = false
    var body: some View {
        GeometryReader { geometry in
            Path { circleArrowsPath in
                let rect = geometry.frame(in: .local)
                let w2 = rect.maxX
                let h2 = rect.maxY
        
                circleArrowsPath.move(to: CGPoint(x: 0.08687 * w2, y: 0.42079 * h2))
                circleArrowsPath.addCurve(to: CGPoint(x: 0.49224 * w2, y: 0.02726 * h2), control1: CGPoint(x: 0.12259 * w2, y: 0.19681 * h2), control2: CGPoint(x: 0.29045 * w2, y: 0.02726 * h2))
                circleArrowsPath.addCurve(to: CGPoint(x: 0.89760 * w2, y: 0.42079 * h2), control1: CGPoint(x: 0.69403 * w2, y: 0.02726 * h2), control2: CGPoint(x: 0.86188 * w2, y: 0.19681 * h2))
                circleArrowsPath.move(to: CGPoint(x: 0.30116 * w2, y: 0.36008 * h2))
                circleArrowsPath.addLine(to: CGPoint(x: 0.08152 * w2, y: 0.41974 * h2))
                circleArrowsPath.addLine(to: CGPoint(x: 0.03062 * w2, y: 0.16228 * h2))
                circleArrowsPath.move(to: CGPoint(x: 0.89760 * w2, y: 0.56940 * h2))
                circleArrowsPath.addCurve(to: CGPoint(x: 0.49224 * w2, y: 0.96292 * h2), control1: CGPoint(x: 0.86188 * w2, y: 0.79338 * h2), control2: CGPoint(x: 0.69403 * w2, y: 0.96292 * h2))
                circleArrowsPath.addCurve(to: CGPoint(x: 0.08687 * w2, y: 0.56940 * h2), control1: CGPoint(x: 0.29045 * w2, y: 0.96292 * h2), control2: CGPoint(x: 0.12259 * w2, y: 0.79338 * h2))
                circleArrowsPath.move(to: CGPoint(x: 0.68688 * w2, y: 0.66464 * h2))
                circleArrowsPath.addLine(to: CGPoint(x: 0.89760 * w2, y: 0.56940 * h2))
                circleArrowsPath.addLine(to: CGPoint(x: 0.97885 * w2, y: 0.81640 * h2))
            }.stroke(lineWidth: 5)
            .scale(x: 0.4, y: 0.35, anchor: .center)
            .rotationEffect(.degrees( self.start ? 360 : 0), anchor: .center)
            .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false))
            .offset(x: 0, y: 8)
        }
        .onAppear {
            self.start.toggle()
        }
    }
}


struct Clouds: View {
    var body: some View {
        GeometryReader { geometry in
            Path { cloudsPath in
                let rect = geometry.frame(in: .local)
                let w = rect.maxX
                let h = rect.maxY
        
                cloudsPath.move(to: CGPoint(x: 0.44914 * w, y: 0.74233 * h))
                cloudsPath.addLine(to: CGPoint(x: 0.33726 * w, y: 0.74233 * h))
                cloudsPath.addCurve(to: CGPoint(x: 0.23247 * w, y: 0.69888 * h), control1: CGPoint(x: 0.29627 * w, y: 0.74233 * h), control2: CGPoint(x: 0.26144 * w, y: 0.72785 * h))
                cloudsPath.addCurve(to: CGPoint(x: 0.18901 * w, y: 0.59408 * h), control1: CGPoint(x: 0.20350 * w, y: 0.66990 * h), control2: CGPoint(x: 0.18901 * w, y: 0.63507 * h))
                cloudsPath.addCurve(to: CGPoint(x: 0.23247 * w, y: 0.48929 * h), control1: CGPoint(x: 0.18901 * w, y: 0.55309 * h), control2: CGPoint(x: 0.20350 * w, y: 0.51826 * h))
                cloudsPath.addCurve(to: CGPoint(x: 0.33726 * w, y: 0.44583 * h), control1: CGPoint(x: 0.26144 * w, y: 0.46032 * h), control2: CGPoint(x: 0.29627 * w, y: 0.44583 * h))
                cloudsPath.addLine(to: CGPoint(x: 0.33726 * w, y: 0.43566 * h))
                cloudsPath.addCurve(to: CGPoint(x: 0.39428 * w, y: 0.29851 * h), control1: CGPoint(x: 0.33757 * w, y: 0.38203 * h), control2: CGPoint(x: 0.35668 * w, y: 0.33642 * h))
                cloudsPath.addCurve(to: CGPoint(x: 0.53082 * w, y: 0.24149 * h), control1: CGPoint(x: 0.43219 * w, y: 0.26059 * h), control2: CGPoint(x: 0.47781 * w, y: 0.24149 * h))
                cloudsPath.addCurve(to: CGPoint(x: 0.64918 * w, y: 0.28032 * h), control1: CGPoint(x: 0.57551 * w, y: 0.24149 * h), control2: CGPoint(x: 0.61496 * w, y: 0.25443 * h))
                cloudsPath.addCurve(to: CGPoint(x: 0.71883 * w, y: 0.38234 * h), control1: CGPoint(x: 0.68339 * w, y: 0.30621 * h), control2: CGPoint(x: 0.70681 * w, y: 0.34042 * h))
                cloudsPath.addCurve(to: CGPoint(x: 0.78202 * w, y: 0.37155 * h), control1: CGPoint(x: 0.74041 * w, y: 0.37525 * h), control2: CGPoint(x: 0.76167 * w, y: 0.37155 * h))
                cloudsPath.addCurve(to: CGPoint(x: 0.91208 * w, y: 0.42580 * h), control1: CGPoint(x: 0.83256 * w, y: 0.37155 * h), control2: CGPoint(x: 0.87602 * w, y: 0.38974 * h))
                cloudsPath.addCurve(to: CGPoint(x: 0.96633 * w, y: 0.55679 * h), control1: CGPoint(x: 0.94814 * w, y: 0.46186 * h), control2: CGPoint(x: 0.96633 * w, y: 0.50562 * h))
                cloudsPath.addCurve(to: CGPoint(x: 0.91208 * w, y: 0.68778 * h), control1: CGPoint(x: 0.96633 * w, y: 0.60795 * h), control2: CGPoint(x: 0.94814 * w, y: 0.65172 * h))
                cloudsPath.addCurve(to: CGPoint(x: 0.78202 * w, y: 0.74202 * h), control1: CGPoint(x: 0.87602 * w, y: 0.72384 * h), control2: CGPoint(x: 0.83256 * w, y: 0.74202 * h))
                cloudsPath.addLine(to: CGPoint(x: 0.69078 * w, y: 0.74202 * h))
                cloudsPath.move(to: CGPoint(x: 0.45932 * w, y: 0.22762 * h))
                cloudsPath.addCurve(to: CGPoint(x: 0.44082 * w, y: 0.21128 * h), control1: CGPoint(x: 0.45346 * w, y: 0.22176 * h), control2: CGPoint(x: 0.44760 * w, y: 0.21621 * h))
                cloudsPath.addCurve(to: CGPoint(x: 0.33665 * w, y: 0.17707 * h), control1: CGPoint(x: 0.41062 * w, y: 0.18847 * h), control2: CGPoint(x: 0.37579 * w, y: 0.17707 * h))
                cloudsPath.addCurve(to: CGPoint(x: 0.21644 * w, y: 0.22731 * h), control1: CGPoint(x: 0.28980 * w, y: 0.17707 * h), control2: CGPoint(x: 0.24973 * w, y: 0.19371 * h))
                cloudsPath.addCurve(to: CGPoint(x: 0.16620 * w, y: 0.34905 * h), control1: CGPoint(x: 0.18316 * w, y: 0.26090 * h), control2: CGPoint(x: 0.16620 * w, y: 0.30128 * h))
                cloudsPath.addCurve(to: CGPoint(x: 0.16929 * w, y: 0.35707 * h), control1: CGPoint(x: 0.16620 * w, y: 0.35306 * h), control2: CGPoint(x: 0.16744 * w, y: 0.35552 * h))
                cloudsPath.addLine(to: CGPoint(x: 0.16620 * w, y: 0.35707 * h))
                cloudsPath.addCurve(to: CGPoint(x: 0.07374 * w, y: 0.39528 * h), control1: CGPoint(x: 0.13014 * w, y: 0.35707 * h), control2: CGPoint(x: 0.09932 * w, y: 0.36970 * h))
                cloudsPath.addCurve(to: CGPoint(x: 0.03552 * w, y: 0.48775 * h), control1: CGPoint(x: 0.04816 * w, y: 0.42087 * h), control2: CGPoint(x: 0.03552 * w, y: 0.45169 * h))
                cloudsPath.addCurve(to: CGPoint(x: 0.07374 * w, y: 0.58021 * h), control1: CGPoint(x: 0.03552 * w, y: 0.52381 * h), control2: CGPoint(x: 0.04816 * w, y: 0.55463 * h))
                cloudsPath.addCurve(to: CGPoint(x: 0.16620 * w, y: 0.61843 * h), control1: CGPoint(x: 0.09932 * w, y: 0.60579 * h), control2: CGPoint(x: 0.12984 * w, y: 0.61843 * h))
                cloudsPath.addLine(to: CGPoint(x: 0.16929 * w, y: 0.61843 * h))
                
                cloudsPath.move(to: CGPoint(x: 0.62298 * w, y: 0.58977 * h))
                cloudsPath.addLine(to: CGPoint(x: 0.62298 * w, y: 0.77346 * h))
                cloudsPath.move(to: CGPoint(x: 0.56103 * w, y: 0.64788 * h))
                cloudsPath.addLine(to: CGPoint(x: 0.62298 * w, y: 0.58545 * h))
                cloudsPath.addLine(to: CGPoint(x: 0.68493 * w, y: 0.64788 * h))
                cloudsPath.move(to: CGPoint(x: 0.52065 * w, y: 0.86469 * h))
                cloudsPath.addLine(to: CGPoint(x: 0.52065 * w, y: 0.68100 * h))
                cloudsPath.move(to: CGPoint(x: 0.58260 * w, y: 0.80658 * h))
                cloudsPath.addLine(to: CGPoint(x: 0.52065 * w, y: 0.86901 * h))
                cloudsPath.addLine(to: CGPoint(x: 0.45870 * w, y: 0.80658 * h))
            }.stroke(lineWidth: 2.5)
            .scaleEffect(x: 1.2, y: 1.22, anchor: .center)
            .offset(x: 0, y: -2)
        }
    }
}


struct Cloud: View {
    var body: some View {
        GeometryReader { geometry in
            Path { cloudPath in
                let rect = geometry.frame(in: .local)
                let w = rect.maxX
                let h = rect.maxY
                
                cloudPath.move(to: CGPoint(x: 0.24846 * w, y: 0.71086 * h))
                cloudPath.addLine(to: CGPoint(x: 0.20217 * w, y: 0.71086 * h))
                cloudPath.addCurve(to: CGPoint(x: 0.07020 * w, y: 0.65506 * h), control1: CGPoint(x: 0.15077 * w, y: 0.71086 * h), control2: CGPoint(x: 0.10666 * w, y: 0.69226 * h))
                cloudPath.addCurve(to: CGPoint(x: 0.01917 * w, y: 0.52041 * h), control1: CGPoint(x: 0.03375 * w, y: 0.61787 * h), control2: CGPoint(x: 0.01917 * w, y: 0.57286 * h))
                cloudPath.addCurve(to: CGPoint(x: 0.04760 * w, y: 0.41179 * h), control1: CGPoint(x: 0.01917 * w, y: 0.47949 * h), control2: CGPoint(x: 0.02609 * w, y: 0.44303 * h))
                cloudPath.addCurve(to: CGPoint(x: 0.13801 * w, y: 0.34148 * h), control1: CGPoint(x: 0.06911 * w, y: 0.38054 * h), control2: CGPoint(x: 0.09900 * w, y: 0.35710 * h))
                cloudPath.addCurve(to: CGPoint(x: 0.18139 * w, y: 0.24997 * h), control1: CGPoint(x: 0.14165 * w, y: 0.30577 * h), control2: CGPoint(x: 0.15623 * w, y: 0.27527 * h))
                cloudPath.addCurve(to: CGPoint(x: 0.27362 * w, y: 0.21240 * h), control1: CGPoint(x: 0.20654 * w, y: 0.22505 * h), control2: CGPoint(x: 0.23716 * w, y: 0.21240 * h))
                cloudPath.addCurve(to: CGPoint(x: 0.34726 * w, y: 0.23547 * h), control1: CGPoint(x: 0.29731 * w, y: 0.21240 * h), control2: CGPoint(x: 0.32210 * w, y: 0.22021 * h))
                cloudPath.addCurve(to: CGPoint(x: 0.44167 * w, y: 0.13057 * h), control1: CGPoint(x: 0.36986 * w, y: 0.19194 * h), control2: CGPoint(x: 0.40121 * w, y: 0.15698 * h))
                cloudPath.addCurve(to: CGPoint(x: 0.57546 * w, y: 0.09114 * h), control1: CGPoint(x: 0.48177 * w, y: 0.10416 * h), control2: CGPoint(x: 0.52661 * w, y: 0.09114 * h))
                cloudPath.addCurve(to: CGPoint(x: 0.75555 * w, y: 0.16628 * h), control1: CGPoint(x: 0.64582 * w, y: 0.09114 * h), control2: CGPoint(x: 0.70597 * w, y: 0.11606 * h))
                cloudPath.addCurve(to: CGPoint(x: 0.82991 * w, y: 0.34892 * h), control1: CGPoint(x: 0.80512 * w, y: 0.21612 * h), control2: CGPoint(x: 0.82991 * w, y: 0.27713 * h))
                cloudPath.addCurve(to: CGPoint(x: 0.82809 * w, y: 0.36045 * h), control1: CGPoint(x: 0.82991 * w, y: 0.35264 * h), control2: CGPoint(x: 0.82918 * w, y: 0.35673 * h))
                cloudPath.addCurve(to: CGPoint(x: 0.93454 * w, y: 0.41737 * h), control1: CGPoint(x: 0.86819 * w, y: 0.36566 * h), control2: CGPoint(x: 0.90392 * w, y: 0.38463 * h))
                cloudPath.addCurve(to: CGPoint(x: 0.98083 * w, y: 0.53380 * h), control1: CGPoint(x: 0.96516 * w, y: 0.45010 * h), control2: CGPoint(x: 0.98083 * w, y: 0.48879 * h))
                cloudPath.addCurve(to: CGPoint(x: 0.93089 * w, y: 0.65878 * h), control1: CGPoint(x: 0.98083 * w, y: 0.58253 * h), control2: CGPoint(x: 0.96406 * w, y: 0.62419 * h))
                cloudPath.addCurve(to: CGPoint(x: 0.80913 * w, y: 0.71086 * h), control1: CGPoint(x: 0.89772 * w, y: 0.69338 * h), control2: CGPoint(x: 0.85689 * w, y: 0.71086 * h))
                cloudPath.addLine(to: CGPoint(x: 0.76976 * w, y: 0.71086 * h))
            }.stroke(lineWidth: 2.5)
        }
    }
}


struct TorrentIcon: View, Equatable {
    
    static func == (lhs: TorrentIcon, rhs: TorrentIcon) -> Bool {
        lhs.type == rhs.type && lhs.start == rhs.start
    }
    
    @State public var type: TorrentIconType
    @State public var color: Color
    @ObservedObject var torrent: Torrent
    @EnvironmentObject var appState: AppState
    @State private var start: Bool = false
    
    init(type: TorrentIconType, color: Color) {
        self._type = State(initialValue: type)
        self._color = State(initialValue: color)
        self.torrent = Torrent()
        self.torrent.trId = 0
    }
    
    init(torrent: Torrent) {
        self._type = State(initialValue: torrent.iconType)
        self._color = State(initialValue: torrent.statusColor)
        self.torrent = torrent
    }
    
    var body: some View {
        ZStack {
            if self.type == .All {
                Clouds()
            } else {
                Cloud()
                    .scaleEffect(self.start ? 1.25 : 1 )
                    .animation(Animation.linear(duration: 1))
                    .scaleEffect(self.start ? 0.8 : 1)
                    .animation(Animation.linear(duration: 1).delay(1))
              
                switch (self.type) {
                    case .Active:
                        LittleArrows()
                    case .Download:
                        ArrowDown()
                            .offset(x: 0 , y: self.start ? 7 : 0 )
                            .opacity(self.start ? 0.4 : 1)
                            .animation(Animation.linear(duration: 1.5).repeatWhile(self.start))
                    case .Upload:
                        ArrowUp()
                            .offset(x: 0 , y: self.start ? -7 : 0)
                            .opacity(self.start ? 0.4 : 1)
                            .animation(Animation.linear(duration:1.5).repeatWhile(self.start))
                    case .Wait:
                        WaitButton()
                    case .Verify:
                        CheckButton()
                    case .Error:
                        CrossButton()
                    case .Completed:
                        ValidMark()
                    case .Pause:
                        StopButton()
                    default:
                       EmptyView()
                }
            }
        }.foregroundColor(self.color)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    if self.type == .Download && torrent.trId == 0 {
                        self.torrent.downloadRate = 100
                    } else if self.type == .Upload && torrent.trId == 0  {
                        self.torrent.uploadRate = 100
                    }
                }
            }
        }
        .onChange(of: self.torrent.downloadRate) { value in
            if self.type == .Download {
                withAnimation {
                    self.start = value > 0
                }
            }
        }
        .onChange(of: self.torrent.uploadRate) { value in
            if self.type == .Upload {
                withAnimation {
                    self.start = value > 0
                }
            }
        }
        .onChange(of: self.torrent.status) { value in
            if torrent.trId != 0 {
                withAnimation {
                    self.type = torrent.iconType
                    self.color = torrent.statusColor
                }
            }
        }
        
    }
    
    func format(_ appState: AppState)-> some View {
        if appState.sizeIsCompact || appState.detailViewIsDisplayed {
            return self
                .frame(width: TrIconPadSlideSize.width , height:  TrIconPadSlideSize.height , alignment: .center)
        }
        else  {
            return self
                .frame(width: TrIconPadSize.width , height:  TrIconPadSize.height , alignment: .center)
        }
        
    }
    
}


struct TorrentIcon_Previews: PreviewProvider {
    @State static var start: Bool = false
    static let appState = AppState()
    static var previews: some View {
        Group {
            TorrentIcon(type: .Upload, color: .colorUpload)
                .preferredColorScheme(.dark)
                .frame(width: 300, height: 300, alignment: .center)
                .previewDevice(PreviewDevice(rawValue: "iPhone 8 Plus"))
                .environment(\.colorScheme, .dark)
            
            TorrentIcon(type:.Download, color: .colorDownload)
                .preferredColorScheme(.dark)
                  .frame(width: 300, height: 300, alignment: .center)
                .previewDevice(PreviewDevice(rawValue: "iPhone 8 Plus"))
                .environment(\.colorScheme, .dark)
        }
    }
}


