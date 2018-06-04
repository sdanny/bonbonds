//
//  UIApplication.swift
//  news
//
//  Created by Daniyar Salakhutdinov on 20.05.2018.
//  Copyright © 2018 Daniyar Salakhutdinov. All rights reserved.
//

import UIKit
import JavaScriptCore

@objc protocol SelfAware: class {
    static func awake()
}

fileprivate class SwizzlingPoint {
    
    static func run() {
        // gets the project objc classes count
        let typeCount = Int(objc_getClassList(nil, 0))
        // objc classes list
        let types = UnsafeMutablePointer<AnyClass?>.allocate(capacity: typeCount)
        let autoreleasingTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
        objc_getClassList(autoreleasingTypes, Int32(typeCount))
        // iterate
        for index in 0 ..< typeCount {
            guard let type = types[index] else { continue }
            if class_conformsToProtocol(type, SelfAware.self) {
                let item = type as! SelfAware.Type
                item.awake()
            }
        }
        types.deallocate()
    }
}

extension UIApplication {
    
    private static let runOnce: Void = {
        SwizzlingPoint.run()
    }()
    
    override open var next: UIResponder? {
        UIApplication.runOnce
        return super.next
    }
    
}
