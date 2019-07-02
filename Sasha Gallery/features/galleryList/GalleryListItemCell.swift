//
//  GalleryListItemCell.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/03.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit
import Kingfisher


final class GalleryListItemCell: UICollectionViewCell {
    
    private var imageView: UIImageView = {
        let sender = UIImageView()
        sender.translatesAutoresizingMaskIntoConstraints = false
        sender.contentMode = .scaleAspectFill
        return sender
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



// MARK: setUp imageView

extension GalleryListItemCell {
    
    func setUpSubViews(url: URL) {
        self.imageView.kf.setImage(with: url)
    }
}
