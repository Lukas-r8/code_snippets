import UIKit

var photo = UIImage(named: "lukas.jpg")!



func getArrayFrom(_ img: UIImage, hasAlphaComponent: Bool = true) throws -> [UInt8]{
    guard let cgimg = img.cgImage else {throw NSError(domain: "Failed to convert image", code: 1, userInfo: nil)}

    let bytesPerPixels: Int = hasAlphaComponent ? 4 : 3
    
    let width: Int = cgimg.width
    let height: Int = cgimg.height
    
    let bitsPerComponent: Int = 8
    let bytesPerRow = bytesPerPixels * width
    let totalPixels = (bytesPerPixels * width) * height
    
    let alignment = MemoryLayout<UInt8>.alignment
    
    let data = UnsafeMutableRawPointer.allocate(byteCount: totalPixels, alignment: alignment )
    
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue).rawValue
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    let ctx = CGContext(data: data, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
    ctx?.draw(cgimg, in: CGRect(origin: .zero, size: photo.size))
    
    
    let bindedPointer: UnsafeMutablePointer<UInt8> = data.bindMemory(to: UInt8.self, capacity: totalPixels)
    
    let pixels = UnsafeMutableBufferPointer.init(start: bindedPointer, count: totalPixels)
    
    
    return pixels.map {$0}
}



func arrayToImage(_ array: [UInt8], width: Int, height: Int) throws -> UIImage {
    
    var d = array
    
    let cgImg = d.withUnsafeMutableBytes { (ptr) -> CGImage in
        let ctx = CGContext(
            data: ptr.baseAddress,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 4*width,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
            )!
        return ctx.makeImage()!
    }
    return UIImage(cgImage: cgImg)
}






