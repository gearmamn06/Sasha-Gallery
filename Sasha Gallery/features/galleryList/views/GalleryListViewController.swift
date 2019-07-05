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
        
        subscribeNextViewControllerPushing()
        
        DispatchQueue.global().async {
            self.viewModel.input.refreshList(shouldClearCache: false)
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.input.viewDidLayoutSubviews()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        setUpTheme()
    }
    
    
    private func setUpTheme() {
        
        self.view.backgroundColor = UIColor.black
        self.collectionView.backgroundColor = UIColor.black
        navigationController?.navigationBar.barStyle = .blackTranslucent
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 20, weight: .heavy)
        ]
        
    }
}


// MARK: setup navigaionBar

extension GalleryListViewController {
    
    private func setUpNavigationBar() {
        
        self.title = "Sasha Gallery"
        
        let sortButton = UIBarButtonItem(image: #imageLiteral(resourceName: "29"), style: .plain, target: nil, action: nil)
        
        let layoutStyleToggleButton = UIBarButtonItem(title: "2xn", style: .plain,
                                                      target: nil, action: nil)
        
        self.navigationItem.rightBarButtonItems = [sortButton, layoutStyleToggleButton]
        
        sortButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.input.sortingButtonDidTap()
            })
            .disposed(by: bag)
        
        layoutStyleToggleButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.input.toggleLayoutStyle()
            })
            .disposed(by: bag)
        
        subscribeSortOptionSelectionAlertController()
        
    }
    
    private func subscribeSortOptionSelectionAlertController() {
        viewModel.output.showSortOrderSelectPopupWithCurrentValue
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
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.viewModel.input.imageDidSelect(atIndexPath: indexPath)
            })
            .disposed(by: bag)
        
        subscribeCollectionViewFlowLayout()
        
        subscribeRefreshControl()
    }
}



// MARK: CollectionViewFlowLayout changes

extension GalleryListViewController {
    
    private func subscribeCollectionViewFlowLayout() {
        viewModel.output.newCollectionViewFlowLayout
            .drive(onNext: { [weak self] info in
                self?.collectionView.collectionViewLayout = info.1
                self?.collectionView.reloadData()
                
                self?.navigationItem.rightBarButtonItems?.last?.title = info.0
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
    
    private func createRefreshControl() {
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresDidCall), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        collectionView.sendSubviewToBack(refreshControl)
    }
    
    private func subscribeRefreshControl() {
        
        createRefreshControl()
        
        viewModel.output.acitivityIndicatorAnimating
            .drive(onNext: { [weak self] animating in
                if animating {
                    self?.collectionView.refreshControl?.beginRefreshing()
                    self?.navigationItem.rightBarButtonItems?.forEach{ $0.isEnabled = false }
                }else{
                    self?.collectionView.refreshControl?.endRefreshing()
                    self?.navigationItem.rightBarButtonItems?.forEach{ $0.isEnabled = true }
                }
            })
            .disposed(by: bag)
    }
    
    
    @objc private func refresDidCall() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.viewModel.input.refreshList(shouldClearCache: true)
        })
    }
    
}


extension GalleryListViewController {
    
    private func subscribeNextViewControllerPushing() {
        
        viewModel.output.nextPushViewController
            .emit(onNext: { [weak self] nextViewController in
                guard let self = self, let next = nextViewController else { return }
                self.navigationController?.pushViewController(next, animated: true)
            })
            .disposed(by: bag)
    }
}



// MARK: storyboard info

extension GalleryListViewController: StoryboardLoadableView {
    
    static var storyboardName: String {
        return "GalleryListView"
    }
}
