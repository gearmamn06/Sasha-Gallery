//
//  GridFlowLayoutView.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/03.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit


class GridFlowLayoutView: UICollectionViewFlowLayout {
    
    private let minColumnWidth: CGFloat = 150
    private let cellHeight: CGFloat = 170.0
    
    
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        let availWidth = collectionView.bounds.inset(by: collectionView.layoutMargins).width
        let maxColumns = Int(availWidth / minColumnWidth)
        let cellWidth = (availWidth / CGFloat(maxColumns)).rounded(.down)
        
        self.itemSize = CGSize(width: cellWidth, height: cellHeight)
        self.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
        self.sectionInsetReference = .fromSafeArea
    }
}
