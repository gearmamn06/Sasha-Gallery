//
//  MosaicFlowLayoutView.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/03.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit


open class MosaicFlowLayoutView: UICollectionViewFlowLayout {
    
    // properties for cellSizing
    var minColumnWidth: CGFloat = 150
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionview = collectionView else { return 0 }
        
        let insets = collectionview.contentInset
        return collectionview.bounds.width - (insets.left + insets.right)
    }
    
    open override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    private var cache = [UICollectionViewLayoutAttributes]()
    
    private let imageRatios: [Float]
    
    init(imageRatios: [Float]) {
        self.imageRatios = imageRatios
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



extension MosaicFlowLayoutView {
    
    
    func clearCache() {
        self.cache.removeAll()
    }
    
    override open func prepare() {
        
        guard cache.isEmpty, let collectionView = collectionView else { return }
        
        let numberOfColumns = (contentWidth / minColumnWidth).int
        let columnWidth = (contentWidth / numberOfColumns.cg).rounded(.down)
        
        let xOffsets = (0..<numberOfColumns).map{ $0.cg * columnWidth }
        
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(row: item, section: 0)
            
            let imageRatio = (0..<imageRatios.count) ~= item ? imageRatios[item] : 0
            let imageHeight = columnWidth * imageRatio.cg
            
            let frame = CGRect(x: xOffsets[column], y: yOffset[column],
                               width: columnWidth, height: imageHeight)
                            .inset(by: .zero)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)
            
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + imageHeight
            
            column = (column + 1) % numberOfColumns
        }
    }
    
    
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
