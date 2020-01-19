import UIKit

struct ImageData {
    var pixels: [Pixel]
    var metadata: ImageMetadata
}

struct ImageMetadata {
    var height: Int
    var width: Int
    var colorSpace: CGColorSpace?
    
    var size: CGSize { CGSize(width: width, height: height) }
}


struct Pixel {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8
    var data: [UInt8] { return [b,g,r,a]}
}

func convertImageIntoPixels(image: UIImage) -> ImageData? {
     guard
         let cgImage = image.cgImage,
         let data = cgImage.dataProvider?.data
     else { return nil }
     
     let pointer: UnsafePointer<UInt8> = CFDataGetBytePtr(data)
     let rowLenght = cgImage.width * 4
     let pixels = stride(from: 0, to: rowLenght * cgImage.height, by: 4).map { iterator -> Pixel in
         return Pixel(r: pointer[iterator], g: pointer[iterator + 1], b: pointer[iterator + 2], a: pointer[iterator + 3])
     }
     let metadata = ImageMetadata(height: cgImage.height, width: cgImage.width, colorSpace: cgImage.colorSpace)
     return ImageData(pixels: pixels, metadata: metadata)
 }
 
 func getImageFromPixels(_ imgData: ImageData) -> UIImage? {
     var data = imgData.pixels.flatMap { $0.data }
     let width = imgData.metadata.width
     let height = imgData.metadata.height
     let image = data.withUnsafeMutableBytes { pointer -> CGImage? in
         let ctx = CGContext(data: pointer.baseAddress,
                             width: width,
                             height: height,
                             bitsPerComponent: 8,
                             bytesPerRow: width * 4,
                             space: CGColorSpaceCreateDeviceRGB(),
                             bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
         return ctx?.makeImage()
     }
     guard let cgimage = image else { return nil }
     return UIImage(cgImage: cgimage)
 }
