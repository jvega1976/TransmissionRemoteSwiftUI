//
//  SearchBarView.swift
//  TransmissionRemoteSwiftUI
//
//  Created by  on 2/9/20.
//

import SwiftUI

struct SearchBarView : View {
    @EnvironmentObject var connector: RPCConnector
    @Binding var displaySearch: Bool
    @State private var searchText: String = ""
    public var action: (String)->Void = { _ in }
    
    init(displayed displaySearch:Binding<Bool>, perform action: @escaping (String)->Void = {_ in}) {
        self._displaySearch = displaySearch
        self.action = action
    }
    
    var body: some View {
        HStack(alignment:.center, spacing: 15) {
            #if !os(macOS) || targetEnvironment(macCatalyst)
            Image(systemName: "magnifyingglass")
                .imageScale(.large)
                .foregroundColor(.secondary)
            #else
            Image("search").foregroundColor(.secondary)
            #endif
            TextField("Search",
                      text: $searchText,
                      onEditingChanged: { _ in },
                      onCommit: {
                        self.action(self.searchText)
                        //self.searchText = ""                //self.displaySearch.toggle()
                      })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .shadow(color:.primary, radius: 3)
            if searchText != "" {
                Button(action: {
                    self.searchText = String("")
                }) {
                    #if !os(macOS) || targetEnvironment(macCatalyst)
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(.secondary)
                    #else
                    Image("xmark.circle.fill").foregroundColor(.secondary).opacity(searchText == "" ? 0.0 : 1.0)
                    #endif
                }
            }
        }
        .padding(.all)
    }
}


struct SearchBarView_Previews: PreviewProvider {
    @State static var display: Bool = true

    static func action(text: String)->Void {
        return
    }
    
    static var previews: some View {
        SearchBarView(displayed: $display, perform: action)
            .preferredColorScheme(.dark)
    }
}
