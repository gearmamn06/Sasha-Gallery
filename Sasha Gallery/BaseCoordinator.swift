//
//  AppCoordinator.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/06.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


// MARK: BaseCoordinatorDelegate: child viewController -> request

protocol BaseCoordinatorInterface: class {
    
    func pushGalleryCollectionView(collectionTitle: String, collectionURL: URL)
    func pushImageDetailView(imageTitle: String, webPageURL: URL, imageRatio: Float)
}


// MARK: private and internal properties & initializer

class BaseCoordinator {
    
    fileprivate enum NavigationFlow: Equatable {
        case collection(title: String, provider: HTMLProvider)
        case imageDetail(imageTitle: String, webPageURL: URL, imageRatio: Float)
        
        static var initialFlow: NavigationFlow {
            let provider = HTMLProvider(urlString: "https://www.gettyimagesgallery.com/collection/sasha/")
            return .collection(title: "Sasha", provider: provider)
        }
        
        private var identifier: Int {
            switch self {
            case .collection:
                return 0
            case .imageDetail:
                return 1
            }
        }
        
        
        static func == (lhs: NavigationFlow, rhs: NavigationFlow) -> Bool {
            return lhs.identifier == rhs.identifier
        }
        
    }
    
    private let bag = DisposeBag()
    private var nextNavigationFlow = BehaviorRelay<NavigationFlow>(value: .initialFlow)

    private weak var navigationController: UINavigationController!
    
    init(navigationViewController: UINavigationController) {
        self.navigationController = navigationViewController
        
        subscribeNextNavigationFlow()
    }
}


// MARK: received nextNavigationFlow request and handle it

extension BaseCoordinator: BaseCoordinatorInterface {
    
    private func subscribeNextNavigationFlow() {
        nextNavigationFlow
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] nextFlow in
                guard let self = self else { return }
                switch nextFlow {
                    
                case .collection(let title, let provider):
                    let viewModel = GalleryListViewModel(provider: provider)
                    let nextViewController = GalleryListViewController.instance
                    nextViewController.injectDependency(viewModel, delegate: self)
                    nextViewController.title = title
                        
                    self.navigationController.pushViewController(nextViewController,
                                                                  animated: true)
                    
                case .imageDetail(let title, let url, let ratio):
                    let ratio = ratio == 0 ? 0.6 : ratio
                    let viewModel = ImageDetailViewModel(imageInfo: ((pageURL: url,
                                                                      imageRatio: ratio)))
                    let nextViewController = ImageDetailViewController.instance
                    nextViewController.injectDependency(viewModel: viewModel, delegate: self)
                    nextViewController.title = title
                    
                    self.navigationController.pushViewController(nextViewController,
                                                                 animated: true)
                }
            })
            .disposed(by: bag)
    }
}



// MARK: receive push request from child viewController

extension BaseCoordinator {
    
    func pushGalleryCollectionView(collectionTitle: String, collectionURL: URL) {
        let provider = HTMLProvider(urlString: collectionURL.absoluteString)
        let flow = NavigationFlow.collection(title: collectionTitle,
                                             provider: provider)
        nextNavigationFlow.accept(flow)
    }
    
    func pushImageDetailView(imageTitle: String, webPageURL: URL, imageRatio: Float) {
        let flow = NavigationFlow.imageDetail(imageTitle: imageTitle,
                                              webPageURL: webPageURL,
                                              imageRatio: imageRatio)
        nextNavigationFlow.accept(flow)
    }
}
