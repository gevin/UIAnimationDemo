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
    
    let layer1 = CALayer()
    let layer2 = CALayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        
        
    }

    @IBAction func switchClicked(_ sender: Any) {
        self.switchContent()
    }
    
    func switchContent() {
        self.navigationBar.isHidden = false
        self.navigationBar2.isHidden = false
        let image1 = self.navigationBar.takeSnapshot(self.navigationBar.bounds)
        let image2 = self.navigationBar2.takeSnapshot(self.navigationBar2.bounds)

        layer1.bounds = self.containerView.bounds
        layer1.frame = CGRect(origin: CGPoint.zero, size: self.containerView.bounds.size)
        layer1.contents = image1?.cgImage  // #Gevin_Note: 注意，要用 cgImage
        layer2.bounds = self.containerView.bounds
        layer2.frame = CGRect(origin: CGPoint.zero, size: self.containerView.bounds.size)
        layer2.contents = image2?.cgImage  // #Gevin_Note: 注意，要用 cgImage
        
        var transform = CATransform3DIdentity
        transform.m34 = -2.5 / 2000.0

        layer1.anchorPointZ = -self.navigationBar.bounds.height/2
        layer2.anchorPointZ = -self.navigationBar.bounds.height/2
        
        layer1.removeFromSuperlayer()
        layer2.removeFromSuperlayer()
        
        self.containerView.layer.addSublayer(layer1)
        self.containerView.layer.addSublayer(layer2)
        
        self.rotate(layer: layer1, from: 0.0, to: 90.0, timingFunc: CAMediaTimingFunctionName.easeInEaseOut, duration: 1.0, delay: 0.0)
        self.rotate(layer: layer2, from: -90.0, to: 0.0, timingFunc: CAMediaTimingFunctionName.easeInEaseOut, duration: 1.0, delay: 0.0)
        
        self.navigationBar.isHidden = true
        self.navigationBar2.isHidden = true
        
    }
    
    private func rotate( layer: CALayer, from startAngle: CGFloat, to endAngle: CGFloat, timingFunc: CAMediaTimingFunctionName, duration: CFTimeInterval, delay: CFTimeInterval ) {
        
        var transform = CATransform3DIdentity
        transform.m34 = -2.5 / 2000.0
        layer.transform = transform
        
        let initialMatrix = CATransform3DRotate(transform, CGFloat.pi * (startAngle/180.0), 1.0, 0.0, 0.0)
        let finalMatrix = CATransform3DRotate(transform, CGFloat.pi * (endAngle/180.0), 1.0, 0.0, 0.0)
        
        let flipAnim = CABasicAnimation(keyPath: "transform")
        flipAnim.fromValue = initialMatrix
        flipAnim.toValue = finalMatrix
//        flipAnim.delegate = self
        flipAnim.duration = duration
        flipAnim.fillMode = CAMediaTimingFillMode.forwards
        flipAnim.timingFunction = CAMediaTimingFunction(name: timingFunc)
        // #Gevin_Note: 如果是在 animation group 中，不需要加 CACurrentMediaTime()，但如果是直接給 layer，則需要加 CACurrentMediaTime()
        if delay > 0.0 {
            flipAnim.beginTime = CACurrentMediaTime() + delay
        }
        let key = "rotate\(index)"
        layer.add(flipAnim, forKey: key)
        let anim = layer.animation(forKey: key) as? CABasicAnimation
//        anim?.index = index 
//        anim?.view = targetView
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

