//
//  LaunchViewController.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/06.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.moveToNextViewController()
        })
    }
    
    
    private func moveToNextViewController() {
        
        let nextViewController = GalleryListViewController.instance
        nextViewController.title = "Sasha"
        nextViewController.collectionURL = URL(string: "https://www.gettyimagesgallery.com/collection/sasha/")!
        
        
        let navigationController = UINavigationController(navigationBarClass: nil,
                                                          toolbarClass: nil)
        navigationController.pushViewController(nextViewController, animated: true)
        
        self.present(navigationController, animated: false, completion: nil)
    }
}
