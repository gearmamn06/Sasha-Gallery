//
//  ImageDetailViewModelType.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/05.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


enum ImageDetailCellViewModel {
    case productImage(url: URL, ratio: Float)
    case header(productName: String, photographer: String)
    case metaData(title: String, values: [(String, URL)])
    case description(_ value: String)
    
    static func from(fromImageDetail detail: ImageDetail, ratio: Float) -> [ImageDetailCellViewModel?] {
        if detail.isEmpty {
            return [nil, nil, nil, nil]
        }
        return [
            .productImage(url: detail.productImageURL, ratio: ratio),
            .header(productName: detail.productName,
                    photographer: detail.photographer),
            .metaData(title: detail.collection.title,
                        values: detail.collection.values),
            .description(detail.description)
        ]
    }
    
    static var defaults: [ImageDetailCellViewModel?] {
        return [nil, nil, nil, nil]
    }
}


protocol ImageDetailViewModelInput {
    
    func viewDidLayoutSubviews()
    
    func refresh()
    
//    func metaTagDidTap()
    
//    func enquire()
}

protocol ImageDetailViewModelOutput {
//
    var items: Driver<[ImageDetailCellViewModel?]> { get }
//
//
//    func openWebPage(url: URL)
}


protocol ImageDetailViewModelType {
    
    var input: ImageDetailViewModelInput { get }
    var output: ImageDetailViewModelOutput { get }
}
