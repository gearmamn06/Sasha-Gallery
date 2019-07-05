//
//  UITextView+Extension.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/06.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit

extension UITextView {
    
    func embedHyperLinks(tag: String, url: URL) {
        guard let attrText = self.attributedText,
            let range = attrText.string.range(of: tag) else { return }
        
        let nsRange = NSRange(range, in: attrText.string)
        print(nsRange)
        
        let fullAttributedText = NSMutableAttributedString(attributedString: attrText)
        fullAttributedText.addAttribute(.link, value: url, range: nsRange)
        
        
        self.attributedText = fullAttributedText
    }
}

