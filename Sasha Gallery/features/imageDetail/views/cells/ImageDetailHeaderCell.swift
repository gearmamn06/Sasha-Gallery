//
//  ImageDetailTitleCell.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/05.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit


class ImageDetailHeaderCell: UITableViewCell, ImageDetailViewCellType {
    

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private var photograperLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        return label
    }()
    
    var cellViewModel: ImageDetailCellViewModel? {
        didSet {
            guard let viewModel = cellViewModel else  { return }
            switch viewModel {
            case .header(let name, let photographer):
                titleLabel.text = name
                photograperLabel.text = photographer
                
            default: break
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        addSubview(titleLabel)
        addSubview(photograperLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 28),
            titleLabel.bottomAnchor.constraint(equalTo: photograperLabel.topAnchor, constant: -16)
            ])
        
        NSLayoutConstraint.activate([
            photograperLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            photograperLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            photograperLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8)
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
