//
//  ViewController.swift
//  FoldingView
//
//  Created by GevinChen on 2019/8/12.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import QuickLook

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var flipView: FoldingView!
    
    // 指定摺幾次
    // 要有一個FoldingAnimationView，裡面有一堆 FlipView
    // 最後一摺有兩個 FlipView，各翻 90 度，最後一個要直接呈現 back ground 的內容
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.flipView.attach(targetView: imageView, totalFlip: 5)
    }

    // MARK: - Action
    
    @IBAction func playClicked(_ sender: Any) {
        self.flipView.unfolding()
    }
    
    @IBAction func slideChanged(_ sender: Any) {
        
        
    }
    
}

