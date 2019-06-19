import UIKit

class HeartCell: UIImageView {
    var index = 0
    private var velocityX: CGFloat = {
        let m: CGFloat = Int.random(in: 0 ... 1) == 0 ? -1 : 1
        return CGFloat.random(in: 0.6 ... 1.5) * m
    }()
    private var velocityY: CGFloat = -0.8
    
    private var acceleration:CGFloat = 0
    var startingXPosition: CGFloat = 0
    
    override init(image: UIImage?) {
        super.init(image: image)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSpringForce(_ multiplier: CGFloat = 0.02, startX: CGFloat, YVel: CGFloat = -0.4, ind: Int){
        startingXPosition = startX
        velocityY = YVel - CGFloat(index) / 10
        index = ind
        let force = (startingXPosition - center.x) * multiplier
        acceleration += force
        velocityX += acceleration
        acceleration *= 0
        updatePosition()
    }
    
    func updatePosition(){
        center.x += velocityX
        center.y += velocityY
    }
    
}

class HeartEmitter {
    weak var parentView: UIView?
    
    var displayLink: CADisplayLink?
    var duration: TimeInterval = 5
    var numberOfCells: Int = 8
    
    private var startingPoint = CGPoint.zero
    private var startingDate = Date()
    
    private lazy var emitterCells: [HeartCell] = {
        var cells = [HeartCell]()
        guard let parent = parentView else {return [HeartCell]()}
        for _ in 0 ..< numberOfCells {
            let cell = HeartCell(image: #imageLiteral(resourceName: "heartIcon"))
            cell.contentMode = .scaleAspectFit
            let ramdomHeight = CGFloat.random(in: 7 ... 15)
            cell.frame.size = CGSize(width: ramdomHeight, height: ramdomHeight)
            cell.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
            cells.append(cell)
        }
        return cells
    }()
    
    
    
    init(_ parent: UIView) {
        parentView = parent
        setUp()
    }
    func setUp(){
        let x = parentView?.bounds.midX ?? 0
        let y = parentView?.bounds.midY ?? 0
        let centered = CGPoint(x: x, y: y)
        emitterCells.forEach {
            parentView?.addSubview($0)
            $0.center = centered
        }
        displayLink = CADisplayLink(target: self, selector: #selector(startLoop))
        displayLink?.isPaused = true
        displayLink?.add(to: .current, forMode: .common)
        
        startingPoint = centered
    }
    
    func animate(){
        startingDate = Date()
        displayLink?.isPaused = false
        parentView?.isUserInteractionEnabled = false
        emitterCells.forEach { cell in
            UIView.animate(withDuration: duration / 6, animations: {
                cell.transform = .identity
            })
            UIView.animate(withDuration: duration, animations: {
                cell.alpha = 0
            })
        }
    }
    
    @objc func startLoop(_ loop: CADisplayLink){
        if -startingDate.timeIntervalSinceNow < duration {
            for (index, cell) in emitterCells.enumerated() {
                cell.addSpringForce(startX: startingPoint.x, ind: index)
            }
        } else {
            emitterCells.forEach { $0.removeFromSuperview() }
            loop.invalidate()
            parentView?.isUserInteractionEnabled = true
        }
    }
}

extension UIView {
    var particleEmitter: HeartEmitter { HeartEmitter(self)}
}
