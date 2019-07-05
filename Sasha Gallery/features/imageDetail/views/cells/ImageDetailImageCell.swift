//
//  ImageDetailImageCell.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/05.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit
import Kingfisher


class ImageDetailImageCell: UITableViewCell, ImageDetailViewCellType {
    
    fileprivate enum Metric {
        static let defaultScaleRatio: CGFloat = 0.6
    }
    
    private var productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.kf.indicatorType = .activity
        return imageView
    }()
    
    private var scaleRatioConstraint: NSLayoutConstraint? {
        didSet {
            if let old = oldValue {
                productImageView.removeConstraint(old)
            }
            if let newValue = scaleRatioConstraint {
                productImageView.addConstraint(newValue)
            }
        }
    }
    
    
    var cellViewModel: ImageDetailCellViewModel? {
        didSet {
            guard let viewModel = cellViewModel else {
                updateImageViewConstraint(ratio: Metric.defaultScaleRatio)
                productImageView.kf.indicator?.startAnimatingView()
                return
            }
            switch viewModel {
            case .productImage(let url, let ratio):
                updateImageViewConstraint(ratio: CGFloat(ratio))
                let size = CGSize(width: self.bounds.width,
                                  height: self.bounds.width * CGFloat(ratio))
                downloadAndDisplayImage(url: url, expectedSize: size)
            default: break
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = UIColor.black
        
        addSubview(productImageView)
        productImageView.contentMode = .scaleAspectFill
        
        NSLayoutConstraint.activate([
            productImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            productImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            productImageView.topAnchor.constraint(equalTo: self.topAnchor),
            productImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



extension ImageDetailImageCell {
    
    
    private func updateImageViewConstraint(ratio: CGFloat) {
        let constraint = NSLayoutConstraint(item: productImageView,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: productImageView,
                                            attribute: .width,
                                            multiplier: ratio,
                                            constant:  0.0)
        constraint.priority = UILayoutPriority(rawValue: 999)
        self.scaleRatioConstraint = constraint
    }
    
    
    private func downloadAndDisplayImage(url: URL, expectedSize: CGSize) {
        
        
        let processor = DownsamplingImageProcessor(size: expectedSize)
        productImageView.kf.setImage(with: url, options: [
            .scaleFactor(UIScreen.main.scale),
            .transition(.fade(1)),
            .processor(processor)
        ]) { [weak self] _ in
            self?.productImageView.kf.indicator?.stopAnimatingView()
        }
    }
}

