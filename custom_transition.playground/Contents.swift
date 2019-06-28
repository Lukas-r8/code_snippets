import Foundation
import UIKit


class customTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var duration: TimeInterval = 0.8
    var startPoint = CGPoint.zero
    
    var circle = UIView()
    
    var circleColor = UIColor.white
    enum transitMode: Int {
        case presenting, dismissing
    }
    
    var transitionMode: transitMode = .presenting
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let container = transitionContext.containerView
        guard let to = transitionContext.view(forKey: UITransitionContextViewKey.to) else {return}
        guard let from = transitionContext.view(forKey: UITransitionContextViewKey.from) else {return}
        
        circleColor = to.backgroundColor ?? UIColor.white
        
        if transitionMode == .presenting {
            to.translatesAutoresizingMaskIntoConstraints = false
            to.center = CGPoint(x: self.startPoint.x, y: self.startPoint.y - 15)
            
            circle = UIView()
            circle.backgroundColor = circleColor
            circle.frame = getFrameForCircle(rect: to.frame)
            circle.layer.cornerRadius = circle.frame.width / 2
            circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            circle.alpha = 1
            
            
            circle.addSubview(to)
            
            to.alpha = 0
            
            to.centerXAnchor.constraint(equalTo: circle.centerXAnchor).isActive = true
            to.centerYAnchor.constraint(equalTo: circle.centerYAnchor).isActive = true
            to.widthAnchor.constraint(equalToConstant: to.frame.width).isActive = true
            to.heightAnchor.constraint(equalToConstant: to.frame.height).isActive = true
            
            container.addSubview(circle)
            
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.circle.center = from.center
                self.circle.transform = CGAffineTransform.identity
                to.alpha = 1
                
            }) { (sucess) in
                
                transitionContext.completeTransition(sucess)
                
            }
            
        } else if transitionMode == .dismissing {
            
            container.insertSubview(to, belowSubview: circle)
            
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.circle.center = self.startPoint
                self.circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                self.circle.subviews.forEach({ (view) in view.alpha = 0 })
            }) { (sucess) in
                self.circle.removeFromSuperview()
                transitionContext.completeTransition(sucess)
            }
        }
    }
    
    func getFrameForCircle(rect: CGRect) -> CGRect{
        let width = Float(rect.width)
        let height = Float(rect.height)
        
        let diameter = CGFloat(sqrtf(width * width + height * height))
        
        let x: CGFloat = rect.midX - (diameter / 2)
        let y: CGFloat = rect.midY - (diameter / 2)
        
        return CGRect(x: x, y: y, width: diameter, height: diameter)
    }
    
    
    
}
