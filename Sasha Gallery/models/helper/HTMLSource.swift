//
//  HTMLSource.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/01.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation
import SwiftSoup
import RxSwift


// MARK; Properties & initializer

struct HTMLSource<Model: HTMLParsable> {
    
    private let urlString: String
    
    init(urlString: String) {
        self.urlString = urlString
    }
}


// MARK: get HTML Source

extension HTMLSource {
    
    func loadHTMLString(_ resultCallback: (Result<String, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            resultCallback(.failure(CommonError.wrongURL))
            return
        }
        
        guard let string = try? String(contentsOf: url) else {
            resultCallback(.failure(CommonError.emptyData))
            return
        }
        
        resultCallback(.success(string))
    }
}



// MARK: get HTML Source and convert to desire model(Container)

extension HTMLSource {
    
    func loadHTML( _ resultCallback: (Result<Model, Error>) -> Void) {
        self.loadHTMLString { result in
            switch result {
            case .success(let htmlString):
                guard let document = try? SwiftSoup.parse(htmlString) else {
                    resultCallback(.failure(CommonError.invalidHtml))
                    return
                }
                
                let findResult = Model.find(inParent: document)
                resultCallback(findResult)
                
                
            case .failure(let error):
                resultCallback(.failure(error))
            }
        }
    }
}



extension HTMLSource {
    
    func loadHTML() -> Observable<Model> {
        return Observable.create { observer in
            self.loadHTML { result in
                
                switch result {
                case .success(let model):
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        observer.onNext(model)
                        observer.onCompleted()
                    })
                    
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
}
