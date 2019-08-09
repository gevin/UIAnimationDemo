//
//  ViewController.swift
//  SpinMenu
//
//  Created by GevinChen on 2019/8/7.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var itemList: [UIView] = []
    //let arcCenter = CGPoint(x: 185, y: 280)
    let radius:CGFloat = 120.0
    
    @IBOutlet weak var button: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var imageNames = ["icons8-budgie", "icons8-dove", "icons8-flamingo", "icons8-flying-duck", "icons8-hummingbird", "icons8-kiwi-bird", "icons8-owl" ]
        
        for i in 0..<imageNames.count {
            let menuItem = UIView()
            let control = UIControl(frame: CGRect.zero)
            control.addTarget(self, action: #selector(itemClicked(_:)), for: UIControl.Event.touchUpInside)
            control.tag = i + 1
            let imageView = UIImageView(image: UIImage(named: imageNames[i]))
            imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            control.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            menuItem.bounds = CGRect(x: 0, y: 0, width: 50, height: 50)
            menuItem.isHidden = false
            menuItem.tag = i + 1
            menuItem.addSubview(imageView)
            menuItem.addSubview(control)
            self.view.addSubview(menuItem)
            itemList.append(menuItem)
        }
        itemList = itemList.sorted { (item1:UIView, item2:UIView) -> Bool in
            return item1.tag < item2.tag
        }
//        self.menuItem.isHidden = true
        
    }
    
    @IBAction func playClicked(_ sender: Any) {
        for i in 0..<self.itemList.count {
            let item = self.itemList[i]
            self.playAnimation(item: item, index: i)
        }
    }
    
    @objc
    func itemClicked(_ sender: Any) {
        let control = sender as! UIControl
        print("item \(control.tag) clicked.")
    }
    
    func playAnimation( item: UIView, index: Int ) {

        let startAngle:CGFloat = 60.0 + CGFloat(index) * 30.0
        let endAngle:CGFloat = 180.0 + CGFloat(index) * 30.0
        let path = UIBezierPath(arcCenter: button.center, radius: radius, startAngle: CGFloat.pi * (startAngle/180.0), endAngle: CGFloat.pi * (endAngle/180.0), clockwise: false)
        
        // 繞圓移動
        let moveAlongPath = CAKeyframeAnimation(keyPath: "position")
        moveAlongPath.path = path.cgPath
        moveAlongPath.duration = 0.5
        moveAlongPath.calculationMode = CAAnimationCalculationMode.paced
        moveAlongPath.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)]
        moveAlongPath.fillMode = CAMediaTimingFillMode.forwards

        // item 往右轉30度，模擬有慣性
        item.layer.transform = CATransform3DMakeRotation( CGFloat.pi * (1.0/6.0), 0.0, 0.0, 1.0)
        
        // 移動動畫結束後，往左旋轉回0度
        let rotateAnim = CASpringAnimation(keyPath: "transform.rotation.z")
        rotateAnim.damping = 8 // 值越小，彈越多次
        rotateAnim.initialVelocity = 30.0 // 值越高，往前衝的力道越大
        rotateAnim.mass = 1.0
        rotateAnim.stiffness = 140 // 剛性，回彈的速度，值越大，速度越快
        rotateAnim.duration = 1.0
//        rotateAnim.isRemovedOnCompletion = false
        rotateAnim.fromValue = (CGFloat.pi * (1.0/6.0)) 
        rotateAnim.toValue = 0.0
        rotateAnim.beginTime = 0.5
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [moveAlongPath, /*inertiaAnim,*/ rotateAnim]
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = CAMediaTimingFillMode.forwards
        animationGroup.duration = 1.5 // 要設定總時間長度，不然動畫跑到一半就停了
        animationGroup.delegate = item
        
        item.layer.add(animationGroup, forKey: "animGroup\(item.tag)")
        item.center = self.convertPoint(center: button.center, radius: radius, angle: endAngle)
        item.isHidden = false
    }
    
    func convertPoint( center: CGPoint, radius: CGFloat, angle: CGFloat) -> CGPoint {
        let x = center.x + (radius*cos(CGFloat.pi * (angle/180.0) ))
        let y = center.y + (radius*sin(CGFloat.pi * (angle/180.0) ))
        return CGPoint(x: x, y: y)
    }
    
}

extension UIView: CAAnimationDelegate {
    
    public func animationDidStart(_ anim: CAAnimation) {
        print("item \(self.tag) anim start")
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.layer.removeAllAnimations()
        print("item \(self.tag) anim stop")
        self.layer.transform = CATransform3DMakeRotation( 0.0, 0.0, 0.0, 1.0)
    }
}

