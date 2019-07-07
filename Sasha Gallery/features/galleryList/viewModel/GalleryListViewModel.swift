//
//  GalleryListViewModel.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/03.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher


//MARK: private and internal properties

final class GalleryListViewModel: GalleryListViewModelType {
    
    private let bag = DisposeBag()
    
    private let _viewIsReady = PublishRelay<Void>()
    private let _requestLoadData = PublishRelay<Bool>()
    private let _isLoading = BehaviorRelay<Bool>(value: false)
    
    private let _requestPreFetch = PublishRelay<[IndexPath]>()
    
    private let _sortingButtonDidTap = PublishRelay<Void>()
    private let _sortingOption = BehaviorRelay<ListSortingOrder>(value: .normal)
    
    private let _currentLayoutStyle =
        BehaviorRelay<ListLayoutStyle>(value: .normal)
    
    private let _images = BehaviorRelay<[GalleryImage]>(value: [])
    
    private let _selectImageIndexPath = PublishRelay<IndexPath>()
    
    var collectionURL: URL
    
    init(collectionURL: URL) {
        self.collectionURL = collectionURL
        
        bindRefresh()
        subscribePreFetchRequest()
    }
}


// MARK: GalleryListViewModel Inputs

extension GalleryListViewModel: GalleryListViewModelInput {
    
    func viewDidLayoutSubviews() {
        _viewIsReady.accept(())
    }
    
    func refreshList(withOutCache: Bool) {
        _requestLoadData.accept(withOutCache)
    }
    
    func requestPreFetches(atIndxPaths: [IndexPath]) {
        _requestPreFetch.accept(atIndxPaths)
    }
    
    func sortingButtonDidTap() {
        _sortingButtonDidTap.accept(())
    }
    
    func newSortingOrderDidSelect(to: ListSortingOrder) {
        _sortingOption.accept(to)
    }
    
    func toggleLayoutStyle() {
        var newValue = _currentLayoutStyle.value
        newValue.toggle()
        _currentLayoutStyle.accept(newValue)
    }
    
    func imageDidSelect(atIndexPath indexPath: IndexPath) {
        _selectImageIndexPath.accept(indexPath)
    }
   
}


// MARK: GalleryListViewModel Outputs

extension GalleryListViewModel: GalleryListViewModelOutput {
    
    // 뷰가 준비되었으면(최촤값) 화면에 보여줄 가장 마지막 이미지 리스트를 정렬기준에따라 정렬하여 방출
    var images: Signal<[GalleryImage]> {
        return Observable.combineLatest(
                _viewIsReady.take(1),
                _images.skip(1),
                _sortingOption
            )
            .map{ _, imgs, option in
                switch option {
                case .title:
                    return imgs.sortByTitle()
                case .newest:
                    return imgs.sortByDate()
                    
                default: return imgs
                }
            }
            .asSignal(onErrorJustReturn: [])
    }
    
    // _isLoading 값을 드라이버로 방출
    var acitivityIndicatorAnimating: Driver<Bool> {
        return _isLoading
            .asDriver(onErrorJustReturn: false)
    }
    
    // 보여질 이미지 리스트값이 변경되거나 레이아웃 스타일 기준이 변경되면 새로운 레이아웃 방출
    var newCollectionViewFlowLayout: Driver<(String, UICollectionViewFlowLayout)> {
        return Observable.combineLatest( _images.skip(1), _currentLayoutStyle) { data, style in
            let ratios = data.map{ $0.imageRatio }
            return (style.buttonTitle, MosaicFlowLayoutView(minColumnWidth: style.rawValue,
                                                            imageRatios: ratios))
        }
        .asDriver(onErrorJustReturn: (ListLayoutStyle.normal.buttonTitle,
                                      UICollectionViewFlowLayout()))
    }
    
    // _sortingButtonDidTap 값이 방출되면 현재 정렬기준값으로 변경하여 방출
    var showSortOrderSelectPopupWithCurrentValue: Signal<String> {
        return _sortingButtonDidTap.compactMap { [weak self] in
            return self?._sortingOption.value.description
        }
        .asSignal(onErrorJustReturn: "")
        .filter{ !$0.isEmpty }
    }
    
    // _selectImageIndexPath값이 방출되면 요청된 위치의 이미지정보를 방출
    var requestPushImageDetailView: Signal<GalleryImage?> {
        return _selectImageIndexPath.compactMap { [weak self] (indexPath: IndexPath) -> GalleryImage? in
            if let self = self, (0..<self._images.value.count) ~= indexPath.row {
                return self._images.value[indexPath.row]
            }
            return nil
        }
        .asSignal(onErrorJustReturn: nil)
    }
}



extension GalleryListViewModel {
    
    var input: GalleryListViewModelInput {
        return self
    }
    
    var output: GalleryListViewModelOutput {
        return self
    }
}



// MARK: internal subscribing

private extension GalleryListViewModel {
    
    func bindRefresh() {
        
        let urlString = self.collectionURL.absoluteString
        
        // _requestLoadData를 내부적으로 구독하여 방출되면 새로운 GalleryImageList 값 요청 -> 결과([GalleryImage]만) 방출
        _requestLoadData
            .do(onNext: { [weak self] _ in
                self?._isLoading.accept(true)
            })
            .flatMapLatest { flag in
                return HTMLProvider<GalleryImageList>(urlString: urlString)
                    .loadHTML(withOutCache: flag)
                    .asSignal(onErrorJustReturn: GalleryImageList.empty)
            }
            .map{ $0.images }
            .do(onNext: { [weak self] _ in
                self?._isLoading.accept(false)
            })
            .bind(to: _images)
            .disposed(by: bag)
    }
    
    private func subscribePreFetchRequest() {
        
        // _requestPreFetch가 방출되면 [IndexPath]를 preFetch 할 [URL]로 변경
        let prefetcInfos: Signal<[URL]> = _requestPreFetch
            .compactMap { [weak self] indexPaths in
                guard let self = self else { return nil }
                
                var sender = [URL]()
                let models = self._images.value
                
                for indexPath in indexPaths {
                    guard (0..<models.count) ~= indexPath.row else { continue }
                    let model = models[indexPath.row]
                    sender.append(model.imageURL)
                }
                
                return sender
            }
            .asSignal(onErrorJustReturn: [])
            .filter{ !$0.isEmpty }
        
        // prefetcInfos를 내부적으로 구독하여 방출시 Kingfisher의 preFetch 시작
        prefetcInfos
            .emit(onNext: { requestURLs in
                let preFetcher = ImagePrefetcher(resources: requestURLs)
                preFetcher.start()
            })
            .disposed(by: bag)
    }
}


// MARK: fileprivate extensions

fileprivate extension GalleryImageList {
    
    static var empty: GalleryImageList {
        return GalleryImageList(images: [])
    }
}


fileprivate extension Array where Element == GalleryImage {
    
    func sortByTitle() -> Array {
        return self.sorted(by: { $0.title < $1.title })
    }
    
    func sortByDate() -> Array {
        return self.sorted(by: { $0.date > $1.date })
    }
}

fileprivate extension ListLayoutStyle {
    
    mutating func toggle() {
        switch self {
        case .normal: self = .zoomIn
        case .zoomIn: self = .zoomOut
        case .zoomOut: self = .normal
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .normal: return "2xn"
        case .zoomIn: return "1xn"
        case .zoomOut: return "nxn"
        }
    }
}


extension ListSortingOrder {
    var description: String {
        switch self {
        case .normal: return "기본"
        case .title: return "이름별"
        case .newest: return "시간별"
        }
    }
}
