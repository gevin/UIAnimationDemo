//
//  FoldingView.swift
//  FoldingView
//
//  Created by GevinChen on 2019/8/12.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit

class FoldingView: UIView {

    var showSnapshot = true
    var halfFlipDuration = 0.3
    var flipCount: Int = 0
    private var _totalFlip: Int = -1 // 1 fold has 2 surface, 2 fold has 3 surface ... etc

    private var _snapshotContainerView = UIView() // to bound display area of _snapshotView
    private var _snapshotView = UIImageView() // display snapshot of _attachTarget 
    private var _flipLayers: [CALayer] = []
    private var _flipHeight: CGFloat = 0.0
    private var _attachTarget: UIView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.white
        self.addSubview(_snapshotContainerView)
        self._snapshotContainerView.addSubview(self._snapshotView)
        self._snapshotContainerView.clipsToBounds = true
        self.isHidden = true
    }
    
    
    func attach( targetView: UIView, totalFlip: Int ) {
        self._attachTarget = targetView
        self._totalFlip = totalFlip
        _snapshotView.image = nil
        
        // remove old view
        for layer in self._flipLayers {
            layer.removeFromSuperlayer()
        }
        
        self._flipLayers = []
        for i in 0..<totalFlip {
            
            let flipSubLayer1 = CALayer()
            flipSubLayer1.isHidden = true
            flipSubLayer1.backgroundColor = UIColor(displayP3Red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor            
            let flipSubLayer2 = CALayer()
            flipSubLayer2.isHidden = true
            flipSubLayer2.backgroundColor = UIColor(displayP3Red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor
            self._flipLayers.append(flipSubLayer1)
            self._flipLayers.append(flipSubLayer2)
            self.layer.addSublayer(flipSubLayer1)
            self.layer.addSublayer(flipSubLayer2)
            
        }
    }
    
    /**
      One flip is rendered by 2 UIViews. The first one rotate angle 0 ~ 90, and second one rotate angle 90 ~ 180 
      The reason is you can display different content in front and behind of the flip page
     */
    func unfolding() {
        
        guard let targetView = self._attachTarget else {return}
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        self.flipCount = 0
        self.isHidden = false
        self.bounds = targetView.bounds
        self.frame = targetView.frame
        self._flipHeight = targetView.bounds.size.height / CGFloat(_totalFlip+1)
        _snapshotView.image = targetView.takeSnapshot(targetView.bounds)
        _snapshotView.frame = self.bounds
        self._snapshotContainerView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self._flipHeight)
        
        for i in 0..<self._totalFlip {
            
            // first half flip
            let flipSublayer1 = self._flipLayers[i*2]
            flipSublayer1.transform = CATransform3DIdentity
            flipSublayer1.anchorPoint = CGPoint(x: 0.5, y: 1.0) // should setup anchor before give 'frame'
            flipSublayer1.isHidden = true
            flipSublayer1.bounds = CGRect(x: 0, y: 0, width: self.bounds.width, height: self._flipHeight)
            flipSublayer1.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self._flipHeight)
            flipSublayer1.frame = flipSublayer1.frame.offsetBy(dx: 0, dy: self._flipHeight * CGFloat(i) )
            
            if showSnapshot {
                let cropImage1 = targetView.takeSnapshot( CGRect(x: 0, y: self._flipHeight * CGFloat(i), width: self.bounds.width, height: self._flipHeight))
                flipSublayer1.contents = cropImage1?.cgImage
            }
             
            if flipSublayer1.sublayers == nil {
                let label = CATextLayer()
                let font = UIFont(name: "Helvetica-Bold", size: 20.0)
                let fontName: CFString = font?.fontName as! CFString
                let fontRef: CGFont? = CGFont(fontName)
                label.font = fontRef
                label.fontSize = font?.pointSize ?? 0.0
                label.string = "\(i*2)"
                label.alignmentMode = CATextLayerAlignmentMode.center
                label.foregroundColor = UIColor.black.cgColor
                label.backgroundColor = UIColor.white.cgColor
                label.frame = CGRect(x: flipSublayer1.frame.width/2 - 30, y: flipSublayer1.frame.height/2 - 12, width: 60, height: 24)
                flipSublayer1.addSublayer(label)
            }
            
            flipSublayer1.removeAllAnimations()
            self.rotate(layer: flipSublayer1,
                        index: i*2,
                        from: 0.0,
                        to: -90.0,
                        timingFunc: CAMediaTimingFunctionName.easeIn, 
                        duration: halfFlipDuration, 
                        delay: halfFlipDuration * Double(i*2) )

            // last half flip
            let flipSublayer2 = self._flipLayers[i*2 + 1]
            flipSublayer2.transform = CATransform3DIdentity
            flipSublayer2.anchorPoint = CGPoint(x: 0.5, y: 0.0) // should setup anchor before give 'frame'
            flipSublayer2.isHidden = true
            flipSublayer2.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self._flipHeight)
            flipSublayer2.frame = flipSublayer2.frame.offsetBy(dx: 0, dy: self._flipHeight * CGFloat(i+1))
            
            if showSnapshot || i == self._totalFlip-1 {
                let cropImage2 = targetView.takeSnapshot( CGRect(x: 0, y: self._flipHeight * CGFloat(i+1), width: self.bounds.width, height: self._flipHeight))
                flipSublayer2.contents = cropImage2?.cgImage
            }
            
            if flipSublayer2.sublayers == nil {
                let label = CATextLayer()
                let font = UIFont(name: "Helvetica-Bold", size: 16.0)
                let fontName: CFString = font?.fontName as! CFString
                let fontRef: CGFont? = CGFont(fontName)
                label.font = fontRef
                label.fontSize = font?.pointSize ?? 0.0
                label.string = "\(i*2 + 1)"
                label.alignmentMode = CATextLayerAlignmentMode.center
                label.foregroundColor = UIColor.black.cgColor
                label.backgroundColor = UIColor.white.cgColor
                label.frame = CGRect(x: flipSublayer2.frame.width/2 - 30, y: flipSublayer2.frame.height/2 - 12, width: 60, height: 24)
                flipSublayer2.addSublayer(label)
            }
            
            flipSublayer2.removeAllAnimations()
            self.rotate(layer: flipSublayer2, 
                        index: i*2 + 1,
                        from: 90.0, 
                        to: 0.0,
                        timingFunc: CAMediaTimingFunctionName.easeOut,
                        duration: halfFlipDuration, 
                        delay: halfFlipDuration * Double(i*2 + 1))
        }
        
        // show the first flip surface
        self._flipLayers.first?.isHidden = false
        
        CATransaction.commit()
    }
    
    private func rotate( layer: CALayer, index: Int, from startAngle: CGFloat, to endAngle: CGFloat, timingFunc: CAMediaTimingFunctionName, duration: CFTimeInterval, delay: CFTimeInterval ) {
        
        var transform = CATransform3DIdentity
        transform.m34 = -2.5 / 2000.0
        layer.transform = transform
        
        let initialMatrix = CATransform3DRotate(transform, CGFloat.pi * (startAngle/180.0), 1.0, 0.0, 0.0)
        let finalMatrix = CATransform3DRotate(transform, CGFloat.pi * (endAngle/180.0), 1.0, 0.0, 0.0)
        
        let flipAnim = CABasicAnimation(keyPath: "transform")
        flipAnim.fromValue = initialMatrix
        flipAnim.toValue = finalMatrix
        flipAnim.delegate = self
        flipAnim.duration = duration
        flipAnim.fillMode = CAMediaTimingFillMode.forwards
        flipAnim.timingFunction = CAMediaTimingFunction(name: timingFunc)
        // #Gevin_Note: 
        // 因為有多個 sublayer 同時執行 animation，所以每個 animation 必須要有相同的起始基準時間 CACurrentMediaTime()
        // 每個 animation 都要設定 beginTime，不然會出現時間不同步，可能一個 animation 還沒執行完，下一個 animation 就執行了
        flipAnim.beginTime = CACurrentMediaTime() + delay
        let key = "rotate\(index)"
        layer.add(flipAnim, forKey: key)
        let anim = layer.animation(forKey: key) as? CABasicAnimation
        anim?.index = index 
        anim?.layer = layer
    }
}

extension FoldingView: CAAnimationDelegate {
    
    func animationDidStart(_ anim: CAAnimation) {
        guard let flipAnim = anim as? CABasicAnimation else {return}
        guard let flipLayer = flipAnim.layer else {return}
        //print("animation \(flipAnim.index) start")
        // change property whitout animation
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        flipLayer.isHidden = false
        CATransaction.commit()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let flipAnim = anim as? CABasicAnimation else {return}
        guard let flipLayer = flipAnim.layer else {return}
        //print("animation \(flipAnim.index) stop")
        
        if self.isOneFlipFinish(anim: flipAnim) {
            // one flip completed, display more content
            self._snapshotContainerView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self._flipHeight + self._flipHeight * CGFloat(self.flipCount+1))
            if self.flipCount < self._totalFlip {
                // one flip completed
                self.flipCount += 1
            } else {
                // all completed
                self.isHidden = true
            }
        }
        flipAnim.index = -1
        flipAnim.layer = nil
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        flipLayer.isHidden = true
        flipLayer.contents = nil
        CATransaction.commit()
    }
    
    private func isOneFlipFinish( anim: CABasicAnimation ) -> Bool {
        return (anim.index % 2 == 1)
    }
}

extension CABasicAnimation {
    
    struct AssociatedKeys {
        static var layerKey: UInt8 = 0
        static var indexKey: UInt8 = 0
    }

    var index: Int {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.indexKey) as? Int else { return -1 }
            return value
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.indexKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    var layer: CALayer? {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.layerKey) as? CALayer else { return nil }
            return value
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.layerKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
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



