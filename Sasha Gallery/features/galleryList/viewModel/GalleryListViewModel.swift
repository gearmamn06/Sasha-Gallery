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
    private let backgroundScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
    
    private let _viewDidLayoutSubviews = PublishRelay<Void>()
    private let _loadData = PublishRelay<Void>()
    
//    private let _sortingButtonDidTap = PublishRelay<Void>()
    private let _sortingOption = BehaviorRelay<ListSortingOrder>(value: .normal)
    
    private let _currentLayoutStyle =
        BehaviorRelay<ListLayoutStyle>(value: .grid)
    
    private let _images = PublishRelay<[GalleryImage]>()
    
    init() {
        
        bindRefresh()
    }
}


// MARK: GalleryListViewModel Inputs
extension GalleryListViewModel: GalleryListViewModelInput {
    
    func viewDidLayoutSubviews() {
        _viewDidLayoutSubviews.accept(())
    }
    
    func refreshList() {
        _loadData.accept(())
    }
    
    func sortingButtonDidTap() {
        
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
                _viewDidLayoutSubviews.take(1),
                _images,
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
            _loadData.map{ _ in true },
            images.map{ _ in false }.asObservable()
            ])
            .merge()
            .startWith(true)
            .asDriver(onErrorJustReturn: false)
    }
    
    var newCollectionViewLayout: Driver<UICollectionViewFlowLayout> {
        return Observable.combineLatest( _images, _currentLayoutStyle) { data, style in
            switch style {
            case .grid:
                return GridFlowLayoutView()
                
            case .mosaic:
                let ratios = data.map{ $0.imageRatio }
                return MosaicFlowLayoutView(imageRatios: ratios)  // TODO: insert ratios
            }
        }
        .distinctUntilChanged()
        .asDriver(onErrorJustReturn: UICollectionViewFlowLayout())
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
        
        _loadData
            .subscribeOn(backgroundScheduler)
            .flatMapLatest { _ in
//               source = "https://www.gettyimagesgallery.com/collection/sasha/"
                return HTMLSource<GalleryImageList>(urlString: "https://www.gettyimagesgallery.com/collection/sasha/")
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
        case .grid: self = .mosaic
        case .mosaic: self = .grid
        }
    }
}
