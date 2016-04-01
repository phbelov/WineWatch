//
//  DetailViewController.swift
//  WineWatch
//
//  Created by Филипп Белов on 3/31/16.
//  Copyright © 2016 Philip Belov. All rights reserved.
//

import UIKit
import AVKit

class DetailViewController: UIViewController {
    
    var videoImage: UIImage!
    var usernameText: String!
    var descriptionText: String!
    var avatarImage: UIImage!
    var videoURL: NSURL!
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    var playerIsPlaying: Bool = false

    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarLabel: UIImageView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        videoImageView.image = videoImage
        descriptionLabel.text = descriptionText
        usernameLabel.text = usernameText
        avatarLabel.image = avatarImage
        
        addVideoLayer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.tapped))
        tapRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.PlayPause.rawValue)]
        self.view.addGestureRecognizer(tapRecognizer)
        
        let backRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.backTapped))
        backRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.Menu.rawValue)]
        self.view.addGestureRecognizer(backRecognizer)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tapped() {
        if playerIsPlaying {
            self.player?.pause()
            playerIsPlaying = false
        } else {
            self.player?.play()
            playerIsPlaying = true
            NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: nil, usingBlock: { (notification) in
                self.player?.seekToTime(kCMTimeZero)
                self.player?.play()
            })
        }
    }
    
    func backTapped() {
        NSOperationQueue.mainQueue().addOperationWithBlock({
            if self.player != nil {
                self.player?.pause()
                self.player = nil
                self.playerLayer = nil
            }
        })
        print("ello")
        self.performSegueWithIdentifier("unwindSegue", sender: self)
    }
    
    func addVideoLayer() {
        self.player = AVPlayer(URL: videoURL)
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer!.frame = self.videoImageView.bounds
        self.videoImageView.layer.addSublayer(self.playerLayer!)
    }
        
}
