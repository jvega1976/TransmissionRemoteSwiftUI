//
//  appState.swift
//  iOS
//
//  Created by Johnny Vega Sosa on 6/24/20.
//

import Foundation
import SwiftUI

class AppState: NSObject, ObservableObject {
    
    static var current: AppState = AppState()
    
    @Published var sizeIsCompact: Bool  {
        didSet {
          self.detailViewIsDisplayed = !self.sizeIsCompact && self.isLandscape
        }
    }

    var isiPhone: Bool = UIDevice.current.userInterfaceIdiom == .phone
    
    @Published var detailViewIsDisplayed: Bool = true
    
    var verticalSizeClass: UserInterfaceSizeClass? = .regular {
        didSet {
            self.sizeIsCompact = verticalSizeClass == .compact || self.horizontalSizeClass == .compact || self.isiPhone
        }
    }
    
    var horizontalSizeClass: UserInterfaceSizeClass? = .regular {
        didSet {
            self.sizeIsCompact = verticalSizeClass == .compact || self.horizontalSizeClass == .compact || self.isiPhone
        }
    }
    
    var isLandscape: Bool = UIScreen.main.bounds.size.width >  UIScreen.main.bounds.size.height
    
    var observeScreen = 0
    
    override public init() {
        sizeIsCompact = false
        sizeIsCompact = false
        detailViewIsDisplayed = true
        self.isLandscape = UIDevice.current.orientation.isLandscape || UIScreen.main.bounds.size.width >  UIScreen.main.bounds.size.height
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateOrientation(_:)), name: UIDevice.orientationDidChangeNotification, object: UIDevice.current)
    }
    
    @objc func updateOrientation(_ notification: Notification) {
        guard let device = notification.object as? UIDevice else { return }
        self.isLandscape = device.orientation.isLandscape || UIScreen.main.bounds.size.width >  UIScreen.main.bounds.size.height
    }
    
}


