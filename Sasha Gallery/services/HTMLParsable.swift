//
//  HTMLParsable.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/02.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation
import SwiftSoup


protocol HTMLParsable {
    
    // build current HTML element to HTMLParsable model
    init?(element: Element)
    
    static var cssQuery: String { get }
    static var className: String? { get }
}


// MARK: find target from parent HTML element

extension HTMLParsable {
    
    static func find(inParent element: Element) -> Result<Self, Error> {
        var foundElement: Element?
        if let elements = try? element.select(cssQuery) {
            if let className = className {
                foundElement = elements.first(where: { (try? $0.className()) == className })
            }else{
                foundElement = elements.first()
            }
        }
        
        guard let found = foundElement, let sender = self.init(element: found) else {
            return .failure(NetworkError.notfound)
        }
        
        return .success(sender)
    }
}




