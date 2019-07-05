//
//  ImageDetailViewCell.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/05.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit

protocol ImageDetailViewCellType: class {
    
    var cellViewModel: ImageDetailCellViewModel? { get set }
}
