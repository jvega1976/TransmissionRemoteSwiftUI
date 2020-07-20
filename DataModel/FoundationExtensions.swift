//
//  FoundationExtensions.swift
//  Transmission Remote
//
//  Created by  on 7/28/19.
//

import Foundation

extension NSObject {
    
    private static var selectedFlag = 0
    
    var dataObject: Any? {
        get {
            return objc_getAssociatedObject(self, &NSObject.selectedFlag)
        }
        set(dataObject) {
            objc_setAssociatedObject(self, &NSObject.selectedFlag, dataObject, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

fileprivate let badChars = CharacterSet.alphanumerics.inverted

extension String {
    
    var snakeCased: String? {
        let pattern = "([a-z0-9])([A-Z])"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: self.count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1-$2").lowercased()
    }
    
    
    
    var uppercasingFirst: String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    var lowercasingFirst: String {
        return prefix(1).lowercased() + dropFirst()
    }
    
    var camelCased: String {
        guard !isEmpty else {
            return ""
        }
        
        let parts = self.components(separatedBy: badChars)
        
        let first = String(describing: parts.first!).lowercasingFirst
        let rest = parts.dropFirst().map({String($0).uppercasingFirst})
        
        return ([first] + rest).joined(separator: "")
    }
}


