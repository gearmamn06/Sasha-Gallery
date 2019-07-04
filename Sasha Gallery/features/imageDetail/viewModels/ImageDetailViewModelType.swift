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
    case productTitle(_ value: String)
    case photographer(_ value: String)
    case collection(title: String, values: [(String, URL)])
    case description(_ value: String)
    
    static func make(fromImageDetail detail: ImageDetail) -> [ImageDetailCellViewModel] {
        return [
            .productTitle(detail.productName),
            .photographer(detail.photographer),
            .collection(title: detail.collection.title,
                        values: detail.collection.values),
            .description(detail.description)
        ]
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
    var items: Driver<[ImageDetailCellViewModel]> { get }
//
//
//    func openWebPage(url: URL)
}


protocol ImageDetailViewModelType {
    
    var input: ImageDetailViewModelInput { get }
    var output: ImageDetailViewModelOutput { get }
}
