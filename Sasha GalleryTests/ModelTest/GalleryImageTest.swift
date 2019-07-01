//
//  GalleryImageTest.swift
//  Sasha GalleryTests
//
//  Created by ParkHyunsoo on 2019/07/02.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import XCTest
import SwiftSoup
@testable import Sasha_Gallery


class GalleryImageTest: XCTestCase {
    
    var node: Element!
    
    override func setUp() {
        
        let htmlString = LocalHTMLSourceReader.read()
        let html = try! SwiftSoup.parse(htmlString)
        node = try! html.select("div.grid-item").first()!
    }
    
    override func tearDown() {
        node = nil
    }
}



extension GalleryImageTest {
    
    
    func test_galleryImageParsing() {
        
        // given
        let imageElement = node!
        
        // when
        let image = GalleryImage(element: imageElement)
        
        // then
        XCTAssertNotNil(image)
    }
}
