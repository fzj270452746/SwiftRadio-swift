//
//  DataManager.swift
//  SwiftRadioDemo
//
//  Created by Jacqui on 2016/11/6.
//  Copyright © 2016年 Jugg. All rights reserved.
//

import UIKit

class DataManager: NSObject {
    
    //******************************************
    //  Load local JSON Data
    //******************************************
    class func getDataFromFileWithSuccess(_ success: (_ data: Data) -> ()) {
        if let filePath = Bundle.main.path(forResource: "stations", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath), options: .uncached) as Data
                success(data)
            } catch {
                fatalError()
            }
        } else {
            print("The local JSON file could not be found")
        }
    }
    
    //******************************************
    //  REUSABLE DATA/API CALL METHOD
    //******************************************
    class func loadDataFromURL(_ url:URL, completion:@escaping (_ data:Data?, _ error:Error?) -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.allowsCellularAccess          = true
        sessionConfig.timeoutIntervalForRequest     = 15
        sessionConfig.timeoutIntervalForResource    = 30
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        let session = URLSession(configuration: sessionConfig)
        let loadDataTask = session.dataTask(with: url) { (data, response, error) in
            if let responseError = error {
                completion(nil, responseError)
                
                if kDebugLog {
                    print("API ERROR: \(error)")
                }
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let statusError = NSError.init(domain: "com.matthewfecher", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                    
                    if kDebugLog {
                        print("API: HTTP status code has unexpected value")
                    }
                    completion(nil, statusError)
                }
            } else {
                completion(data, nil)
            }
            
        }
        
        loadDataTask.resume()
    }
    
    //*****************************************************************
    // Get LastFM/iTunes Data
    //*****************************************************************
    class func getTrackDataWithSuccess(queryURL: String, success: @escaping ((_ metadata: Data?) -> ())) {
        loadDataFromURL(URL(string: queryURL)!, completion: { (data, error) in
            if let urlData = data {
                success(urlData)
            } else {
                if kDebugLog {
                    print("API TIMEOUT OR ERROR")
                }
            }
        })
    }
}
