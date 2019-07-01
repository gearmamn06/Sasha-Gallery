//
//  HTMLParser.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/01.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation
import SwiftSoup


struct HTMLParser {
    
    private let sourceURLString: String
    
    init(sourceURLString: String) {
        self.sourceURLString = sourceURLString
    }
}


extension HTMLParser {
    
    func getImageList(html: String) -> Result<[Element], Error> {
        
        guard let document = try? SwiftSoup.parse(html) else {
            return .failure(NetworkError.invalidHtml)
        }

        if let gridContainers = try? document.select("div.grid").array(),
            let gridContainer = gridContainers
                    .first(where: { $0.nonThrowClassName == "grid masonry-grid masonry-view" }),
            let items = try? gridContainer.select("div.grid-item").array() {
            let first = items.first!
            let dataSet = first.dataset()
            print("dataSet: \(dataSet)")
            let href = try? (try? first.select("a"))?.attr("href")
            print("link: \(href)")
            let image = try! first.select("img").first()!
            let src = try! image.attr("data-src")
            print("src: \(src)")
            
            return .success(items)
        }
        
        return .failure(NetworkError.notfound)
    }
    
    
//    func findElement() -> Result<Element, Error> {
//        let result = findElemements()
//        switch result {
//        case .success(let elements):
//            if let first = elements.first {
//                return .success(first)
//            }
//            return .failure(NetworkError.notfound)
//
//        case .failure(let error):
//            return .failure(error)
//        }
//    }
    
    
//    func findElemements() -> Result<[Element], Error> {
//
//    }
    
}


fileprivate extension Element {
    
    var nonThrowClassName: String? {
        return try? self.className()
    }
}
