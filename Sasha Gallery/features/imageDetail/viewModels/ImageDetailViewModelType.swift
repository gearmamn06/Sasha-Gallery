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


protocol ImageDetailViewModelInput {
    
    func viewDidLayoutSubviews()
    
    func refresh()
    
    func metaTagDidTap(meta: (key: String, link: URL))
    
    func enquireButtonDidTap()
}

protocol ImageDetailViewModelOutput {
//
    var items: Driver<[ImageDetailCellViewModel?]> { get }
    
    var enquireButtonEnability: Driver<Bool> { get }

    var openURLPage: Signal<URL> { get }
    
    var requestPushCollectionView: Signal<(titile: String, url: URL)> { get }
}


protocol ImageDetailViewModelType {
    
    var imageInfo: (pageURL: URL, imageRatio: Float) { get set }
    
    init(imageInfo: (pageURL: URL, imageRatio: Float))
    
    var input: ImageDetailViewModelInput { get }
    var output: ImageDetailViewModelOutput { get }
}
