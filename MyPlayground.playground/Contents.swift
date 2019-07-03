import UIKit
import RxSwift
import RxCocoa

var str = "Hello, playground"



let publisher = PublishRelay<Void>()
let behavior = BehaviorRelay<Int>(value: 0)


let event = Observable.zip(publisher, behavior)
    .map{ $0.1 }

