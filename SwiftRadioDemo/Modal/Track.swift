//
//  Track.swift
//  SwiftRadioDemo
//
//  Created by Fan on 2016/11/7.
//  Copyright © 2016年 Jugg. All rights reserved.
//

import UIKit

struct Track {
    var title : String = ""
    var artist : String = ""
    var artworkURL : String = ""
    var artworkImage = UIImage(named: "albumArt")
    var artworkLoaded = false
    var isPlaying : Bool = false
}
