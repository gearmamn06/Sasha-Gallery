import UIKit

var str = "Hello, playground"




let urlString = "https://www.gettyimagesgallery.com/wp-content/uploads/2018/12/GettyImages-3360485-1024x802.jpg"
let fullRange = NSRange(urlString.startIndex..., in: urlString)

let pattern = "[0-9]*x[0-9]*.jpg$"
if let regex = try? NSRegularExpression(pattern: pattern),
    let result = regex.firstMatch(in: urlString, range: fullRange),
    let range = Range(result.range, in: urlString) {
    
    let sizes = urlString[range]
                .replacingOccurrences(of: ".jpg", with: "")
                .split(separator: "x")
    
    if sizes.count == 2, let width = Int(sizes[0]), let height = Int(sizes[1]) {
        print("width: \(width), and height: \(height)")
    }
}
