//
//  ImageDetailViewModelType.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/05.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


// MARK: ImageDetailViewModel inputs

protocol ImageDetailViewModelInput {
    
    /// ViewController의 viewDidLayoutSubview가 콜되었다는 이벤트 전달
    func viewDidLayoutSubviews()
    
    /// 최초 목록 그리기 요청 및 새로고침 요청이 되었다는 이벤트 전달
    func refresh(withOutCache: Bool)
    
    /// collection 태그가 탭되었다는 이벤트 전달
    func metaTagDidTap(meta: (key: String, link: URL))
    
    /// enquire button이 탭되었다는 이벤트 전달
    func enquireButtonDidTap()
}


// MARK: ImageDetailViewModel Outputs

protocol ImageDetailViewModelOutput {
    
    /// 화면에 보여질 이미지 세부정보 셀 모델의 어레이
    var items: Driver<[ImageDetailCellViewModel?]> { get }
    
    /// enquireButton의 enable 속성
    var enquireButtonEnability: Driver<Bool> { get }

    /// 열어야하는 앱페이지 시그날
    var openURLPage: Signal<URL> { get }
    
    /// collectionView(GalleryListView)로의 이동하라는 시그널
    var requestPushCollectionView: Signal<(titile: String, url: URL)> { get }
}


// MARK: ImageDetailViewModelType = Input + Output

protocol ImageDetailViewModelType {
    
    var imageInfo: (pageURL: URL, imageRatio: Float) { get set }
    
    init(imageInfo: (pageURL: URL, imageRatio: Float))
    
    var input: ImageDetailViewModelInput { get }
    var output: ImageDetailViewModelOutput { get }
}
