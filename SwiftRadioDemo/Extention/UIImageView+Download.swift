//
//  UIImageView+Download.swift
//  SwiftRadioDemo
//
//  Created by Jacqui on 2016/11/6.
//  Copyright © 2016年 Jugg. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadImageWithURL(_ url: URL, callback: @escaping (UIImage) -> ()) -> URLSessionDownloadTask {
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: url) { [weak self] url, response, error in
            
            if error == nil && url != nil {
                if let data = NSData(contentsOf: url!) {
                    if let image = UIImage(data: data as Data) {
                        DispatchQueue.main.async(execute: { 
                            if let strongSelf = self {
                                strongSelf.image = image
                                callback(image)
                            }
                        })
                    }
                    
                }
            }
        }
        
        downloadTask.resume()
        return downloadTask
    }
}
