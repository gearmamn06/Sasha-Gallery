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
    
    func get<T: HTMLParsable>(key: String) -> T? {
        return self.storage.object(forKey: key as NSString) as? T
    }
    
    func put<T: HTMLParsable>(key: String, value: T?) {
        if let value = value {
            storage.setObject(value as AnyObject, forKey: key as NSString)
        }else{
            storage.removeObject(forKey: key as NSString)
        }
    }
    
    func clear() {
        storage.removeAllObjects()
    }
}

