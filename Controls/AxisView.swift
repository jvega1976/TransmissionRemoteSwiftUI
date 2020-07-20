//
//  AxisViewswift.swift
//  TransmissionRemoteSwiftUI
//
//  Created by  on 6/1/20.
//

import SwiftUI

struct AxisView<Content:View>: View {
    
    private var content: ()->Content
    private var axis: Axis
    private var alignment: Alignment
    private var spacing: CGFloat?
    
    init(_ axis: Axis, alignment: Alignment, spacing: CGFloat? = nil, @ViewBuilder content: @escaping ()->Content) {
        self.axis = axis
        self.content = content
        self.alignment = alignment
        self.spacing = spacing
    }
    
    public var body: some View {
        Group {
            if self.axis == .vertical {
                VStack(alignment:self.alignment.horizontal, spacing: self.spacing, content: self.content)
            } else if self.axis == .horizontal {
                HStack(alignment:self.alignment.vertical, spacing: self.spacing, content: self.content)
            } else {
                ZStack(alignment:self.alignment, content: self.content)
            }
        }
    }
}

struct AxisView_Previews: PreviewProvider {
    static var previews: some View {
        AxisView(.horizontal, alignment: .trailing) {
            Text("Test")
        }
        .device()
    }
}
