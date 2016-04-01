//
//  VideoFeed.swift
//  WineWatch
//
//  Created by Филипп Белов on 3/29/16.
//  Copyright © 2016 Philip Belov. All rights reserved.
//

import UIKit

class VideoFeed: NSObject {
    var items: [VideoFeedItem]
    let sourceURL: NSURL
        
    init (items newItems: [VideoFeedItem], sourceURL newURL: NSURL) {
        self.items = newItems
        self.sourceURL = newURL
        super.init()
    }
    
    convenience init? (data: NSData, sourceURL url: NSURL) {
        var newItems = [VideoFeedItem]()
        
        var jsonObject: Dictionary<String, AnyObject>?
        
        do {
            jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? Dictionary<String,AnyObject>
        } catch {
            
        }
        
        guard let feedRoot = jsonObject else { return nil }
        guard let feedData = feedRoot["data"] as? Dictionary<String,AnyObject> else { return nil }
//        let numberOfItems = feedData["count"] as? Int
        guard let records = feedData["records"] as? Array<AnyObject> else { return nil }
        
        for record in records {
            
            guard let recordDict = record as? Dictionary<String,AnyObject> else { continue }
            
            guard let avatarURLString = recordDict["avatarUrl"] as? String else { continue }
            guard let avatarURL = NSURL(string: avatarURLString) else { continue }
            
            guard let itemDescription = recordDict["description"] as? String else { continue }
            
            guard let userName = recordDict["username"] as? String else { continue }
            
            guard let videoURLString = recordDict["videoUrl"] as? String else { continue }
            guard let videoURL = NSURL(string: videoURLString) else { continue }
            
            guard let thumbnailURLString = recordDict["thumbnailUrl"] as? String else { continue }
            guard let thumbnailURL = NSURL(string: thumbnailURLString) else { continue }
            
            guard let loopsDict = recordDict["loops"] as? Dictionary<String,AnyObject> else { continue }
            guard let loops = loopsDict["count"] as? Int else { continue }
            
            let newVideoFeedItem = VideoFeedItem(avatarURL: avatarURL, itemDescription: itemDescription, userName: userName, thumbnailURL: thumbnailURL, videoURL: videoURL, loops: loops)
            newItems.append(newVideoFeedItem)
        }
        
        self.init(items: newItems, sourceURL: url)

    }
        
}
