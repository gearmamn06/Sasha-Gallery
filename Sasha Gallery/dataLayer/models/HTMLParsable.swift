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
        // cssQuery와 만족하는 element 검색
        if let elements = try? element.select(cssQuery) {
            // className 값이 존재하다면 elements 중 클래스이름이 일치하는것 검사
            // 일치하는것이 있다면 검색 완료, 없다면 가장 첫번째 element
            if let className = className {
                foundElement = elements.first(where: { (try? $0.className()) == className })
            }else{
                foundElement = elements.first()
            }
        }
        
        guard let found = foundElement, let sender = self.init(element: found) else {
            return .failure(CommonError.notfound)
        }
        
        return .success(sender)
    }
}




