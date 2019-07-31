//
//  HTMLProviderType.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/31.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation
import RxSwift


protocol HTMLProViderType {
    
    init(urlString: String)
    
    func loadHTMLString(withOutCache: Bool,
                        _ resultCallback: @escaping (Result<String, Error>) -> Void)
    
    func loadHTML<Model: HTMLParsable>(withOutCache: Bool,
                  _ resultCallback: @escaping (Result<Model, Error>) -> Void)
}


extension HTMLProViderType {
    
    func loadHTML<Model: HTMLParsable>(withOutCache: Bool = false) -> Observable<Model> {
        return Observable.create { observer in
            self.loadHTML(withOutCache: withOutCache) { (result: Result<Model, Error>) in
                
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
