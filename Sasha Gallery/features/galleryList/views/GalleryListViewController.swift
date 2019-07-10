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
    
    private let bag = DisposeBag()
    private var viewModel: GalleryListViewModelType!
    private weak var delegate: BaseCoordinatorInterface!
    
    
    func injectDependency(_ viewModel: GalleryListViewModelType,
                          delegate: BaseCoordinatorInterface) {
        self.viewModel = viewModel
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
        setUpCollectionVew()
        
        subscribeNextViewControllerPushing()
        
        viewModel.input.refreshList(withOutCache: false)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.input.viewDidLayoutSubviews()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        // set rightBarButton items
        let sortButton = UIBarButtonItem(image: #imageLiteral(resourceName: "29"), style: .plain, target: nil, action: nil)
        
        let layoutStyleToggleButton = UIBarButtonItem(title: "2xn", style: .plain,
                                                      target: nil, action: nil)
        
        self.navigationItem.rightBarButtonItems = [sortButton, layoutStyleToggleButton]
        
        
        // subscribe rightBarButton items tap
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
        
        // subscribe viewmodel.output.new sorting option -> change barbuttonItem
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
        
        // bind viewmodel.output.items to uicollectionview
        viewModel.output.images.asObservable()
            .bind(to: collectionView.rx.items(cellIdentifier: "GalleryListItemCell", cellType: GalleryListItemCell.self))
            { _ , element, cell in
                cell.imageURL = element.imageURL
            }
            .disposed(by: bag)

        
        subscribeCollectionViewItemSelected()
        subscribeCollectionViewPrefetch()
        subscribeCollectionViewFlowLayout()
        subscribeRefreshControl()
    }
}


// MARK: Collectionview subscribing

extension GalleryListViewController {
    
    private func subscribeCollectionViewItemSelected() {
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.viewModel.input.imageDidSelect(atIndexPath: indexPath)
            })
            .disposed(by: bag)
    }
    
    private func subscribeCollectionViewPrefetch() {
        collectionView.rx.prefetchItems
            .subscribe(onNext: { [weak self] indexPaths in
                self?.viewModel.input.requestPreFetches(atIndxPaths: indexPaths)
            })
            .disposed(by: bag)
        
        collectionView.rx.cancelPrefetchingForItems
            .subscribe(onNext: { [weak self] indexPaths in
                self?.viewModel.input.cancelPreFetches(atIndexPaths: indexPaths)
            })
            .disposed(by: bag)
    }
}


// MARK: CollectionViewFlowLayout changes

extension GalleryListViewController {
    
    private func subscribeCollectionViewFlowLayout() {
        viewModel.output.newCollectionViewFlowLayout
            .drive(onNext: { [weak self] info in
                // 레이아웃 변경전 이전 레이아웃이 MosaicFlowLayout인지 검사
                let isMosaicLayout = self?.collectionView.collectionViewLayout
                    is MosaicFlowLayoutView
                
                self?.collectionView.collectionViewLayout = info.1
                self?.collectionView.reloadData()
                
                self?.navigationItem.rightBarButtonItems?.last?.title = info.0
                
                // 이전 레이아웃이 mosaicFlowLayout이 아니었다면 == 최초 기본레리아웃 -> 오프셋 .zero로 변경
                if isMosaicLayout == false {
                    self?.collectionView.contentOffset = .zero
                }
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
    
    private func subscribeRefreshControl() {
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.white
        refreshControl.rx.controlEvent(.valueChanged)
            .throttle(.milliseconds(100) , scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.input.refreshList(withOutCache: true)
            })
            .disposed(by: bag)
        
        collectionView.refreshControl = refreshControl
        collectionView.alwaysBounceVertical = true

        viewModel.output.acitivityIndicatorAnimating
            .drive(onNext: { [weak self] animating in
                if animating {
                    self?.navigationItem.rightBarButtonItems?.forEach{ $0.isEnabled = false }
                }else{
                    self?.collectionView.refreshControl?.endRefreshing()
                    self?.navigationItem.rightBarButtonItems?.forEach{ $0.isEnabled = true }
                }
            })
            .disposed(by: bag)
    }
}


extension GalleryListViewController {
    
    private func subscribeNextViewControllerPushing() {
        
        viewModel.output.requestPushImageDetailView
            .emit(onNext: { [weak self] _image in
                guard let self = self, let image = _image else { return }
                self.delegate?.pushImageDetailView(imageTitle: image.title,
                                                  webPageURL: image.pageURL,
                                                  imageRatio: image.imageRatio)
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
