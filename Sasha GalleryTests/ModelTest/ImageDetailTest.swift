//
//  ImageDetailTest.swift
//  Sasha GalleryTests
//
//  Created by ParkHyunsoo on 2019/07/04.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import XCTest
import SwiftSoup
@testable import Sasha_Gallery


class ImageDetailTest: XCTestCase {
    
    override func setUp() {}
    
    override func tearDown() {}
}


extension ImageDetailTest {
    
    func test_imageDetailParsing() {
        
        // given
        let htmlString = LocalHTMLSourceReader.read(fileName: "imageDetail")
        let document = try! SwiftSoup.parse(htmlString)
        let node = try! document.select(ImageDetail.cssQuery).first()!
        
        // when
        let imageDetail = ImageDetail(element: node)
        
        
        // then
        XCTAssertNotNil(imageDetail)
    }
    
    func test_imageDetailFinding() {
        
        // given
        let urlString = "https://www.gettyimagesgallery.com/images/astaires-and-hanson/?collection=sasha"
        let provider = HTMLProvider<ImageDetail>(urlString: urlString)
        
        // when
        var error: Error!
        var imageDetail: ImageDetail!
        
        let promise = expectation(description: "load html and find image detail data")
        provider.loadHTML { result in
            switch result {
            case .success(let value):
                imageDetail = value
                
            case .failure(let err):
                error = err
            }
            promise.fulfill()
        }
        
        waitForExpectations(timeout: 500, handler: nil)
        
        // then
        XCTAssertNil(error)
        XCTAssertNotNil(imageDetail)
    }
}
