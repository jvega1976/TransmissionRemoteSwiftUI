//
//  CategoriesView.swift
//  TransmissionRemoteSwiftUI
//
//  Created by  on 2/9/20.
//

import SwiftUI

struct CategoriesView: View, Equatable {
    
    static func == (lhs: CategoriesView, rhs: CategoriesView) -> Bool {
        lhs.startAnimation == rhs.startAnimation
    }
    
    
    @EnvironmentObject var connector: RPCConnector
    @EnvironmentObject var appState: AppState
    @State var startAnimation: Bool = false
    
    var body: some View {
        List {
            ScrollView(.horizontal,showsIndicators: false, content: {
                HStack(alignment:.center, spacing: self.appState.sizeIsCompact || ( self.appState.detailViewIsDisplayed) ? 0 : 15) {
                    ForEach(self.connector.categorization.categories) { category in
                        ZStack(alignment: .topTrailing) {
                            VStack(alignment: .center) {
                                Button(action: {
                                    self.connector.categorization.selectedCategoryIndex = self.connector.categorization.categories.firstIndex(of: category)!
                                }) {
                                    if self.appState.sizeIsCompact || ( self.appState.detailViewIsDisplayed)  {
                                        TorrentIcon(type: category.iconType, color: category.iconColor)
                                            .frame(width: TrIconPadSlideSize.width , height:  TrIconPadSlideSize.height , alignment: .center)
                                            .fixedSize()
                                   }
                                   else  {
                                        TorrentIcon(type: category.iconType, color: category.iconColor)
                                            .frame(width: TrIconPadSize.width , height:  TrIconPadSize.height , alignment: .center)
                                         .fixedSize()
                                    }
                                }
                                    Text(category.title)
                                        .deviceFont()
                                        .allowsTightening(true)
                                        .minimumScaleFactor(0.50)
                                        .scaledToFill()
                                        .multilineTextAlignment(.center)
                                        .frame(width: filterHeight)
                            }
                            Text(String(self.connector.categorization.numberOfItemsInCategory(withTitle: category.title)))
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.systemTeal)
                                .multilineTextAlignment(.leading)
                                .offset(x: 1.2, y: 1.2)
                                .opacity(0.8)
                            Text(String(self.connector.categorization.numberOfItemsInCategory(withTitle: category.title)))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
            })
        }
        .frame(height: filterHeight)
        .animation(.default)
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
            .frame(height: 80)
    }
}
