//
//  HTMLCacheTest.swift
//  Sasha GalleryTests
//
//  Created by ParkHyunsoo on 2019/07/06.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import XCTest
import SwiftSoup
@testable import Sasha_Gallery


class HTMLCacheTest: XCTestCase {
    
    
    override func setUp() {}
    
    override func tearDown() {
        HTMLCache.test_shared.clear()
    }
}



fileprivate struct TestHTML: HTMLParsable, Equatable {
    
    struct SubHTML: HTMLParsable, Equatable {
        
        static var cssQuery: String {
            return ""
        }
        
        static var className: String? {
            return nil
        }
        
        private let identifier: Int
        
        init?(element: Element) {
            identifier = Int.random(in: 0..<100000)
        }
        
        init(_ identifier: Int) {
            self.identifier = identifier
        }
        
        static func == (lhs: SubHTML, rhs: SubHTML) -> Bool {
            return lhs.identifier == rhs.identifier
        }
    }
    
    static var cssQuery: String {
        return ""
    }
    
    static var className: String? {
        return nil
    }

    private let subHTML: SubHTML
    var identifier: Int
    
    init?(element: Element) {
        self.identifier = Int.random(in: 0..<100000)
        self.subHTML = SubHTML(element: element)!
    }
    
    init(identifier: Int, subIdentifier: Int) {
        self.identifier = identifier
        self.subHTML = SubHTML(subIdentifier)
    }
    
    static func == (lhs: TestHTML, rhs: TestHTML) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.subHTML == rhs.subHTML
    }
}


fileprivate extension TestHTML {
    
    func isEqualTestHTML(with: HTMLParsable?) -> Bool {
        let right = with as? TestHTML
        return self == right
    }
}


extension HTMLCacheTest {
    
    func test_save_testHTML() {
        
        // given
        let key = "htmlKey"
        let html = TestHTML(identifier: 10, subIdentifier: 93)
        var copied = html
        copied.identifier = 124124
        
        // when
        HTMLCache.test_shared.put(key: key, value: html)
        let cache: TestHTML? = HTMLCache.test_shared.get(key: key)
        
        // then
        XCTAssertNotNil(cache)
        XCTAssertTrue(html.isEqualTestHTML(with: cache))
        XCTAssertFalse(copied.isEqualTestHTML(with: cache))
        
    }
}
