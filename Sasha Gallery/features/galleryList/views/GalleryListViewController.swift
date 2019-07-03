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

extension GalleryListViewController {
    
    private func setUpNavigationBar() {
        
        // TODO: Change theme to dark
        
        self.title = "Sasha Gallery"
        
        let sortButton = UIBarButtonItem(barButtonSystemItem: .organize,
                                         target: self, action: #selector(sortButtonDidTap))
        
        let layoutStyleToggleButton = UIBarButtonItem(barButtonSystemItem: .camera,
                                                      target: self,
                                                      action: #selector(toggleLayoutStyleButtonDidtap))
        
        self.navigationItem.rightBarButtonItems = [sortButton, layoutStyleToggleButton]
        
        subscribeSortOptionSelectionAlertController()
        
    }
    
    @objc private func toggleLayoutStyleButtonDidtap() {
        viewModel.input.toggleLayoutStyle()
    }
    
    @objc private func sortButtonDidTap() {
        viewModel.input.sortingButtonDidTap()
    }
    
    private func subscribeSortOptionSelectionAlertController() {
        viewModel.output.showSortOrderSelectPopupWithCurrentValue
            .debug()
            .emit(onNext: { [weak self] description in
                self?.showSortOrderSelectAlertController(currentOptionDescription: description)
            })
            .disposed(by: bag)
    }
    
    private func showSortOrderSelectAlertController(currentOptionDescription description: String) {
        let alert = UIAlertController(title: "정렬기준 변경",
                                      message: "새로운 이미지 정렬 기준을 선택해주세요\n현재: \(description)",
                                        preferredStyle: .actionSheet)
        
        let types: [ListSortingOrder] = [.normal, .title, .newest]
        let actions = types.map { type in
            UIAlertAction(title: type.description, style: .default) { _ in
                self.viewModel.input.newSortingOrderDidSelect(to: type)
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        (actions + [cancel]).forEach {
            alert.addAction($0)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
}


// MARK: setup collectionView

extension GalleryListViewController {
    
    private func setUpCollectionVew() {
        
        collectionView.register(GalleryListItemCell.self,
                                forCellWithReuseIdentifier: "GalleryListItemCell")
        
        viewModel.output.images.asObservable()
            .bind(to: collectionView.rx.items(cellIdentifier: "GalleryListItemCell", cellType: GalleryListItemCell.self))
            { _ , element, cell in
                cell.imageURL = element.imageURL
            }
            .disposed(by: bag)
        
        subscribeCollectionViewFlowLayout()
        
        setUpCollectionViewRefreshControl()
        subscribeRefreshControl()
    }
}



// MARK: CollectionViewFlowLayout changes

extension GalleryListViewController {
    
    private func subscribeCollectionViewFlowLayout() {
        viewModel.output.newCollectionViewLayout
            .debug()
            .drive(onNext: { [weak self] layout in
                self?.collectionView.collectionViewLayout = layout
                self?.collectionView.reloadData()
            })
            .disposed(by: bag)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // clear mosaicFlowLayout cache when screen rotation changed
        (self.collectionView.collectionViewLayout as? MosaicFlowLayoutView)?.clearCache()
    }
}



// MARK: CollectionView refresh control setting

extension GalleryListViewController {
    
    private func setUpCollectionViewRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresDidCall), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        collectionView.sendSubviewToBack(refreshControl)
    }
    
    private func subscribeRefreshControl() {
        viewModel.output.acitivityIndicatorAnimating
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
