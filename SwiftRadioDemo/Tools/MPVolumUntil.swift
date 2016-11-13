//
//  MPVolumUntil.swift
//  SwiftRadioDemo
//
//  Created by Fan on 2016/11/9.
//  Copyright © 2016年 Jugg. All rights reserved.
//

import UIKit
import MediaPlayer

class MPVolumUntil : NSObject {
    
    var volumValue : Float = 0.0
    var slide : UISlider?
    
    
    fileprivate var mpVolumeView : MPVolumeView!
    
    static let shared = MPVolumUntil()

    func loadMPVolumeView() {
        mpVolumeView = MPVolumeView()
//        mpVolumeView.isHidden = true
//        
//        let apt = UIApplication.shared.delegate as? AppDelegate
//        let window = apt?.window
//        window?.addSubview(mpVolumeView)
    }
    
    func registerVolumeChangeEvent() {
        NotificationCenter.default.addObserver(self, selector: #selector(volumeChangedNotification(noti:)), name: Notification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
    }
    
    func unregisterVolumeChangeEvent() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
    }
    
    func setVolumValue(newValue: Float) {
        if slide != nil {
            generateMPVolumeSlider()
        }
        slide?.value = newValue
    }
    
    func getSlide() -> UISlider? {
        for view in mpVolumeView.subviews {
            if NSStringFromClass(view.classForCoder) == "MPVolumeSlider" {
                slide = view as? UISlider
                return slide!
            }
        }
        return nil
    }
}


// MARK: - Notification Event
extension MPVolumUntil {
    func volumeChangedNotification(noti: Notification)  {
        
    }
}

extension MPVolumUntil {
    func generateMPVolumeSlider() {
        for view in mpVolumeView.subviews {
            if view.description == "MPVolumeSlider" {
                slide = view as? UISlider
                break
            }
        }
    }
}
