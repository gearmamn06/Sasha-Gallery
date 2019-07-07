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
    
    func loadHTMLString(withOutCache: Bool = false,
                        _ resultCallback: @escaping (Result<String, Error>) -> Void) {
        
        guard let url = URL(string: urlString) else {
            resultCallback(.failure(CommonError.wrongURL))
            return
        }
        
        let cachePolicy: URLRequest.CachePolicy = withOutCache ? .reloadIgnoringCacheData
            : .returnCacheDataElseLoad
        
        let request = URLRequest(url: url, cachePolicy: cachePolicy)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data,
                ((response as? HTTPURLResponse)?.statusCode ?? 500 < 300),
                let string = String(data: data, encoding: .utf8) {
                
                resultCallback(.success(string))
                return
            }
            
            resultCallback(.failure(error ?? CommonError.emptyData))
        }.resume()
    }
}



// MARK: get HTML Source and convert to desire model(Container)

extension HTMLProvider {
    
    func loadHTML(withOutCache: Bool = false, _ resultCallback: @escaping (Result<Model, Error>) -> Void) {
        
        // check cache exists
        if !withOutCache, let cached: Model = HTMLCache.shared.get(key: urlString)  {
            resultCallback(.success(cached))
            return
        }
        
        let urlString = self.urlString
        self.loadHTMLString(withOutCache: withOutCache) { result in
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
