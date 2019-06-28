import Foundation
import UIKit

class SpirograpghController: UIViewController {
    
    var path = UIBezierPath()
    var path2 = UIBezierPath()
    
    var drawPath = UIBezierPath()
    var drawPath2 = UIBezierPath()
    
    let layer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.lineWidth = 1
        shape.fillColor = nil
        shape.strokeColor = UIColor.clear.cgColor
        return shape
    }()
    
    let layer2: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.lineWidth = 1
        shape.fillColor = nil
        shape.lineDashPattern = [10,5]
        shape.strokeColor = UIColor.clear.cgColor
        return shape
    }()
    
    
    let drawLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.fillColor = nil
        shape.lineCap = CAShapeLayerLineCap.round
        shape.lineJoin = CAShapeLayerLineJoin.round
        shape.strokeColor = UIColor.red.cgColor
        return shape
    }()
    
    let drawLayer2: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.fillColor = nil
        shape.lineCap = CAShapeLayerLineCap.round
        shape.lineJoin = CAShapeLayerLineJoin.round
        shape.strokeColor = UIColor.green.cgColor
        return shape
    }()
    
    let pointer: UIView = {
        let p = UIView()
        p.backgroundColor = UIColor.red
        p.frame.size = CGSize(width: 10, height: 10)
        p.layer.cornerRadius = 5
        return p
    }()
    
    let pointer2: UIView = {
        let p = UIView()
        p.backgroundColor = UIColor.green
        p.frame.size = CGSize(width: 10, height: 10)
        p.layer.cornerRadius = 5
        return p
    }()
    
    
    
    var angle:CGFloat = 0
    
    
    
    lazy var display: CADisplayLink = {
        let link = CADisplayLink(target: self, selector: #selector(loop))
        link.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
        link.isPaused = true
        return link
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.layer.addSublayer(layer)
        view.layer.addSublayer(layer2)
        view.layer.addSublayer(drawLayer)
        view.layer.addSublayer(drawLayer2)
        view.addSubview(pointer)
        view.addSubview(pointer2)
        addCircles()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(startAnimating)))
    }
    
    
    @objc func startAnimating(tap: UITapGestureRecognizer){
        let bol = display.isPaused ? false : true
        display.isPaused = bol
    }
    
    
    
    func addCircles(){
        path.addArc(withCenter: view.center, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        path2.addArc(withCenter: view.center.add((radius - radius2 * 2) + radius2), radius: radius2, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        let point = getCenter(view.center,0, radius: (radius - radius2 * 2) + radius2 * 2 - holeOffSet)
        let point2 = getCenter(view.center,0, radius: (radius - radius2 * 2) + radius2 * 2 - holeOffSet - holeOffSet2)
        
        drawPath.move(to: point)
        drawPath2.move(to: point2)
        
        pointer.center = point
        pointer2.center = point2
        
        layer.path = path.cgPath
        layer2.path = path2.cgPath
    }
    
    lazy var radius: CGFloat = self.view.frame.width / 2
    lazy var radius2: CGFloat = 110  //radius * 0.555555
    
    lazy var holeOffSet: CGFloat =  self.view.frame.width * 0.04
    lazy var holeOffSet2: CGFloat =  self.view.frame.width * 0.08
    
    
    func getCenter(_ offset: CGPoint,_ angle: CGFloat, radius: CGFloat) -> CGPoint {
        let x = offset.x + radius * cos(angle)
        let y = offset.y + radius * sin(angle)
        return CGPoint(x: x, y: y)
    }
    
    var angle2: CGFloat = 0
    
    @objc func loop(){
        
        let point2 = getCenter(view.center,angle, radius: (radius - radius2 * 2) + radius2)
        let calcAngle = -(radius / radius2 * angle)
        
        path2 = UIBezierPath(arcCenter: point2 , radius: radius2, startAngle: calcAngle, endAngle: calcAngle  + .pi * 2, clockwise: true)
        layer2.path = path2.cgPath
        
        
        
        
        let drawPoint = getCenter(point2,calcAngle, radius: radius2 - holeOffSet)
        let drawPoint2 = getCenter(point2,calcAngle, radius: radius2 - holeOffSet - holeOffSet2)
        
        
        
        
        drawPath.addLine(to: drawPoint)
        drawPath2.addLine(to: drawPoint2)
        
        pointer.center = drawPoint
        drawLayer.path = drawPath.cgPath
        
        pointer2.center = drawPoint2
        
        drawLayer2.path = drawPath2.cgPath
        
        // r = a * .pi / 180
        
        angle += 0.018
        //        angle2 -= 0.001
        
    }
    
    
    
    
    
    
    
}

extension CGPoint {
    func add(_ numberX: CGFloat = 0,_ numberY: CGFloat = 0 ) -> CGPoint{
        return CGPoint(x: self.x + numberX, y: self.y + numberY)
    }
}
