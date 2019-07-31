//
//  GalleryViewModelTest.swift
//  Sasha GalleryTests
//
//  Created by ParkHyunsoo on 2019/07/31.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import Sasha_Gallery


class GalleryViewModelTest: XCTestCase {
    
    
    private var scheduler: TestScheduler!
    private var bag: DisposeBag!
    
    
    override func setUp() {
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }
    
    
    override func tearDown() {
        scheduler.stop()
        bag = DisposeBag()
    }
}



fileprivate extension GalleryViewModelTest {
    
    func test_indicatorAnimatings() {
        
        // given
        // viewModel setting
        let provider = HTMLProviderMock(urlString: "")
        let viewModel = GalleryListViewModel(provider: provider)
        
        // when
        // initial value -> true
        // not ready + request -> no response
        // ready + request -> true
        // ready + request not end + request -> no response
        // after response -> false
        
        // then
    }
}
