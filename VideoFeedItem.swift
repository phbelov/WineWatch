//
//  VideoFeedItem.swift
//  WineWatch
//
//  Created by Филипп Белов on 3/29/16.
//  Copyright © 2016 Philip Belov. All rights reserved.
//

import UIKit

class VideoFeedItem: NSObject {
    let avatarURL: NSURL
    let itemDescription: String
    let userName: String
    let thumbnailURL: NSURL
    let videoURL: NSURL
    let loops: Int
    
    init(avatarURL newAvatarURL: NSURL, itemDescription newItemDescription: String, userName newUserName: String, thumbnailURL newThumbnailURL: NSURL, videoURL newVideoURL: NSURL, loops newLoops: Int) {
        self.avatarURL = newAvatarURL
        self.itemDescription = newItemDescription
        self.userName = newUserName
        self.thumbnailURL = newThumbnailURL
        self.videoURL = newVideoURL
        self.loops = newLoops
        super.init()
    }
        
}
