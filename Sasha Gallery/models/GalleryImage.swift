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


// MARK: find image ratio using urlString suffix

extension GalleryImage {
    
    var imageRatio: Float{
        
        let urlString = imageURL.absoluteString
        let fullRange = NSRange(urlString.startIndex..., in: urlString)
        
        let pattern = "[0-9]*x[0-9]*.jpg$"
        if let regex = try? NSRegularExpression(pattern: pattern),
            let result = regex.firstMatch(in: urlString, range: fullRange),
            let range = Range(result.range, in: urlString) {
            
            let sizes = urlString[range]
                .replacingOccurrences(of: ".jpg", with: "")
                .split(separator: "x")
            
            if sizes.count == 2, let width = Int(sizes[0]),
                let height = Int(sizes[1]), width > 0 {
                
                return Float(height) / Float(width)
            }
        }

        
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
