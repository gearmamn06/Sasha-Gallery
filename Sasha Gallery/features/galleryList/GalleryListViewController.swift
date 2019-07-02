//
//  GalleryListViewController.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/03.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit


class GalleryListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}



extension GalleryListViewController: StoryboardLoadableView {
    
    static var storyboardName: String {
        return "GalleryListView"
    }
}
