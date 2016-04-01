//
//  VideoCollectionViewCell.swift
//  WineWatch
//
//  Created by Филипп Белов on 3/27/16.
//  Copyright © 2016 Philip Belov. All rights reserved.
//

import UIKit
import AVKit

class VideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    weak var dataTask1: NSURLSessionDataTask?
    weak var dataTask2: NSURLSessionDataTask?
 
    override func prepareForReuse() {
        super.prepareForReuse()
        
        descriptionLabel.alpha = 0.0
        thumbnailImage.image = nil
        userImage.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        descriptionLabel.alpha = 0.0
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({
            if self.focused {
                self.descriptionLabel.alpha = 1.0
            } else {
                self.descriptionLabel.alpha = 0.0
            }
            }, completion: nil)
    }
    
}
