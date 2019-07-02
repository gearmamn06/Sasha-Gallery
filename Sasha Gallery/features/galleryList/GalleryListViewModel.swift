//
//  GalleryListViewModel.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/03.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


//MARK: private and internal properties

final class GalleryListViewModel: GalleryListViewModelType {
    
    private let bag = DisposeBag()
    private let backgroundScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
    
    private let _viewDidLayoutSubviews = PublishRelay<Void>()
    private let _loadData = PublishRelay<Void>()
    
//    private let _sortingButtonDidTap = PublishRelay<Void>()
//    private let _sortingOption = BehaviorRelay<ListSortingOrder>(value: .normal)
//    private let _currentLayoutStyle = BehaviorRelay
    
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
        
    }
   
}


// MARK: GalleryListViewModel Outputs

extension GalleryListViewModel: GalleryListViewModelOutput {
    
    var images: Signal<[GalleryImage]> {
        return Observable.combineLatest(
                _viewDidLayoutSubviews.take(1),
                _images
            )
            .map{ _, imgs in imgs }
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
                return HTMLSource<GalleryImageList>(urlString: "https://www.gettyimagesgallery.com/collection/sasha/")
                    .loadHTML()
                    .asSignal(onErrorJustReturn: GalleryImageList.empty)
            }
            .map{ $0.images }
            .debug()
            .bind(to: _images)
            .disposed(by: bag)
    }
}


fileprivate extension GalleryImageList {
    
    static var empty: GalleryImageList {
        return GalleryImageList(images: [])
    }
}
