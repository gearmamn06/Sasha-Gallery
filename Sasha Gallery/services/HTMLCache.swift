//
//  HTMLCache.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/06.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation


class HTMLCache {
    
    
    private init() {}
    
    private static var _shared: HTMLCache!
    
    private var storage = NSCache<NSString, AnyObject>()
    
    static var shared: HTMLCache {
        if _shared == nil {
            _shared = HTMLCache()
        }
        return _shared
    }
    static let test_shared = HTMLCache()
}


// MARK: interface

extension HTMLCache {
    
    subscript(key: String) -> HTMLParsable? {
        get {
            return self.storage.object(forKey: key as NSString) as? HTMLParsable
        }
        set {
            if let newValue = newValue {
                self.storage.setObject(newValue as AnyObject, forKey: key as NSString)
            }else{
                self.storage.removeObject(forKey: key as NSString)
            }
        }
    }
    
    func clear() {
        storage.removeAllObjects()
    }
}

