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


//MARK: private and internal properties

final class GalleryListViewModel: GalleryListViewModelType {
    
    private let bag = DisposeBag()
    
    private let _viewIsReady = PublishRelay<Void>()
    private let _requestLoadData = PublishRelay<Void>()
    private let _isLoading = BehaviorRelay<Bool>(value: false)
    
    private let _sortingButtonDidTap = PublishRelay<Void>()
    private let _sortingOption = BehaviorRelay<ListSortingOrder>(value: .normal)
    
    private let _currentLayoutStyle =
        BehaviorRelay<ListLayoutStyle>(value: .normal)
    
    private let _images = BehaviorRelay<[GalleryImage]>(value: [])
    
    private let _selectImageIndexPath = PublishRelay<IndexPath>()
    
    init() {
        
        bindRefresh()
    }
}


// MARK: GalleryListViewModel Inputs

extension GalleryListViewModel: GalleryListViewModelInput {
    
    func viewDidLayoutSubviews() {
        _viewIsReady.accept(())
    }
    
    func refreshList(shouldClearCache: Bool) {
        if shouldClearCache {
            HTMLCache.shared.clear()
        }
        _requestLoadData.accept(())
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
    
    
    var acitivityIndicatorAnimating: Driver<Bool> {
        return _isLoading
            .asDriver(onErrorJustReturn: false)
    }
    
    var newCollectionViewFlowLayout: Driver<(String, UICollectionViewFlowLayout)> {
        return Observable.combineLatest( _images.skip(1), _currentLayoutStyle) { data, style in
            let ratios = data.map{ $0.imageRatio }
            return (style.buttonTitle, MosaicFlowLayoutView(minColumnWidth: style.rawValue,
                                                            imageRatios: ratios))
        }
        .asDriver(onErrorJustReturn: (ListLayoutStyle.normal.buttonTitle,
                                      UICollectionViewFlowLayout()))
    }
    
    var showSortOrderSelectPopupWithCurrentValue: Signal<String> {
        return _sortingButtonDidTap.compactMap { [weak self] in
            return self?._sortingOption.value.description
        }
        .asSignal(onErrorJustReturn: "")
        .filter{ !$0.isEmpty }
    }
    
    
    var nextPushViewController: Signal<UIViewController?> {
        return _selectImageIndexPath.compactMap { [weak self] (indexPath: IndexPath) -> GalleryImage? in
            if let self = self, (0..<self._images.value.count) ~= indexPath.row {
                return self._images.value[indexPath.row]
            }
            return nil
        }
        .map { image in
            let nextViewController = ImageDetailViewController.instance
            nextViewController.galleryImage = image
            return nextViewController
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
        
        _requestLoadData
            .do(onNext: { [weak self] in
                self?._isLoading.accept(true)
            })
            .flatMapLatest { _ in
                return HTMLProvider<GalleryImageList>(urlString: "https://www.gettyimagesgallery.com/collection/sasha/")
                    .loadHTML()
                    .asSignal(onErrorJustReturn: GalleryImageList.empty)
            }
            .map{ $0.images }
            .do(onNext: { [weak self] _ in
                self?._isLoading.accept(false)
            })
            .bind(to: _images)
            .disposed(by: bag)
    }
}


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
