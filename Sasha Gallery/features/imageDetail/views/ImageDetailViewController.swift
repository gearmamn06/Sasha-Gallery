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
    
    private var viewModel: ImageDetailViewModelType!
    private weak var delegate: BaseCoordinatorDelegate!
    
    func injectDependency(viewModel: ImageDetailViewModelType,
                          delegate: BaseCoordinatorDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTheme()
        setUpNavigationbar()
        setUpTableView()
        subscribeOpenWebpage()
        
        DispatchQueue.global().async {
            self.viewModel.input.refresh()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.input.viewDidLayoutSubviews()
    }
    
    
    private func setTheme() {
        self.view.backgroundColor = UIColor.black
        self.tableView.backgroundColor = UIColor.black
        self.tableView.separatorStyle = .none
    }
    
}


// MARK: navigationBar setting

extension ImageDetailViewController {
    
    private func setUpNavigationbar() {
        let enquireButton = UIBarButtonItem(title: "Enquire", style: .plain,
                                            target: nil, action: nil)
        enquireButton.tintColor = UIColor.controlAccentBlue
        
        enquireButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.viewModel.input.enquireButtonDidTap()
            })
            .disposed(by: bag)
        
        self.navigationItem.rightBarButtonItem = enquireButton
        
        viewModel.output.enquireButtonEnability
            .drive(onNext: { [weak self] isEnable in
                self?.navigationItem.rightBarButtonItem?.isEnabled = isEnable
            })
            .disposed(by: bag)
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
            .bind(to: tableView.rx.items) { tableview, index, element in
                switch index {
                case 0:
                    let cell: ImageDetailImageCell = tableview.dequeuImageDetailCell()
                    cell.cellViewModel = element
                    return cell
                    
                case 1:
                    let cell: ImageDetailHeaderCell = tableview.dequeuImageDetailCell()
                    cell.cellViewModel = element
                    return cell
                    
                case 2:
                    let cell: ImageDetailMetaDataCell = tableview.dequeuImageDetailCell()
                    cell.cellViewModel = element
                    cell.linkDidTap = { [weak self] url in
                        self?.viewModel.input.metaTagDidTap(link: url)
                    }
                    return cell
                    
                default:
                    let cell: ImageDetailDescriptionCell = tableview.dequeuImageDetailCell()
                    cell.cellViewModel = element
                    return cell
                }
            }
            .disposed(by: bag)
    }
}



extension ImageDetailViewController {
    
    private func subscribeOpenWebpage() {
        
        viewModel.output.openURLPage
            .emit(onNext: { url in
                UIApplication.shared.open(url)
            })
            .disposed(by: bag)
    }
}



// fileprivate extensions

fileprivate extension ImageDetailViewCellType {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}


fileprivate extension UITableView {
    
    func register(cellType: UITableViewCell.Type) {
        let cellName = String(describing: cellType)
        self.register(cellType, forCellReuseIdentifier: cellName)
    }
    
    func dequeuImageDetailCell<Cell: ImageDetailViewCellType & UITableViewCell>() -> Cell {
        let cell = self.dequeueReusableCell(withIdentifier: Cell.reuseIdentifier) as! Cell
        return cell
    }
}


extension ImageDetailViewController: StoryboardLoadableView {
    
    static var storyboardName: String {
        return "ImageDetailView"
    }
    
}
