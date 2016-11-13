//
//  AnimationFrames.swift
//  SwiftRadioDemo
//
//  Created by Fan on 2016/11/7.
//  Copyright © 2016年 Jugg. All rights reserved.
//

import UIKit

class AnimationFrames: NSObject {
    class func createFrames() -> [UIImage] {
        var animationImages = [UIImage]()
        for i in 0...3 {
            if let image = UIImage(named: "NowPlayingBars-\(i)") {
                animationImages.append(image)
            }
        }
        
        for i in stride(from: 2, through: 0, by: -1) {
            if let image = UIImage(named: "NowPlayingBars-\(i)") {
                animationImages.append(image)
            }
        }
        
        return animationImages
    }
}
