//
//  HTMLSourceTest.swift
//  Sasha GalleryTests
//
//  Created by ParkHyunsoo on 2019/07/01.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import XCTest
@testable import Sasha_Gallery
import SwiftSoup

class HTMLSourceTest: XCTestCase {
    
    override func setUp() {}
    
    override func tearDown() {}
}


fileprivate struct HTMLMockUp: HTMLParsable {
    init?(element: Element) {}
    
    static var cssQuery: String = ""
    
    static var className: String?
}

// MARK: test correct url and data source

extension HTMLSourceTest {
    
    func testCorrectURLAndHTMLSource() {
        
        // given
        let sourceUrlString = "https://www.gettyimagesgallery.com/collection/sasha/"
        let source = HTMLSource<HTMLMockUp>(urlString: sourceUrlString)
        
        // when
        var htmlString: String!
        var error: Error!
        
        let promise = expectation(description: "get HTML Source string from given URL")
        source.loadHTMLString { result in
            switch result {
            case .success(let value):
                htmlString = value
                
            case .failure(let err):
                error = err
            }
            promise.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        // then
        XCTAssertNil(error)
        XCTAssertNotNil(htmlString)
    }
}


// MARK: wrong url source

extension HTMLSourceTest {
    
    func testWrongURLHTMLSource() {
        
        let sourceUrlString = ""
        let source = HTMLSource<HTMLMockUp>(urlString: sourceUrlString)
        
        // when
        var htmlString: String!
        var error: Error!
        
        let promise = expectation(description: "get HTML Source string from given URL")
        source.loadHTMLString { result in
            switch result {
            case .success(let value):
                htmlString = value
                
            case .failure(let err):
                error = err
            }
            promise.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        // then
        XCTAssertNotNil(error)
        XCTAssertNil(htmlString)
    }
}


// MARK: empty data

extension HTMLSourceTest {
    
    func testEmptyHTMLSource() {
        let sourceUrlString = "wrong"
        let source = HTMLSource<HTMLMockUp>(urlString: sourceUrlString)
        
        // when
        var htmlString: String!
        var error: Error!
        
        let promise = expectation(description: "get HTML Source string from given URL")
        source.loadHTMLString { result in
            switch result {
            case .success(let value):
                htmlString = value
                
            case .failure(let err):
                error = err
            }
            promise.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        // then
        XCTAssertNotNil(error)
        XCTAssertNil(htmlString)
    }
}


// MARK: load remote HTML source

extension HTMLSourceTest {
    
    func test_loadRemoteGalleryImageList() {
        
        // given
        let sourceURLString = "https://www.gettyimagesgallery.com/collection/sasha/"
        let source = HTMLSource<GalleryImageList>(urlString: sourceURLString)
        
        // when
        var galleryImageList: GalleryImageList!
        var error: Error!
        
        let promise = expectation(description: "load html and find galleryImage list model")
        source.loadHTML { result in
            switch result {
            case .success(let model):
                galleryImageList = model
                
            case .failure(let err):
                error = err
            }
            promise.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        // then
        XCTAssertNil(error)
        XCTAssertNotNil(galleryImageList)
        XCTAssertFalse(galleryImageList.images.isEmpty)
    }
}
