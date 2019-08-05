//
//  ViewController.swift
//  DrawCircle
//
//  Created by GevinChen on 2019/6/12.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var slider: UISlider! {
        didSet {
            self.slider.addTarget(self, action: #selector(slideChanged(sender:)), for: UIControl.Event.valueChanged)
            self.slider.maximumValue = 1.0
            self.slider.minimumValue = 0.0
            self.slider.value = 0.5
            self.slider.isContinuous = true
        }
    }
    
    var circle: CAShapeLayer = CAShapeLayer()
    var circleBackground: CAShapeLayer = CAShapeLayer()
    var circlePath: UIBezierPath!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.layerConfigure()

    }
    
    // MARK: - Action
    
    @objc
    func slideChanged( sender: UISlider ) {
        circle.strokeEnd = CGFloat(sender.value)
    }
    
    @IBAction func playClicked(_ sender: Any) {
        
        self.playAnimation()
    }
    
    @IBAction func stopClicked(_ sender: Any) {
        self.stopAnimation()
    }
    
    // MARK: - operation
    
    func layerConfigure() {
        let lineWidth:CGFloat = 5.0
        let startAngle:CGFloat = -90.0
        let endAngle:CGFloat = 270.01
        
        self.circlePath = UIBezierPath(arcCenter: CGPoint( x: self.circleView.frame.size.width/2.0, y: self.circleView.frame.size.height/2.0),
                                       radius: (self.circleView.frame.size.height * 0.5) - (lineWidth/2.0), 
                                       startAngle: self.degree2radians(startAngle), 
                                       endAngle: self.degree2radians(endAngle), 
                                       clockwise: true)
        
        self.circle.path          = self.circlePath.cgPath
        self.circle.lineCap       = CAShapeLayerLineCap.round
        self.circle.fillColor     = UIColor.clear.cgColor
        self.circle.strokeColor   = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        self.circle.lineWidth     = lineWidth
        self.circle.zPosition     = 1;
        self.circle.strokeStart   = 0.0
        self.circle.strokeEnd     = 0.5
        
        self.circleBackground.path        = self.circlePath.cgPath
        self.circleBackground.lineCap     = CAShapeLayerLineCap.round
        self.circleBackground.fillColor   = UIColor.clear.cgColor
        self.circleBackground.lineWidth   = lineWidth
        self.circleBackground.strokeColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)   // (hasBackgroundShadow ? backgroundShadowColor.CGColor : [UIColor clearColor].CGColor);
        self.circleBackground.strokeEnd   = 1.0;
        self.circleBackground.zPosition   = -1;
        
        self.circleView.layer.addSublayer(circle)
        self.circleView.layer.addSublayer(circleBackground)
    }
    
    func degree2radians(_ number: CGFloat) -> CGFloat {
        return number * .pi / 180
    }
    
    func playAnimation() {
        // 一般
//        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd") // perform animation on 'strokeEnd' property of CAShapeLayer 
//        strokeAnimation.duration = 2.0
//        strokeAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//        strokeAnimation.fromValue = 0.0
//        strokeAnimation.toValue = 1.0
//        strokeAnimation.delegate = self
        
        // spring
        let strokeAnimation = CASpringAnimation(keyPath: "strokeEnd")
        strokeAnimation.damping = 5 // 0~10 彈跳係數，值越低，越會彈
        strokeAnimation.mass = 1.0 // 質量 0~1，值越高，衝超過 toValue 的量越多
        strokeAnimation.stiffness = 100 // 剛性 0~100
        strokeAnimation.duration = strokeAnimation.settlingDuration
        strokeAnimation.fromValue = 0.0
        strokeAnimation.toValue = 0.5
        strokeAnimation.delegate = self
        
        self.circle.add(strokeAnimation, forKey: "strokeAnim")
    }
    
    func stopAnimation() {
        self.circle.removeAnimation(forKey: "strokeAnim")
    }

}

extension ViewController: CAAnimationDelegate {
    func animationDidStart(_ anim: CAAnimation) {
        print("animation start!!")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        print("animation stop!!")
    }
}

