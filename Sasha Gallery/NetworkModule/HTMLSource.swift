//
//  HTMLSource.swift
//  Sasha Gallery
//
//  Created by ParkHyunsoo on 2019/07/01.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation


// MARK; Properties & initializer

struct HTMLSource {
    
    private let urlString: String
    
    init(urlString: String) {
        self.urlString = urlString
    }
}


// MARK: get HTML Source

extension HTMLSource {
    
    func loadHTMLString(_ resultCallback: (Result<String, NetworkError>) -> Void) {
        guard let url = URL(string: urlString) else {
            resultCallback(.failure(.wrongURL))
            return
        }
        
        guard let string = try? String(contentsOf: url) else {
            resultCallback(.failure(.emptyData))
            return
        }
        
        resultCallback(.success(string))
    }
}
