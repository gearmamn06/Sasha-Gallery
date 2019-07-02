//
//  SashaGalleryUsecase.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/02.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation


enum SashaGalleryUsecase {
    case mainList
    case detail(artWorkName: String)
}


extension SashaGalleryUsecase {
    
    var contentURLString: String {
        switch self {
        case .mainList:
            return "https://www.gettyimagesgallery.com/collection/sasha/"
        case .detail(let artWorkName):
            return "https://www.gettyimagesgallery.com/images/\(artWorkName)/?collection=sasha"
        }
    }
}
