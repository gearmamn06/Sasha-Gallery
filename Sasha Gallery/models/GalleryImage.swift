//
//  GalleryImage.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/02.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation
import SwiftSoup

struct GalleryImage {
    
    let title: String
    let date: Date
    let pageURL: URL
    let imageURL: URL
}


extension GalleryImage: HTMLParsable {
    
    static var cssQuery: String {
        return "div.grid-item"
    }
    
    static var className: String? {
        return "image-item col-md-4"
    }
    
    init?(element: Element) {
        
        guard let title = try? element.attr("data-title") else  {
            return nil
        }
        self.title = title
        
        guard let dateString = try? element.attr("data-date"),
            let date = dateString.toDate() else {
            return nil
        }
        self.date = date
        
        guard let a = try? element.select("a").first(), let href = try? a.attr("href"),
            let pageURL = URL(string: href) else {
                return nil
        }
        self.pageURL = pageURL
        
        guard let img = try? element.select("img").first(),
            let src = try? img.attr("data-src"),
            let imageURL = URL(string: src) else {
                return nil
        }
        self.imageURL = imageURL
    }
}


extension GalleryImage {
    
    var imageRatio: Float{
        return 0
    }
}


fileprivate extension String {
    
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.date(from: self)
    }
}
