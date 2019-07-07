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
    private let _requestLoadData = PublishRelay<Bool>()
    private let _tappedMetaLink = PublishRelay<(String, URL)>()
    private let _requestEnquire = PublishRelay<Void>()

    var imageInfo: (pageURL: URL, imageRatio: Float)
    
    init(imageInfo: (pageURL: URL, imageRatio: Float)) {
        self.imageInfo = imageInfo
    }

    
    private lazy var _imageDetail: Signal<ImageDetail> = {
        return _requestLoadData
            .compactMap { [weak self] withoutCache in
                guard let self = self else { return nil }
                return (withoutCache, self.imageInfo.pageURL)
            }
            .flatMapLatest { (withoutCache: Bool, url: URL) in
                return HTMLProvider<ImageDetail>(urlString: url.absoluteString)
                    .loadHTML(withOutCache: withoutCache)
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
    
    func refresh(withOutCache: Bool) {
        _requestLoadData.accept(withOutCache)
    }
    
    func metaTagDidTap(meta: (key: String, link: URL)) {
        _tappedMetaLink.accept((meta.key, meta.link))
    }
    
    func enquireButtonDidTap() {
        _requestEnquire.accept(())
    }
}


// MARK: ImageDetailViewModel Output

extension ImageDetailViewModel: ImageDetailViewModelOutput {
    
    // 뷰가 준비되었으면(최촤값) 가장 마지막 이미지 정보를 바탕으로 셀뷰모델 방출
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
        .filter{ !$0.isEmpty }
    }
    
    // 로딩이 요청되었다면 -> 비활성화 / 초기값 제외 셀뷰모델이 갱신되었다면 -> 활성화
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
    
    // _requestEnquire이 방출되면 이미지 세부정보 URL로 변환하여 방출
    var openURLPage: Signal<URL> {
        return _requestEnquire.compactMap{ [weak self] _ in
            return self?.imageInfo.pageURL
        }.asSignal(onErrorJustReturn: URL.empty)
        .filter { !$0.isEmpty }
    }
    
    // _tappedMetaLink가 방툴되었다면 콜렉션 타이틀과, URL 튜플로 반환하여 방출
    var requestPushCollectionView: Signal<(titile: String, url: URL)> {
        return _tappedMetaLink
            .asSignal(onErrorJustReturn: ("", URL.empty))
            .filter{ !$0.0.isEmpty && !$0.1.isEmpty }
            .map{ (titile: $0.0, url: $0.1) }
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
