//
//  URL.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/06.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation


extension URL {
    
    private static var emptyURLKey: String {
        return "http://www.thisiemptyurl.com"
    }
    
    static var empty: URL {
        return URL(string: emptyURLKey)!
    }
    
    var isEmpty: Bool {
        return self.absoluteString == URL.emptyURLKey
    }
}
