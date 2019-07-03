//
//  GalleryListViewModelType.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/03.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


enum ListSortingOrder {
    case normal
    case title
    case newest
}

enum ListLayoutStyle {
    case normal
    case horizontal
    case vertical
}


protocol GalleryListViewModelInput {
    
    // list updating trigger
    func viewDidLayoutSubviews()
    
    // refresh datasource and update list
    func refreshList()
    
    // 소팅옵션 변경 요청
    func sortingButtonDidTap()
    // 새로운 소팅기준 선택됨
    func newSortingOrderDidSelect(to: ListSortingOrder) // -> update dataSource
    
    // toogle current layout style
    func toggleLayoutStyle() // -> update layout
}

protocol GalleryListViewModelOutput {
    
    var acitivityIndicatorAnimating: Driver<Bool> { get }
    
    var images: Signal<[GalleryImage]> { get }
    
    var showSortOrderSelectPopupWithCurrentValue: Signal<String> { get }
    
    var newCollectionViewLayout: Driver<UICollectionViewFlowLayout> { get }
}


protocol GalleryListViewModelType {
    
    var input: GalleryListViewModelInput { get }
    var output: GalleryListViewModelOutput { get }
}
