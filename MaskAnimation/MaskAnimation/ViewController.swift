//
//  ViewController.swift
//  ClipAnimationDemo
//
//  Created by GevinChen on 2019/8/4.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var slide: UISlider!
    
    var currentDisplayView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var colors: [UIColor] = [#colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)]
        for i in 0..<3 {
            
            // configure view
            let subView = UIView(frame: CGRect.zero)
            subView.tag = i
            let label = UILabel(frame: CGRect.zero)
            label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            label.text = "view \(i+1)"
            label.textAlignment = NSTextAlignment.center
            subView.tag = i+1
            subView.backgroundColor = colors[i]
            
            // configure layout
            subView.addSubview(label)
            self.containerView.addSubview(subView)
            label.translatesAutoresizingMaskIntoConstraints = false
            subView.translatesAutoresizingMaskIntoConstraints = false
            subView.addConstraints( NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["label":label]) )
            subView.addConstraint( NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: subView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 0.5, constant: 0) )
            self.containerView.addConstraints( NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view":subView]) )
            self.containerView.addConstraints( NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view":subView]) )
            
            // init mask layer
            let clipLayer = CAShapeLayer()
            let circleFinalPath = UIBezierPath(arcCenter: CGPoint.zero, radius: self.containerView.bounds.size.height * 1.3, startAngle: 0, endAngle: CGFloat(2.0 * Float.pi), clockwise: true)
            clipLayer.path = circleFinalPath.cgPath
            subView.layer.mask = clipLayer
            
        }
        
        guard let targetView = self.containerView.viewWithTag(1) else {return}
        self.containerView.bringSubviewToFront(targetView)
        self.currentDisplayView = targetView
        
        self.slide.value = 1.0
    }
    
    // MARK: - Operation
    
    func showView( targetView: UIView) {
        
        guard let clipLayer = targetView.layer.mask as? CAShapeLayer else {return}
        //Mask Animation
        let maskLayerAnimation = CABasicAnimation(keyPath: "transform.scale")
        maskLayerAnimation.duration = 1.0
        maskLayerAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        maskLayerAnimation.fromValue = CATransform3DMakeScale( 0.0, 0.0, 1.0)
        maskLayerAnimation.toValue = CATransform3DMakeScale( 1.0, 1.0, 1.0)
        maskLayerAnimation.delegate = targetView
        clipLayer.add(maskLayerAnimation, forKey: "mask_scale")
    }
    
    // MARK: - Action
    
    @IBAction func slideChanged(_ sender: Any) {
        guard let clipLayer = self.currentDisplayView?.layer.mask as? CAShapeLayer else { return }
        if clipLayer.path == nil, let targetView = self.currentDisplayView {
            let circleFinalPath = UIBezierPath(arcCenter: CGPoint.zero, radius: targetView.bounds.size.height * 1.5, startAngle: 0, endAngle: CGFloat(2.0 * Float.pi), clockwise: true)
            clipLayer.path = circleFinalPath.cgPath
        }
        clipLayer.transform = CATransform3DMakeScale(CGFloat(1.0 * self.slide.value), CGFloat(1.0 * self.slide.value), 1.0)

    }
    
    @IBAction func button1Clicked(_ sender: Any) {
        guard let targetView = self.containerView.viewWithTag(1) else {return}
        guard self.currentDisplayView != targetView else {return}
        self.currentDisplayView = targetView
        self.containerView.bringSubviewToFront(targetView)
        self.showView(targetView: targetView)
    }
    
    @IBAction func button2Clicked(_ sender: Any) {
        guard let targetView = self.containerView.viewWithTag(2) else {return}
        guard self.currentDisplayView != targetView else {return}
        self.currentDisplayView = targetView
        self.containerView.bringSubviewToFront(targetView)
        self.showView(targetView: targetView)
    }
    
    @IBAction func button3Clicked(_ sender: Any) {
        guard let targetView = self.containerView.viewWithTag(3) else {return}
        guard self.currentDisplayView != targetView else {return}
        self.currentDisplayView = targetView
        self.containerView.bringSubviewToFront(targetView)
        self.showView(targetView: targetView)
    }
}

extension UIView: CAAnimationDelegate {
    public func animationDidStart(_ anim: CAAnimation) {
        print("animation start!!")
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        print("animation stop!!")
//        guard let maskLayer = self.layer.mask as? CAShapeLayer else {return}
    }
}
