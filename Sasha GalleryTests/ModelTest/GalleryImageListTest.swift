//
//  GalleryImageListTest.swift
//  Sasha GalleryTests
//
//  Created by ParkHyunsoo on 2019/07/02.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import XCTest
import SwiftSoup
@testable import Sasha_Gallery


class GalleryImageListTest: XCTestCase {
    
    var html: Element!
    
    override func setUp() {
        let htmlString = LocalHTMLSourceReader.read()
        self.html = try! SwiftSoup.parse(htmlString)
    }
    
    override func tearDown() {
        html = nil
    }
}



extension GalleryImageListTest {
    
    func test_galleryImageListParsing() {
        
        // given
        let element = try! html.select("div.grid").first()!
        
        // when
        let list = GalleryImageList(element: element)
        
        // then
        XCTAssertNotNil(list)
        XCTAssertFalse(list?.images.isEmpty ?? true)
    }
    
    
    func test_galleryListFinding() {
        
        // given
        let document = self.html!
        
        // when
        let result = GalleryImageList.find(inParent: document)
        
        // then
        switch result {
        case .success(let list):
            XCTAssertEqual(list.images.isEmpty, false)
            
        case .failure:
            XCTAssertTrue(false)
        }
    }
}
