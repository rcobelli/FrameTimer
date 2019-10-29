//
//  VideoView.swift
//  FrameTime
//
//  Created by Ryan Cobelli on 10/28/19.
//  Copyright © 2019 rybel-llc. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoView: UIView {
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var isLoop: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func configure(videoURL: URL) {
        player = AVPlayer(url: videoURL)
		playerLayer = AVPlayerLayer(player: player)
		playerLayer?.frame = bounds
		playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
		if let playerLayer = self.playerLayer {
			layer.addSublayer(playerLayer)
		}
		NotificationCenter.default.addObserver(self, selector: #selector(reachTheEndOfTheVideo(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
    }
    
    func play() {
		if player?.timeControlStatus != AVPlayer.TimeControlStatus.playing {
            player?.play()
        }
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        player?.pause()
		player?.seek(to: CMTime.zero)
    }
    
	@objc func reachTheEndOfTheVideo(_ notification: Notification) {
        if isLoop {
            player?.pause()
			player?.seek(to: CMTime.zero)
            player?.play()
        }
    }
}
