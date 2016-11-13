//
//  RadioStation.swift
//  SwiftRadioDemo
//
//  Created by Jacqui on 2016/11/6.
//  Copyright © 2016年 Jugg. All rights reserved.
//

import UIKit

class RadioStation: NSObject {
    var name: String
    var streamURL: String
    var imageURL: String
    var desc: String
    var longDesc: String
    
    init(name: String, streamURL: String, imageURL: String, desc: String, longDesc: String) {
        self.name = name
        self.streamURL = streamURL
        self.imageURL = imageURL
        self.desc = desc
        self.longDesc = longDesc
    }
    
    convenience init(name: String, streamURL: String, imageURL: String, desc: String) {
        self.init(name: name, streamURL: streamURL, imageURL: imageURL, desc: desc, longDesc: "")
    }
    
    class func parseStation(_ stationJSON: JSON) -> (RadioStation) {
        let name = stationJSON["name"].string ?? ""
        let streamURL = stationJSON["streamURL"].string ?? ""
        let imageURL = stationJSON["imageURL"].string ?? ""
        let desc = stationJSON["desc"].string ?? ""
        let longDesc = stationJSON["longDesc"].string ?? ""
        
        let station = RadioStation(name: name, streamURL: streamURL, imageURL: imageURL, desc: desc, longDesc: longDesc)
        return station
    }
}
