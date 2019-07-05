//
//  ImageDetailViewController.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/05.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ImageDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private let bag = DisposeBag()
    
    var viewModel: ImageDetailViewModelType!
    var productName: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = ImageDetailViewModel(productName: productName ?? "")
        
        setUpNavigationbar()
        setUpTableView()
        
        viewModel.input.refresh()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.input.viewDidLayoutSubviews()
    }
    
}


// MARK: navigationBar setting

extension ImageDetailViewController {
    
    private func setUpNavigationbar() {
        self.title = productName
    }
}


// MARK: tableview setting

extension ImageDetailViewController {
    
    func setUpTableView() {
        
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(cellType: ImageDetailImageCell.self)
        tableView.register(cellType: ImageDetailHeaderCell.self)
        tableView.register(cellType: ImageDetailMetaDataCell.self)
        tableView.register(cellType: ImageDetailDescriptionCell.self)
        
        viewModel.output.items.asObservable()
            .debug()
            .bind(to: tableView.rx.items) { tableview, index, element in
                let cell: ImageDetailViewCell = tableview.dequeImageDetailCell(at: index)
                cell.cellViewModel = element
                return cell
            }
            .disposed(by: bag)
    }
}


// fileprivate extensions

fileprivate extension ImageDetailViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}


fileprivate extension UITableView {
    
    func register(cellType: UITableViewCell.Type) {
        let cellName = String(describing: cellType)
        self.register(cellType, forCellReuseIdentifier: cellName)
    }
    
    func dequeImageDetailCell<T: ImageDetailViewCell>(at index: Int) -> T {
        let cell = self.dequeueReusableCell(withIdentifier: T.reuseIdentifier)
            as! T
        return cell
    }
}
