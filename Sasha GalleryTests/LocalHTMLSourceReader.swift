//
//  LocalHTMLSourceReader.swift
//  Sasha GalleryTests
//
//  Created by ParkHyunsoo on 2019/07/02.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation



class LocalHTMLSourceReader {
    
    class func read() -> String {
        
        let fileName = "mainPage"
        let bundle = Bundle(for: LocalHTMLSourceReader.self)
        let path = bundle.path(forResource: fileName, ofType: "html")!
        let fileUrl = URL(fileURLWithPath: path)
        
        
        let htmlString = try! String(contentsOf: fileUrl)
        return htmlString
    }
}
