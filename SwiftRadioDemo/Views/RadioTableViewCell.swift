//
//  RadioTableViewCell.swift
//  SwiftRadioDemo
//
//  Created by Jacqui on 2016/11/6.
//  Copyright © 2016年 Jugg. All rights reserved.
//

import UIKit
import SnapKit

class RadioTableViewCell: UITableViewCell {

    var stationRadioImage: UIImageView!     ///< 封面图
    var stationRadioNameLbl: UILabel!       ///< 专辑名
    var stationRadioDescLbl: UILabel!       ///< 专辑描述
    
    var downloadTask: URLSessionDownloadTask?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(red: 78/255.0, green: 82/255, blue: 93/255, alpha: 0.6)
        selectedBackgroundView = selectedView
        
        stationRadioImage = UIImageView()
        contentView.addSubview(stationRadioImage)
        
        stationRadioNameLbl = UILabel()
        stationRadioNameLbl.textColor = UIColor.white
        stationRadioNameLbl.font = UIFont.systemFont(ofSize: 18.0)
        contentView.addSubview(stationRadioNameLbl)
        
        stationRadioDescLbl = UILabel()
        stationRadioDescLbl.textColor = UIColor.white
        stationRadioDescLbl.numberOfLines = 0
        stationRadioDescLbl.font = UIFont.systemFont(ofSize: 15.0)
        contentView.addSubview(stationRadioDescLbl)
        
        stationRadioImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(110)
            make.height.equalTo(70)
        }
        
        stationRadioNameLbl.snp.makeConstraints { (make) in
            make.left.equalTo(stationRadioImage.snp.right).offset(20)
            make.bottom.equalTo(stationRadioImage.snp.centerY)
        }
        
        stationRadioDescLbl.snp.makeConstraints { (make) in
            make.left.equalTo(stationRadioImage.snp.right).offset(20)
            make.top.equalTo(stationRadioImage.snp.centerY)
        }
    }
    
    func configureCell(_ radioStation: RadioStation) {
        stationRadioNameLbl.text = radioStation.name
        stationRadioDescLbl.text = radioStation.desc
        
        let imageURL = radioStation.imageURL
        if imageURL.contains("http") {
            if let url = URL(string: imageURL) {
                downloadTask = stationRadioImage.loadImageWithURL(url, callback: { (image) in
                    
                })
            }
        } else if imageURL != "" {
            stationRadioImage.image = UIImage(named: imageURL)
        } else {
            stationRadioImage.image = UIImage(named: "stationImage")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        downloadTask?.cancel()
        downloadTask = nil
        stationRadioImage.image = nil
        stationRadioNameLbl.text = nil
        stationRadioDescLbl.text = nil
    }
}
