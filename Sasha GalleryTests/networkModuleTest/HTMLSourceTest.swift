//
//  HTMLSourceTest.swift
//  Sasha GalleryTests
//
//  Created by ParkHyunsoo on 2019/07/01.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import XCTest
@testable import Sasha_Gallery

class HTMLSourceTest: XCTestCase {
    
    override func setUp() {}
    
    override func tearDown() {}
}


// MARK: test correct url and data source

extension HTMLSourceTest {
    
    func testCorrectURLAndHTMLSource() {
        
        // given
        let sourceUrlString = "https://www.gettyimagesgallery.com/collection/sasha/"
        let source = HTMLSource(urlString: sourceUrlString)
        
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
        let source = HTMLSource(urlString: sourceUrlString)
        
        // when
        var htmlString: String!
        var error: NetworkError!
        
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
        XCTAssertEqual(error, NetworkError.wrongURL)
        XCTAssertNil(htmlString)
    }
}


// MARK: empty data

extension HTMLSourceTest {
    
    func testEmptyHTMLSource() {
        let sourceUrlString = "wrong"
        let source = HTMLSource(urlString: sourceUrlString)
        
        // when
        var htmlString: String!
        var error: NetworkError!
        
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
        XCTAssertEqual(error, NetworkError.emptyData)
        XCTAssertNil(htmlString)
    }
}
