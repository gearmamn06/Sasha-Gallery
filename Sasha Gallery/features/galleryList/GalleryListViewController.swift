//
//  GalleryListViewController.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/03.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class GalleryListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let viewModel: GalleryListViewModelType = GalleryListViewModel()
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        setUpNavigationBar()
        setUpCollectionVew()
        
        viewModel.input.refreshList()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.input.viewDidLayoutSubviews()
    }
}


// MARK: setup navigaionBar

private extension GalleryListViewController {
    
    func setUpNavigationBar() {
        
        // TODO: Change theme to dark
        
        self.title = "Sasha Gallery"
        
        let sortButton = UIBarButtonItem(barButtonSystemItem: .organize,
                                         target: self, action: #selector(sortButtonDidTap))
        
        // TODO: add layout style button
        
        self.navigationItem.rightBarButtonItems = [sortButton]
        
    }
    
    @objc func sortButtonDidTap() {
        let newOptions: [ListSortingOrder] = [.normal, .title, .newest]
        var newOption = newOptions.randomElement()!
        newOption.toggle()
        viewModel.input.newSortingOrderDidSelect(to: newOption)
    }
}


// MARK: setup collectionView

private extension GalleryListViewController {
    
    
    func setUpCollectionVew() {
        
        collectionView.register(GalleryListItemCell.self,
                                forCellWithReuseIdentifier: "GalleryListItemCell")
        
        
        viewModel.output.images.asObservable()
            .bind(to: collectionView.rx.items(cellIdentifier: "GalleryListItemCell", cellType: GalleryListItemCell.self))
            { _ , element, cell in
                cell.setUpSubViews(url: element.imageURL)
            }
            .disposed(by: bag)
            
        
        collectionView.rx.setDelegate(self).disposed(by: bag)
        
        setUpCollectionViewRefreshControl()
        
        subscribeRefreshControl()
    }
}

extension GalleryListViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.collectionView.frame.width / 2
        let height = width

        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}



// MARK: CollectionView refresh control setting

private extension GalleryListViewController {
    
    private func setUpCollectionViewRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresDidCall), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        collectionView.sendSubviewToBack(refreshControl)
    }
    
    private func subscribeRefreshControl() {
        viewModel.output.acitivityIndicatorAnimating
            .debug()
            .drive(onNext: { [weak self] animating in
                if animating {
                    self?.collectionView.refreshControl?.beginRefreshing()
                }else{
                    self?.collectionView.refreshControl?.endRefreshing()
                }
            })
            .disposed(by: bag)
    }
    
    
    @objc private func refresDidCall() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.collectionView.refreshControl?.endRefreshing()
            self.viewModel.input.refreshList()
        })
    }
    
}




// MARK: storyboard info

extension GalleryListViewController: StoryboardLoadableView {
    
    static var storyboardName: String {
        return "GalleryListView"
    }
}
