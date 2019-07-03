//
//  ImageRatioFindTest.swift
//  Sasha GalleryTests
//
//  Created by ParkHyunsoo on 2019/07/04.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import XCTest
@testable import Sasha_Gallery


class ImageRatioFindTest: XCTestCase {

    
    func test_findImageSize() {
        
        // given
        let imageUrlString = "https://www.gettyimagesgallery.com/wp-content/uploads/2018/12/GettyImages-3360485-1024x802.jpg"
        let image = GalleryImage(title: "", date: Date(),
                                 pageURL: URL(string: "www")!,
                                 imageURL: URL(string: imageUrlString)!)
        
        // when
        let ratio = image.imageRatio
        
        // then
        XCTAssertEqual(ratio, 802/1024)
    }
}
