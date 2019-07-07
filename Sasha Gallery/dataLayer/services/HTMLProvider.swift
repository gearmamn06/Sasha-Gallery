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

struct HTMLProvider<Model: HTMLParsable> {
    
    private let urlString: String
    
    init(urlString: String) {
        self.urlString = urlString
    }
}


// MARK: get HTML Source

extension HTMLProvider {
    
    func loadHTMLString(_ resultCallback: (Result<String, Error>) -> Void) {
        
        guard let url = URL(string: urlString) else {
            resultCallback(.failure(CommonError.wrongURL))
            return
        }
        print("read string called..")
        let start = Date()
        guard let string = try? String(contentsOf: url) else {
            resultCallback(.failure(CommonError.emptyData))
            return
        }
        print("string loading interval: \(Date().timeIntervalSince(start))")
        resultCallback(.success(string))
    }
}



// MARK: get HTML Source and convert to desire model(Container)

extension HTMLProvider {
    
    func loadHTML(withOutCache: Bool = false, _ resultCallback: (Result<Model, Error>) -> Void) {
        
        // check cache exists
        if !withOutCache, let cached: Model = HTMLCache.shared.get(key: urlString)  {
            resultCallback(.success(cached))
            return
        }
        
        let urlString = self.urlString
        self.loadHTMLString { result in
            switch result {
            case .success(let htmlString):
                guard let document = try? SwiftSoup.parse(htmlString) else {
                    resultCallback(.failure(CommonError.invalidHtml))
                    return
                }
                
                let findResult = Model.find(inParent: document)
                switch findResult {
                case .success(let model):
                    // save cache data
                    HTMLCache.shared.put(key: urlString, value: model)
                    
                    resultCallback(.success(model))
                    
                case .failure(let error):
                    resultCallback(.failure(error))
                }
                
                
            case .failure(let error):
                resultCallback(.failure(error))
            }
        }
    }
}



extension HTMLProvider {
    
    func loadHTML(withOutCache: Bool = false) -> Observable<Model> {
        return Observable.create { observer in
            self.loadHTML(withOutCache: withOutCache) { result in
                
                switch result {
                case .success(let model):
                    observer.onNext(model)
                    observer.onCompleted()
                    
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
}
