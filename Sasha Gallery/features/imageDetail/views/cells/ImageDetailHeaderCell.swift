//
//  ImageDetailTitleCell.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/05.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit


class ImageDetailHeaderCell: ImageDetailViewCell {
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor.black
        return label
    }()
    
    private var photograperLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setUpSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


private extension ImageDetailHeaderCell {
    
    private func setUpSubviews() {
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 24),
            titleLabel.trailingAnchor.constraint(equalToSystemSpacingAfter: trailingAnchor, multiplier: -24),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4)
            ])
        
        addSubview(photograperLabel)
        NSLayoutConstraint.activate([
            photograperLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            photograperLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            photograperLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            photograperLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: 16)
            ])
    }
}




