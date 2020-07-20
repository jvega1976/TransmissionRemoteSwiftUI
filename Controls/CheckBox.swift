//
//  CheckBox.swift
//  TransmissionRemoteSwiftUI
//
//  Created by  on 3/7/20.
//

import SwiftUI

struct CheckRect: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)
        //path.addRoundedRect(in: rect, cornerSize: rect.size.applying(.init(scaleX: 0.15, y: 0.15)))
        return path
    }
}

struct CheckMark: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
            path.move(to: rect.origin.applying(.init(translationX: rect.width * 0.25, y: rect.height * 0.55)))
            path.addLine(to: CGPoint(x:rect.width * 0.5 , y: rect.height * 0.8))
            path.move(to: CGPoint(x:rect.width * 0.5 , y: rect.height * 0.8))
            path.addLine(to: CGPoint(x:rect.width * 0.75, y: rect.height * 0.2))
            path = path.strokedPath(StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin:.round))
            return path
    }
}


struct CheckBox: View {
    @Binding var selected: Bool
    @State var color: Color = .black
    @State var lineWidth: CGFloat = 1
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        ZStack {
            CheckRect()
                .stroke(self.color, lineWidth: self.lineWidth * 1.4)
               // .background(Color(.sRGB, white: self.colorScheme == .light ? 0.8 : 0.2, opacity: 0.8))
            CheckMark()
                .stroke(self.selected ? self.color : Color.clear, lineWidth: self.lineWidth).animation(Animation.default.speed(0.75))
            
        }
    }
    
    func stroke(color: Color, lineWidth: CGFloat) -> CheckBox {
        return CheckBox(selected: self.$selected, color: color, lineWidth: lineWidth)
    }
    
    func onToggle(count: Int = 1, perform action: @escaping () -> Void) ->  some View {
        return self.onTapGesture {
            withAnimation {
                self.selected.toggle()
            }
            action()
        }
    }

}


struct CheckBoxView: View {
    
    @State var selected: Bool = false
    
    var body: some View {
        CheckBox(selected: self.$selected)
            .stroke(color: .blue, lineWidth: 2)
            .frame(width: 40, height: 40, alignment: .center)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                  self.selected = true
            }
        }
    }
}

struct CheckBox_Previews: PreviewProvider {
    @State static var selected: Bool = true
    static var previews: some View {
        CheckBoxView(selected: self.selected)
            .preferredColorScheme(.dark)
            .environment(\.colorScheme, .dark)
            
    }
}
