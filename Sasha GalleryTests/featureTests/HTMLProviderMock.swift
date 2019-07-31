//
//  HTMLProviderMock.swift
//  Sasha GalleryTests
//
//  Created by ParkHyunsoo on 2019/07/31.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation
@testable import Sasha_Gallery


struct HTMLProviderMock: HTMLProViderType {
    
    
    init(urlString: String) {}
}


extension HTMLProviderMock {
    
    func loadHTMLString(withOutCache: Bool, _ resultCallback: @escaping (Result<String, Error>) -> Void) {
        
        resultCallback(.failure(TestError.def))
    }
    
    func loadHTML<Model: HTMLParsable>(withOutCache: Bool, _ resultCallback: @escaping (Result<Model, Error>) -> Void) {
        
        resultCallback(.failure(TestError.def))
    }
}
