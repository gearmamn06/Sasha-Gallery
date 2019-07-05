//
//  ImageDetailImageCell.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/05.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit


class ImageDetailImageCell: UITableViewCell, ImageDetailViewCellType {
    
    
    var cellViewModel: ImageDetailCellViewModel? {
        didSet {
            guard let viewModel = cellViewModel else {
                // TODO: set loading effect or not..
                return
            }
            
            
        }
    }
}

