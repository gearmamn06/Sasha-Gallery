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
    case grid
    case mosaic
}


protocol GalleryListViewModelInput {
    
    // list updating trigger
    func viewDidLayoutSubviews()
    
    // refresh datasource and update list
    func refreshList()
    
//    func sortingButtonDidTap() // -> 어떻게 정렬기준 보여줄지 결정 -> output 행동
    func newSortingOrderDidSelect(to: ListSortingOrder) // -> update dataSource
    
    // toogle current layout style
    func toggleLayoutStyle() // -> update layout
}

protocol GalleryListViewModelOutput {
    
    var acitivityIndicatorAnimating: Driver<Bool> { get }
    
    var images: Signal<[GalleryImage]> { get }
    
//    var errorMessage: Signal<String> { get }
    
    var newCollectionViewLayout: Driver<UICollectionViewFlowLayout> { get }
}


protocol GalleryListViewModelType {
    
    var input: GalleryListViewModelInput { get }
    var output: GalleryListViewModelOutput { get }
}
