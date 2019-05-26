import Foundation
import UIKit

//func convertStrToNumber(_ string: String) -> NSNumber? {
//    let formatter = NumberFormatter()
//    formatter.locale = Locale(identifier: "en")
//    formatter.numberStyle = NumberFormatter.Style.spellOut
//    return formatter.number(from: string)
//}




//
//func makeNoise1D(x : Int) -> Float{
//    var x = x
//    x = (x >> 13) ^ x;
//    x = (x &* (x &* x &* seed! &+ 19990303) &+ 1376312589) & 0x7fffffff
//    let inner = (x &* (x &* x &* 15731 &+ 789221) &+ 1376312589) & 0x7fffffff
//    return ( 1.0 - ( Float(inner)), / 1073741824.0)
//}
//
//var h = 0xBC1128
//
//
//print(16*16)
//print(pow(2, 8))
//
//
//print(String(format: "%.3f", arguments: [0.00005]))




enum CompressionQuality: CGFloat {
    typealias RawValue = CGFloat
    case lowest  = 0
    case low     = 0.25
    case medium  = 0.5
    case high    = 0.75
    case highest = 1
}

extension Data {
    mutating func append(_ strs: String...) {
        for str in strs {
            if let dataStr = str.data(using: .utf8) {
                self.append(dataStr)
            }
        }
    }
}

extension URLRequest {
    
    mutating func setMultipartRequest(_ photos: UIImage...,
                                   boundary: String,
                                   name: String,
                                   ext: String = "jpeg",
                                   qoc: CompressionQuality = .medium){
        self.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        self.httpMethod = "POST"
        
        var body = Data()
        
        let LB = "\r\n"
        let disposition = "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(Date().timeIntervalSince1970).\(ext)\"\(LB)"
        let type = "Content-Type: image/\(ext)\(LB)\(LB)"
        let startBoundary = "\(LB)--\(boundary)\(LB)"
        let endBoundary = "\(LB)--\(boundary)--"
        
        let photosData = photos.map { (img) -> Data in
            return img.jpegData(compressionQuality: qoc.rawValue)!
        }
        
        for (index, data) in photosData.enumerated(){
            body.append(startBoundary,disposition,type)
            body.append(data)
            if index == photosData.count - 1 {body.append(endBoundary)}
        }
        
        self.httpBody = body
    }

}





func sendFeniciaPhoto(){
    let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI1Y2U2Yjc2NTAxNjJlMTE4MWUxYjIyNTMiLCJhY2Nlc3MiOiJhdXRoIiwiaWF0IjoxNTU4NjQ4OTk5fQ.iB113hyikAbRTqXOSOBfL2_ynpO7YCkL7f3W2Uea1NY"
    
    let link = "http://localhost:3000/upload_post_image/5ce718fdca26f41f358b325d"
    guard let url = URL(string: link) else {return}
    var request = URLRequest(url: url)
    
    let myImage = UIImage(named: "personSign.png")!
    request.setValue(token, forHTTPHeaderField: "x-auth")
    request.setMultipartRequest(myImage, boundary: "a", name: "postImage")
    
    URLSession.shared.dataTask(with: request) { (data, res, err) in
        if let err = err {print("error", err)}
        if let res = res as? HTTPURLResponse {
            print("status code:", res.statusCode)
            guard let data = data else {return}
            print("resp data:", String(data: data, encoding: .utf8) ?? "failed conversion")

        }
        
    }.resume()

}


sendFeniciaPhoto()


func getImage(call: (UIImageView) -> Void){
    let link = "https://fenicia-backend.herokuapp.com/get_post_imageURL/5ce874b007b20800174666b9"
    
    let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI1Y2U2ODMyMTgyOGYyOTAwMTc1Y2QyN2IiLCJhY2Nlc3MiOiJhdXRoIiwiaWF0IjoxNTU4NzE1ODU2fQ.MtOqViTSh-BKiqZNtglMBvj8u050mp6m-3Ans9Sc4OI"
    
    let url = URL(string: link)!
    var request = URLRequest(url: url)
    request.setValue(token, forHTTPHeaderField: "x-auth")
    request.httpMethod = "GET"
    
    URLSession.shared.dataTask(with: request) { (data, res, err) in
        if let err = err {print(err); return}
        if let res = res as? HTTPURLResponse {
            print(res.statusCode)
        }
        guard let data = data else {return}
        if let img = UIImage(data: data) {
            img
        }
        
        
        
    }.resume()
 
}

getImage { (image) in
    print(image.image)
}















