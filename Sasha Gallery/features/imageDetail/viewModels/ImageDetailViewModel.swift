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

final class ImageDetailViewModel: ImageDetailViewModelType {
    
    private let bag = DisposeBag()
    
    private let _viewIsReady = PublishRelay<Void>()
    private let _requestLoadData = PublishRelay<Void>()
    private let _tappedMetaLink = PublishRelay<URL>()
    private let _requestEnquire = PublishRelay<Void>()

    var imageInfo: (pageURL: URL, imageRatio: Float)
    
    init(imageInfo: (pageURL: URL, imageRatio: Float)) {
        self.imageInfo = imageInfo
    }

    
    private lazy var _imageDetail: Signal<ImageDetail> = {
        return _requestLoadData
            .compactMap { [weak self] _ in
                return self?.imageInfo.pageURL
            }
            .flatMapLatest { url in
                return HTMLProvider<ImageDetail>(urlString: url.absoluteString)
                    .loadHTML()
                    .asSignal(onErrorJustReturn: ImageDetail.empty)
            }
            .asSignal(onErrorJustReturn: .empty)
            .asSharedSequence()
    }()
}



// MARK: ImageDetailViewModel Inputs

extension ImageDetailViewModel: ImageDetailViewModelInput {
    
    func viewDidLayoutSubviews() {
        _viewIsReady.accept(())
    }
    
    func refresh() {
        _requestLoadData.accept(())
    }
    
    func metaTagDidTap(link: URL) {
        _tappedMetaLink.accept(link)
    }
    
    func enquireButtonDidTap() {
        _requestEnquire.accept(())
    }
}


// MARK: ImageDetailViewModel Output

extension ImageDetailViewModel: ImageDetailViewModelOutput {
    
    var items: Driver<[ImageDetailCellViewModel?]> {
        return Observable.combineLatest(
            _viewIsReady.take(1),
            _imageDetail.asObservable()
        )
        .compactMap { [weak self] _ , detail in
            guard let self = self else { return nil }
            return CellViewModel.from(fromImageDetail: detail,
                                      ratio: self.imageInfo.imageRatio)
        }
        .startWith([nil, nil, nil, nil])
        .asDriver(onErrorJustReturn: [])
    }
    
    var enquireButtonEnability: Driver<Bool> {
        return Observable.from([
            _requestLoadData.map{ _ in false },
            items.skip(1)
                .map{ values in
                    let isAllDefaultValue = values.compactMap{ $0 }.isEmpty
                    return !isAllDefaultValue
                }.asObservable()
            ])
        .merge()
        .startWith(false)
        .asDriver(onErrorJustReturn: false)
    }
    
    var openURLPage: Signal<URL> {
        return Observable.from([
            _requestEnquire.compactMap{ [weak self] _ in
                return self?.imageInfo.pageURL
            }.asObservable(),
            _tappedMetaLink.asObservable()
        ])
        .merge()
        .asSignal(onErrorJustReturn: URL.empty)
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
