//
//  VideoFeedCollectionViewController.swift
//  WineWatch
//
//  Created by Филипп Белов on 3/27/16.
//  Copyright © 2016 Philip Belov. All rights reserved.
//

import UIKit
import AVKit

private let reuseIdentifier = "VideoCell"
private var playerIsPlaying : Bool = false

class VideoFeedCollectionViewController: UICollectionViewController {
    
    var feed: VideoFeed? = nil {
        didSet {
            self.collectionView?.reloadData()
        }
    }
    
    var currentPageIndex = 1
    var numberOfPages = 5
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: – Gesture Recognizers
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(VideoFeedCollectionViewController.tapped))
        tapRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.PlayPause.rawValue)];
        self.view.addGestureRecognizer(tapRecognizer)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.addItems(forPage: currentPageIndex)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        let destinationVC = segue.destinationViewController as! DetailViewController
        
        if let focusedCell = UIScreen.mainScreen().focusedView as? VideoCollectionViewCell {
            destinationVC.avatarImage = focusedCell.userImage.image
            destinationVC.videoImage = focusedCell.thumbnailImage.image
            destinationVC.descriptionText = focusedCell.descriptionLabel.text
            destinationVC.usernameText = focusedCell.userNameLabel.text
            
            let indexPath = collectionView?.indexPathForCell(focusedCell)
            destinationVC.videoURL = self.feed?.items[(indexPath?.row)!].videoURL
            
            self.player?.pause()
            self.player = nil
            self.playerLayer = nil
        }
    }

    // MARK: – UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.feed?.items.count ?? 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! VideoCollectionViewCell
    
        let item = self.feed?.items[indexPath.row]
        
        cell.descriptionLabel.text = item?.itemDescription
        cell.userNameLabel.text = item?.userName
        
        let avatarRequest = NSURLRequest(URL: (item?.avatarURL)!)
        let thumbnailRequest = NSURLRequest(URL: (item?.thumbnailURL)!)
        cell.dataTask1 = NSURLSession.sharedSession().dataTaskWithRequest(avatarRequest, completionHandler: { (data, response, error) in
            if error == nil && data != nil {
                let image = UIImage(data: data!)
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    cell.userImage.image = image
                    cell.userImage.layer.cornerRadius = cell.userImage.frame.size.width / 2
                    cell.userImage.clipsToBounds = true
                })
            }
        })
        cell.dataTask1?.resume()
        cell.dataTask2 = NSURLSession.sharedSession().dataTaskWithRequest(thumbnailRequest, completionHandler: { (data, response, error) in
            if error == nil && data != nil {
                let image = UIImage(data: data!)
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    cell.thumbnailImage.image = image
                })
            }
        })
        cell.dataTask2?.resume()
    
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == (self.collectionView?.numberOfItemsInSection(0))!-1 {
            self.currentPageIndex += 1
            self.addItems(forPage: currentPageIndex)
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        
        if let previousFocusedView = context.previouslyFocusedView as? VideoCollectionViewCell {
            NSOperationQueue.mainQueue().addOperationWithBlock({
                if previousFocusedView.thumbnailImage.layer.sublayers?.count > 1 {
                    previousFocusedView.thumbnailImage.layer.sublayers?[1].removeFromSuperlayer()
                }
            })
        }
        if let focusedView = context.nextFocusedView as? VideoCollectionViewCell {
            NSOperationQueue.mainQueue().addOperationWithBlock({
                if !playerIsPlaying && self.player != nil {
                    self.player?.play()
                }
                if focusedView.thumbnailImage.layer.sublayers?.count > 1 {
                    focusedView.thumbnailImage.layer.sublayers?[1].removeFromSuperlayer()
                }
            })
        }
        
    }
    
    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? VideoCollectionViewCell {
            cell.dataTask1?.cancel()
            cell.dataTask2?.cancel()
            NSOperationQueue.mainQueue().addOperationWithBlock({
                if cell.userImage != nil && cell.thumbnailImage.image != nil {
                    cell.userImage.image = nil
                    cell.thumbnailImage.image = nil
                }
            })
        }
    }
    
    func addItems(forPage page : Int) {
        if currentPageIndex > numberOfPages {
            return
        }
        VineAPI.sharedInstance.getPopular(forPage: currentPageIndex) { (data) in
            if let data = data {
                let videoFeed = VideoFeed(data: data, sourceURL: NSURL(string: "https://api.vineapp.com/timelines/popular")!)
                if let feed = videoFeed {
                    if self.feed == nil {
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            self.feed = feed
                        })
                    } else {
                        for item in feed.items {
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                self.feed?.items.append(item)
                                self.collectionView?.insertItemsAtIndexPaths([NSIndexPath(forItem: (self.feed?.items.count)! - 1, inSection: 0)])
                            })
                        }
                    }
                }
            }
        }
    }
    
    func tapped() {
        if playerIsPlaying {
            self.player?.pause()
            playerIsPlaying = false
        } else {
            self.player?.play()
            playerIsPlaying = true
        }
    }
    
    @IBAction func unwindViewController (sender : UIStoryboardSegue) {
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollingFinish()
        }
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.scrollingFinish()
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.player?.pause()
        self.player = nil
    }

    func scrollingFinish() {
        if let focusedCell = UIScreen.mainScreen().focusedView as? VideoCollectionViewCell {
            guard let indexPath = collectionView?.indexPathForCell(focusedCell) else { return }
            collectionView!.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                let url = self.feed!.items[indexPath.row].videoURL
                self.player = AVPlayer(URL: url)
                let playerLayer = AVPlayerLayer(player: self.player)
                playerLayer.frame = focusedCell.thumbnailImage.focusedFrameGuide.layoutFrame
                focusedCell.thumbnailImage.layer.addSublayer(playerLayer)
                self.player?.play()
                playerIsPlaying = true
                NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: nil, usingBlock: { (notification) in
                    self.player?.seekToTime(kCMTimeZero)
                    self.player?.play()
                })
            })

        }
    }
}
