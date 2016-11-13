//
//  MenuViewController.swift
//  SwiftRadioDemo
//
//  Created by Fan on 2016/11/10.
//  Copyright © 2016年 Jugg. All rights reserved.
//

import UIKit
import Spring

class MenuViewController: UIViewController {
    
    fileprivate var backImage: UIImageView!     ///<    背景
    fileprivate var centerContainerView : UIView!
    fileprivate var closeBtn : UIButton!
    fileprivate var swiftLogoImg : SpringImageView!
    fileprivate var aboutBtn : SpringButton!
    fileprivate var websiteBtn : SpringButton!
    fileprivate var descLbl : UILabel!
    fileprivate var authorLbl : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

private extension MenuViewController {
    @objc func closePresentView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func aboutMe() {
        
    }
    
    @objc func website() {
        
    }
}

private extension  MenuViewController {
    func setupView() {
        setupBackImage()
        setupContainerView()
    }
    
    /// 创建背景视图
    func setupBackImage() {
        backImage = UIImageView()
        backImage.image = UIImage(named: "background")
        backImage.isUserInteractionEnabled = true
        view.addSubview(backImage)
        
        backImage.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closePresentView))
        backImage.addGestureRecognizer(tapGesture)
    }
    
    func setupContainerView() {
        
        // container
        centerContainerView = UIView()
        centerContainerView.backgroundColor = UIColor.white
        centerContainerView.layer.cornerRadius = 10
        centerContainerView.layer.masksToBounds = true
        
        // close BUtton
        closeBtn = UIButton()
        closeBtn.setTitleColor(UIColor(red: 42/255, green: 104/255, blue: 165/255, alpha: 1), for: .normal)
        closeBtn.setImage(UIImage(named: "btn-close"), for: .normal)
        closeBtn.addTarget(self, action: #selector(closePresentView), for: .touchUpInside)
        
        //logo
        swiftLogoImg = SpringImageView()
        swiftLogoImg.image = UIImage(named: "swift-radio-black")
        
        swiftLogoImg.animation = "zoomIn"
        swiftLogoImg.autostart = true
        swiftLogoImg.delay = 0.3
        
        // about button
        aboutBtn = SpringButton()
        aboutBtn.setTitle("About", for: .normal)
        aboutBtn.setTitleColor(UIColor.white, for: .normal)
        aboutBtn.backgroundColor = UIColor.init(red: 50/255.0, green: 124/255.0, blue: 196/255.0, alpha: 1)
        aboutBtn.addTarget(self, action: #selector(aboutMe), for: .touchUpInside)
        
        aboutBtn.animation = "slideRight"
        aboutBtn.autostart = true
        aboutBtn.delay = 0.6
        aboutBtn.damping = 1
        
        // website button
        websiteBtn = SpringButton()
        websiteBtn.setTitle("Website", for: .normal)
        websiteBtn.setTitleColor(UIColor.white, for: .normal)
        websiteBtn.backgroundColor = UIColor.init(red: 42/255.0, green: 104/255.0, blue: 165/255.0, alpha: 1)
        websiteBtn.addTarget(self, action: #selector(website), for: .touchUpInside)
        
        websiteBtn.animation = "slideLeft"
        websiteBtn.autostart = true
        websiteBtn.delay = 0.6
        websiteBtn.damping = 1
        
        //description Label
        descLbl = UILabel()
        descLbl.text = "Open Source Project"
        descLbl.textColor = UIColor.black
        descLbl.font = UIFont.systemFont(ofSize: 13.0)
        descLbl.textAlignment = .center
        
        //Author Label
        authorLbl = UILabel()
        authorLbl.text = "Created by: Rice"
        authorLbl.textColor = UIColor.gray
        authorLbl.font = UIFont.systemFont(ofSize: 13.0)
        authorLbl.textAlignment = .center
        
        // addSubview
        view.addSubview(centerContainerView)
        centerContainerView.addSubview(closeBtn)
        centerContainerView.addSubview(swiftLogoImg)
        centerContainerView.addSubview(aboutBtn)
        centerContainerView.addSubview(websiteBtn)
        centerContainerView.addSubview(descLbl)
        centerContainerView.addSubview(authorLbl)
        
        // Layout constraints
        centerContainerView.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
            make.width.equalTo(250)
            make.height.equalTo(206)
        }
        
        closeBtn.snp.makeConstraints { (make) in
            make.left.equalTo(centerContainerView).offset(10)
            make.top.equalTo(centerContainerView).offset(10)
            make.width.equalTo(22)
            make.height.equalTo(22)
        }
        
        swiftLogoImg.snp.makeConstraints { (make) in
            make.bottom.equalTo(centerContainerView.snp.centerY).offset(-10)
            make.centerX.equalTo(centerContainerView)
            make.width.equalTo(180)
            make.height.equalTo(70)
        }
        
        aboutBtn.snp.makeConstraints { (make) in
            make.top.equalTo(centerContainerView.snp.centerY)
            make.right.equalTo(centerContainerView.snp.centerX)
            make.width.equalTo(86)
            make.height.equalTo(36)
        }
        
        websiteBtn.snp.makeConstraints { (make) in
            make.top.equalTo(aboutBtn)
            make.left.equalTo(aboutBtn.snp.right)
            make.width.equalTo(aboutBtn)
            make.height.equalTo(aboutBtn)
        }
        
        authorLbl.snp.makeConstraints { (make) in
            make.bottom.equalTo(centerContainerView.snp.bottom).offset(-15)
            make.centerX.equalTo(centerContainerView)
        }
        
        descLbl.snp.makeConstraints { (make) in
            make.bottom.equalTo(authorLbl.snp.top).offset(-5)
            make.centerX.equalTo(centerContainerView)
        }
    }
}
