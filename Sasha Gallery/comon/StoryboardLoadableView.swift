//
//  StoryboardLoadableView.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/03.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit

protocol StoryboardLoadableView {
    
    static var storyboardName: String { get }
}

extension StoryboardLoadableView {
    
    static var storyboardName: String {
        return "Main"
    }
}



extension StoryboardLoadableView where Self: UIViewController {
    
    private static var name: String {
        return String(describing: self)
    }
    
    static var instance: Self {
        let storyBoard = UIStoryboard(name: self.storyboardName, bundle: nil)
        return storyBoard.instantiateViewController(withIdentifier: self.name) as! Self
    }
}
