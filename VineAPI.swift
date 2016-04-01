//
//  VineAPI.swift
//  WineWatch
//
//  Created by Филипп Белов on 3/27/16.
//  Copyright © 2016 Philip Belov. All rights reserved.
//

import UIKit

class VineAPI: NSObject {
    
    class var sharedInstance : VineAPI {
        struct Singleton {
            static let instance = VineAPI()
        }
        return Singleton.instance
    }
    
    override init() {
        super.init()
    }
    
    func getPopular(forPage page: Int = 1, completion: (data: NSData?) -> Void) {
        
        let urlString = "https://api.vineapp.com/timelines/popular?page=\(page)"
        guard let url = NSURL(string: urlString) else { return }
        let request = NSURLRequest(URL: url)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error == nil && data != nil {
                completion(data: data!)
            } else {
                completion(data: nil)
            }
        }
        
        task.resume()
        
    }
    
    
}
