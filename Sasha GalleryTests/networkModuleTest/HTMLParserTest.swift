//
//  HTMLParserTest.swift
//  Sasha GalleryTests
//
//  Created by ParkHyunsoo on 2019/07/01.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import XCTest
import SwiftSoup
@testable import Sasha_Gallery


class HTMLParserTest: XCTestCase {
    
    override func setUp() {}
    
    override func tearDown() {}
}


extension HTMLParserTest {
    
    func testFindgalleryListContainer() {
        
        // given
        let html = LocalHTMLSourceReader.read()
        
        // when
        let parser = HTMLParser(sourceURLString: "")
        let parseResult = parser.getImageList(html: html)
        
        // then
        switch parseResult {
        case .success(let items):
            XCTAssertEqual(items.count, 140)
            
        case .failure(let error):
            XCTAssertNil(error)
        }
    }
}
