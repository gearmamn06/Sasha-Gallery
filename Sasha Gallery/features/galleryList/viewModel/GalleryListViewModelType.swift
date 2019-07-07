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


// MARK: 메인리스트에 리스트를 보일 순서

enum ListSortingOrder {
    case normal
    case title
    case newest
}


// MARK: 메인리스트 콜렉션뷰 레이아웃의 셀 크기를 결정

enum ListLayoutStyle: CGFloat {
    case zoomIn = 300
    case normal = 150
    case zoomOut = 100
}


// MARK: GalleryListViewModel - input

protocol GalleryListViewModelInput {
    
    /// ViewController의 viewDidLayoutSubview가 콜되었다는 이벤트 전달
    func viewDidLayoutSubviews()
    
    /// 최초 목록 그리기 요청 및 새로고침 요청이 되었다는 이벤트 전달
    func refreshList(withOutCache: Bool)
    
    /// collectionView prefetch 델리게이션 함수가 콜되었다는 이벤트 전달
    func requestPreFetches(atIndxPaths: [IndexPath])
    
    /// 정렬기준 변경 버튼이 탭되었다는 이벤트 전달
    func sortingButtonDidTap()
    
    /// 유저가 새로운 정렬기준을 선택하였다는 이벤트 전달
    func newSortingOrderDidSelect(to: ListSortingOrder)
    
    /// 목록 레이아웃스타일 변경이 요청되었다는 이벤트 전달
    func toggleLayoutStyle() // -> update layout
    
    /// 리스트내에 이미지가 선택되었다는 이벤트 전달
    func imageDidSelect(atIndexPath indexPath: IndexPath)
}

// MARK: GalleryListViewModel - output

protocol GalleryListViewModelOutput {
    
    /// 현재화면의 로딩과 관련된 인디케이터의 에니메이팅 여부
    var acitivityIndicatorAnimating: Driver<Bool> { get }
    
    /// 목록에 그릴 이미지 모델 어레이
    var images: Signal<[GalleryImage]> { get }
    
    /// 정렬기준 변경 팦업을 현재 정렬기준값과 함께 보여주라는 시그널
    var showSortOrderSelectPopupWithCurrentValue: Signal<String> { get }
    
    /// 콜렉션뷰에 새로 적용할 레이아웃
    var newCollectionViewFlowLayout: Driver<(String, UICollectionViewFlowLayout)> { get }
    
    /// 이미지 상세페이지로 이동하라는 시그널
    var requestPushImageDetailView: Signal<GalleryImage?> { get }
}


// MARK: GalleryListViewModelType = input + output

protocol GalleryListViewModelType {
    
    var collectionURL: URL { get set }
    
    init(collectionURL: URL)
    
    var input: GalleryListViewModelInput { get }
    var output: GalleryListViewModelOutput { get }
}
