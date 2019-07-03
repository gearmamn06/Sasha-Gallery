//
//  VerticalMosaicFlowLayout.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/04.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit

final class VerticalMosaicFlowLayout: MosaicFlowLayoutView {
    
    override var minColumnWidth: CGFloat {
        get {
            return 300
        }
        set{}
    }
}
