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
    
    private let bag = DisposeBag()
    
    private let _viewIsReady = PublishRelay<Void>()
    private let _requestLoadData = PublishRelay<Void>()
    
    
    private let pageURL: URL
    private let ratio: Float
    
    init(pageURL: URL, ratio: Float) {
        self.pageURL = pageURL
        self.ratio = ratio
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
            .compactMap { [weak self] _ in
                return self?.pageURL
            }
            .flatMapLatest { url in
                return HTMLProvider<ImageDetail>(urlString: url.absoluteString)
                    .loadHTML()
                    .asSignal(onErrorJustReturn: ImageDetail.empty)
            }
            .startWith(ImageDetail.empty)
            .asDriver(onErrorJustReturn: ImageDetail.empty)
    }
    
    var items: Driver<[ImageDetailCellViewModel?]> {
        return Observable.combineLatest(
            _viewIsReady.take(1),
            _imageDetail.asObservable()
        )
        .compactMap { [weak self] _ , detail in
            guard let self = self else { return nil }
            return CellViewModel.from(fromImageDetail: detail, ratio: self.ratio)
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
