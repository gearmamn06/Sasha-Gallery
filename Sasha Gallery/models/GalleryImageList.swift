//
//  GalleryImageList.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/02.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation
import SwiftSoup


struct GalleryImageList {
    
    let images: [GalleryImage]
}


extension GalleryImageList: HTMLParsable {
    
    static var cssQuery: String {
        return "div.grid"
    }
    
    static var className: String? {
        return "grid masonry-grid masonry-view"
    }
    
    init?(element: Element) {
        guard let childs = try? element.select(GalleryImage.cssQuery) else { return nil }
        self.images = childs
            .array()
            .compactMap{ GalleryImage.init(element: $0) }
    }
}
