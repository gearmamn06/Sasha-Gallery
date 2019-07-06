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

protocol BaseCoordinatorDelegate: class {
    func requestNextNavigationFlow(_ next: BaseCoordinator.NavigationFlow)
}


// MARK: private and internal properties & initializer

class BaseCoordinator {
    
    enum NavigationFlow: Equatable {
        case collection(title: String, collectionURL: URL)
        case imageDetail(_ imageModel: GalleryImage)
        
        static var initialFlow: NavigationFlow {
            return .collection(title: "Sasha",
                               collectionURL: URL(string: "https://www.gettyimagesgallery.com/collection/sasha/")!)
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



extension BaseCoordinator: BaseCoordinatorDelegate {
    
    func requestNextNavigationFlow(_ next: BaseCoordinator.NavigationFlow) {
        nextNavigationFlow.accept(next)
    }
    
    
    private func subscribeNextNavigationFlow() {
        nextNavigationFlow
            .distinctUntilChanged()
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] nextFlow in
                guard let self = self else { return }
                switch nextFlow {
                    
                case .collection(let title, let url):
                    let viewModel = GalleryListViewModel(collectionURL: url)
                    let nextViewController = GalleryListViewController.instance
                    nextViewController.injectDependency(viewModel, delegate: self)
                    nextViewController.title = title
                        
                    self.navigationController.pushViewController(nextViewController,
                                                                  animated: true)
                    
                case .imageDetail(let model):
                    
                }
            })
            .disposed(by: bag)
    }
}
