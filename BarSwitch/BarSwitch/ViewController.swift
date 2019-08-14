//
//  ViewController.swift
//  BarSwitch
//
//  Created by GevinChen on 2019/8/13.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBar2: UINavigationBar!
    var duration = 0.3
    let layer1 = CALayer()
    let layer2 = CALayer()
    var hasInit = false
    var currentIndex: NaviBarIndex = .naviBar1 
    enum NaviBarIndex: Int {
        case naviBar1
        case naviBar2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }

    @IBAction func switchClicked(_ sender: Any) {
        self.switchContent(showIndex: self.currentIndex == NaviBarIndex.naviBar1 ? NaviBarIndex.naviBar2 : NaviBarIndex.naviBar1 )
    }
    
    func initSwitchContent() {
        guard !self.hasInit else {return}
        self.hasInit = true
        let image1 = self.navigationBar.takeSnapshot(self.navigationBar.bounds)
        let image2 = self.navigationBar2.takeSnapshot(self.navigationBar2.bounds)
        layer1.bounds = self.containerView.bounds
        layer1.frame = CGRect(origin: CGPoint.zero, size: self.containerView.bounds.size)
        layer1.contents = image1?.cgImage
        layer2.bounds = self.containerView.bounds
        layer2.frame = CGRect(origin: CGPoint.zero, size: self.containerView.bounds.size)
        layer2.contents = image2?.cgImage

        self.containerView.layer.addSublayer(layer1)
        self.containerView.layer.addSublayer(layer2)
        
    }
    
    func switchContent( showIndex: NaviBarIndex ) {
        
        guard self.currentIndex != showIndex else {return}
        self.currentIndex = showIndex 
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        self.initSwitchContent()
        
        self.layer1.isHidden = false
        self.layer2.isHidden = false
        
        if showIndex == .naviBar1 {
            self.rotate(layer: layer1, from: 90.0, to: 0.0, timingFunc: CAMediaTimingFunctionName.easeInEaseOut, duration: duration, delay: 0.0)
            self.rotate(layer: layer2, from: 0.0, to: -90.0, timingFunc: CAMediaTimingFunctionName.easeInEaseOut, duration: duration, delay: 0.0)
        } else {
            self.rotate(layer: layer1, from: 0.0, to: 90.0, timingFunc: CAMediaTimingFunctionName.easeInEaseOut, duration: duration, delay: 0.0)
            self.rotate(layer: layer2, from: -90.0, to: 0.0, timingFunc: CAMediaTimingFunctionName.easeInEaseOut, duration: duration, delay: 0.0)
        }
        
        CATransaction.commit()
        
        self.navigationBar.isHidden = true
        self.navigationBar2.isHidden = true
        
    }
    
    private func rotate( layer: CALayer, from startAngle: CGFloat, to endAngle: CGFloat, timingFunc: CAMediaTimingFunctionName, duration: CFTimeInterval, delay: CFTimeInterval ) {
        
        var transform = CATransform3DIdentity
        transform.m34 = -2.5 / 2000.0
        layer.transform = transform
        
        // 因為軸心後移，所以等於 plane 往前移，那直接 render 圖片會有一點放大，所以要先做一個 translate back 
        layer.anchorPointZ = -self.navigationBar.bounds.height/2
        let moveBackMatrix = CATransform3DTranslate(transform, 0.0, 0.0, -self.navigationBar.bounds.height/2)
        let initialMatrix = CATransform3DRotate(moveBackMatrix, CGFloat.pi * (startAngle/180.0), 1.0, 0.0, 0.0)
        let finalMatrix = CATransform3DRotate(moveBackMatrix, CGFloat.pi * (endAngle/180.0), 1.0, 0.0, 0.0)
        
        let flipAnim = CABasicAnimation(keyPath: "transform")
        flipAnim.fromValue = initialMatrix
        flipAnim.toValue = finalMatrix
        flipAnim.delegate = self
        flipAnim.duration = duration
        flipAnim.fillMode = CAMediaTimingFillMode.forwards
        flipAnim.timingFunction = CAMediaTimingFunction(name: timingFunc)
        flipAnim.beginTime = CACurrentMediaTime() + delay
        
        let key = "rotate\(index)"
        layer.add(flipAnim, forKey: key)
        //let anim = layer.animation(forKey: key) as? CABasicAnimation
    }
}

extension ViewController: CAAnimationDelegate {
    
    func animationDidStart(_ anim: CAAnimation) {
        guard let flipAnim = anim as? CABasicAnimation else {return}

    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let flipAnim = anim as? CABasicAnimation else {return}

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if self.currentIndex == .naviBar1 {
            self.navigationBar.isHidden = false
            self.navigationBar2.isHidden = true
            self.layer1.isHidden = true
            self.layer2.isHidden = true
        } else {
            self.navigationBar.isHidden = true
            self.navigationBar2.isHidden = false
            self.layer1.isHidden = true
            self.layer2.isHidden = true
        }
        CATransaction.commit()
    }

}

extension UIView {
    
    func takeSnapshot(_ frame: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.translateBy(x: frame.origin.x * -1, y: frame.origin.y * -1)
        
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

