//
//  ImageDetailMetaDataCell.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/05.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit


class ImageDetailMetaDataCell: UITableViewCell, ImageDetailViewCellType {
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        return label
    }()
    
    private var hyperLinkTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.contentInset = .zero
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        textView.textColor = UIColor.black
        return textView
    }()
    
    
    var cellViewModel: ImageDetailCellViewModel? {
        didSet {
            guard let viewModel = cellViewModel else { return }
            switch viewModel {
            case .metaData(let title, let hyperLinks):
                titleLabel.text = title
                
                let linkNames = hyperLinks.map{ $0.0 }.reduce("", { names, name in
                    if names.isEmpty {
                        return name
                    }
                    return "\(names), \(name)"
                })
                hyperLinkTextView.attributedText = NSAttributedString(string: linkNames,
                                                                      attributes: [
                                                                        .foregroundColor: UIColor.black
                    ])
                hyperLinks.forEach {
                    hyperLinkTextView.embedHyperLinks(tag: $0.0, url: $0.1)
                }
                
                hyperLinkTextView.delegate = self
                
            default: break
            }
        }
    }
    
    
    var linkDidTap: ((URL) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        addSubview(titleLabel)
        addSubview(hyperLinkTextView)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: hyperLinkTextView.topAnchor, constant: -8)
            ])
        
        NSLayoutConstraint.activate([
            hyperLinkTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            hyperLinkTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            hyperLinkTextView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



extension ImageDetailMetaDataCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.linkDidTap?(URL)
        return false
    }
}
