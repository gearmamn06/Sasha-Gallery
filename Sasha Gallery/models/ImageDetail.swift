//
//  ImageDetail.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/04.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation
import SwiftSoup


struct ImageDetail {
    
    struct ProductMeta {
        let title: String
        let values: [(String, URL)]
    }
    
    let productImageURL: URL
    let productName: String
    let photographer: String
    let collection: ProductMeta
    let description: String
}


extension ImageDetail: HTMLParsable {
    
    static var cssQuery: String {
        return "div.content-wrapper"
    }
    
    static var className: String? {
        return "content-wrapper main-content-wrapper"
    }
    
    init?(element: Element) {
        // set productImageURL
        guard let imageElement = try? element.select("div.product-image").first(),
            let img = try? imageElement.select("img").first(),
            let src = try? img.attr("src"),
            let url = URL(string: src) else {
                return nil
        }
        productImageURL = url
        
        // get productInfo element
        guard let productInfoElement = try? element.select("div.col-md-4").first() else {
            return nil
        }
        
        // set product title
        guard let titleHeader = try? productInfoElement.select("h1.product-title").first(),
            let title = try? titleHeader.text()  else {
            return nil
        }
        self.productName = title
        
        // set photographer
        guard let photographerHeader = try? productInfoElement.select("h3.photographer").first(),
            let photographer = try? photographerHeader.text() else {
            return nil
        }
        self.photographer = photographer
        
        // get product-meta element -> filtering(meta-value ==> a href)
        guard let metaElements = try? productInfoElement.select("div.product-meta"),
            let collection = metaElements.compactMap({ ProductMeta(element: $0) }).first else {
            return nil
        }
        self.collection = collection
        
        // set description
        guard let contentElement = try? productInfoElement.select("div.product-content").first(),
            let description = try? contentElement.select("p").first()?.text() else {
                return nil
        }
        self.description = description
    }
}


extension ImageDetail.ProductMeta: HTMLParsable {
    
    static var cssQuery: String {
        return "div.product-mata"
    }
    
    static var className: String? {
        return nil
    }
    
    init?(element: Element) {
        
        // set title of meta-value
        guard let title = try? element.select("span.meta-title").first()?.text() else {
            return nil
        }
        self.title = title
        
        // get value elemnets(only a href format)
        guard let valueElements = try? element.select("span.meta-value").select("a") else {
            return nil
        }
        // convert a href element to tupple(name: String, href: URL)
        let values: [(String, URL)] = valueElements.compactMap { valueElement in
            guard let link = try? valueElement.attr("href"), let linkURL = URL(string: link),
                let tag = try? valueElement.text() else {
                    return nil
            }
            return (tag, linkURL)
        }
        guard !values.isEmpty else { return nil }
        self.values = values
    }
}



extension ImageDetail.ProductMeta {
    private init() {
        self.title = ""
        self.values = []
    }
    
    static var empty: ImageDetail.ProductMeta {
        return ImageDetail.ProductMeta()
    }
    
    var isEmpty: Bool {
        return self.title.isEmpty
            && values.isEmpty
    }
}


extension ImageDetail {
    
    private init() {
        self.productName = ""
        self.photographer = ""
        self.productImageURL = URL.empty
        self.collection = ImageDetail.ProductMeta.empty
        self.description = ""
    }
    
    static var empty: ImageDetail {
        return ImageDetail()
    }
    
    var isEmpty: Bool {
        return productName.isEmpty
            && photographer.isEmpty
            && productImageURL.isEmpty
            && collection.isEmpty
            && description.isEmpty
    }
}
