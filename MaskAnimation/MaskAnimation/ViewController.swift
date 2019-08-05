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
    var currentDisplayView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var colors: [UIColor] = [#colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)]
        for i in 0..<3 {
            let view = UIView(frame: CGRect.zero)
            view.tag = i
            let label = UILabel(frame: CGRect.zero)
            label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            label.text = "view \(i+1)"
            label.textAlignment = NSTextAlignment.center
            view.tag = i+1
            view.backgroundColor = colors[i]
            view.addSubview(label)
            self.containerView.addSubview(view)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.translatesAutoresizingMaskIntoConstraints = false
            
            view.addConstraints( NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["label":label]) )
            view.addConstraint( NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 0.5, constant: 0) )
            //view.addConstraints( NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["label":label]) )

            self.containerView.addConstraints( NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view":view]) )
            self.containerView.addConstraints( NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view":view]) )
        }
        
        guard let targetView = self.containerView.viewWithTag(1) else {return}
        self.containerView.bringSubviewToFront(targetView)
        self.currentDisplayView = targetView
    }
    
    // MARK: - Operation
    
    func showView( targetView: UIView) {
        

        let circleInitialPath = UIBezierPath(arcCenter: CGPoint.zero, radius: 15, startAngle: 0, endAngle: CGFloat(2.0 * Float.pi), clockwise: true)
        let circleFinalPath = UIBezierPath(arcCenter: CGPoint.zero, radius: targetView.bounds.size.height * 1.5, startAngle: 0, endAngle: CGFloat(2.0 * Float.pi), clockwise: true)
        
        let clipLayer = CAShapeLayer()
        clipLayer.path = circleFinalPath.cgPath
        targetView.layer.mask = clipLayer
        
        //Mask Animation
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.duration = 1.0
        maskLayerAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        maskLayerAnimation.fromValue = circleInitialPath.cgPath
        maskLayerAnimation.toValue = circleFinalPath.cgPath
        maskLayerAnimation.delegate = self
        clipLayer.add(maskLayerAnimation, forKey: "path")
        
    }
    
    // MARK: - Action
    
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

extension ViewController: CAAnimationDelegate {
    func animationDidStart(_ anim: CAAnimation) {
        print("animation start!!")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        print("animation stop!!")
    }
}
