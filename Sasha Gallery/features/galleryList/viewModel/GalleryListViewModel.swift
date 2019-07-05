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
    
    private let _sortingButtonDidTap = PublishRelay<Void>()
    private let _sortingOption = BehaviorRelay<ListSortingOrder>(value: .normal)
    
    private let _currentLayoutStyle =
        BehaviorRelay<ListLayoutStyle>(value: .normal)
    
    private let _images = BehaviorRelay<[GalleryImage]>(value: [])
    
    init() {
        
        bindRefresh()
    }
}


// MARK: GalleryListViewModel Inputs
extension GalleryListViewModel: GalleryListViewModelInput {
    
    func viewDidLayoutSubviews() {
        _viewIsReady.accept(())
    }
    
    func refreshList() {
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
        return Observable.from([
            _requestLoadData.map{ _ in true },
            images.map{ _ in false }.asObservable()
            ])
            .merge()
            .startWith(true)
            .asDriver(onErrorJustReturn: false)
    }
    
    var newCollectionViewLayout: Driver<UICollectionViewFlowLayout> {
        return Observable.combineLatest( _images.skip(1), _currentLayoutStyle) { data, style in
            let ratios = data.map{ $0.imageRatio }
            switch style {
            case .normal: return MosaicFlowLayoutView(imageRatios: ratios)
            case .horizontal: return HorizontalMosaicFlowLayout(imageRatios: ratios)
            case .vertical: return VerticalMosaicFlowLayout(imageRatios: ratios)
            }
        }
        .distinctUntilChanged()
        .asDriver(onErrorJustReturn: UICollectionViewFlowLayout())
    }
    
    var showSortOrderSelectPopupWithCurrentValue: Signal<String> {
        return _sortingButtonDidTap.compactMap { [weak self] in
            return self?._sortingOption.value.description
        }
        .asSignal(onErrorJustReturn: "")
        .filter{ !$0.isEmpty }
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
            .flatMapLatest { _ in
//               source = "https://www.gettyimagesgallery.com/collection/sasha/"
                return HTMLProvider<GalleryImageList>(urlString: "https://www.gettyimagesgallery.com/collection/sasha/")
                    .loadHTML()
                    .asSignal(onErrorJustReturn: GalleryImageList.empty)
            }
            .map{ $0.images }
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
        case .normal: self = .horizontal
        case .horizontal: self = .vertical
        case .vertical: self = .normal
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
