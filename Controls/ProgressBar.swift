//
//  ProgressBar.swift
//  Transmission Remote SwiftUI
//
//  Created by  on 1/24/20.
//

import SwiftUI

struct ProgressBar: View {
    
    var progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.tertiaryLabel)
                    .frame(width: geometry.size.width)
                    .cornerRadius(25)
                    .opacity(0.7)
                Rectangle()
                    .frame(width: geometry.size.width * self.progress)
            }
        }.clipShape(Capsule())
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProgressBar(progress: 0.7)
                .frame(height: 5.0)
                .foregroundColor(Color.green)
            .previewDevice(PreviewDevice(stringLiteral: "iPhone 8 Plus"))
        ProgressBar(progress: 0.7)
            .frame(height: 5.0)
            .foregroundColor(Color.green)
            .device()
        }
    }
}
