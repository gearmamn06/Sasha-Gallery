//
//  ImageDetailViewModel.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/05.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


fileprivate typealias CellViewModel = ImageDetailCellViewModel

// MARK: private and internal properties

class ImageDetailViewModel: ImageDetailViewModelType {
    
    private let _viewIsReady = PublishRelay<Void>()
    private let _requestLoadData = PublishRelay<Void>()
    
    
    private let productName: String
    init(productName: String) {
        self.productName = productName
    }
}



// MARK: ImageDetailViewModel Inputs

extension ImageDetailViewModel: ImageDetailViewModelInput {
    
    func viewDidLayoutSubviews() {
        _viewIsReady.accept(())
    }
    
    func refresh() {
        _requestLoadData.accept(())
    }
}


// MARK: ImageDetailViewModel Output

extension ImageDetailViewModel: ImageDetailViewModelOutput {
    
    private var _imageDetail: Driver<ImageDetail> {
        return _requestLoadData
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest { _ in
                return HTMLProvider<ImageDetail>(urlString: "")
                    .loadHTML()
                    .asSignal(onErrorJustReturn: ImageDetail.empty)
            }
//            .startWith(ImageDetail.empty)
            .asDriver(onErrorJustReturn: ImageDetail.empty)
    }
    
    var items: Driver<[ImageDetailCellViewModel]> {
        return Observable.combineLatest(
            _viewIsReady.take(1),
            _imageDetail.asObservable()
        )
        .map { _, detail in
            return CellViewModel.make(fromImageDetail: detail)
        }
        .asDriver(onErrorJustReturn: [])
    }
    
    var showLoadingEffect: Driver<Bool> {
        return Observable.from([
            _requestLoadData.map{ _ in true },
            items.map{ _ in false }.asObservable()
            ])
        .merge()
        .startWith(true)
        .asDriver(onErrorJustReturn: false)
    }
}


// MARK: ImageDetailViewMOdel IO

extension ImageDetailViewModel {
    
    var input: ImageDetailViewModelInput {
        return self
    }
    
    var output: ImageDetailViewModelOutput {
        return self
    }
}



fileprivate extension ImageDetail.ProductMeta {
    private init() {
        self.title = ""
        self.values = []
    }
    
    static var empty: ImageDetail.ProductMeta {
        return ImageDetail.ProductMeta()
    }
}


fileprivate extension ImageDetail {
    
    private init() {
        self.productName = ""
        self.photographer = ""
        self.productImageURL = URL(string: "www")!
        self.collection = ImageDetail.ProductMeta.empty
        self.description = ""
    }
    
    static var empty: ImageDetail {
        return ImageDetail()
    }
}
