//
//  AnalyzeViewController.swift
//  FrameTime
//
//  Created by Ryan Cobelli on 10/28/19.
//  Copyright © 2019 rybel-llc. All rights reserved.
//

import UIKit
import AVKit
import FDWaveformView

class AnalyzeViewController: UIViewController {
	
	var videoPath : URL?
	var fps = 0
	var fpsHZ = 0.0
	var playbackRate : Float = 0.0
	
	var player : AVPlayer?
	var currentTime = 0.0
	var duration = 0.0
	
	var frame = 0
	var markedFrame = 0
	var markedFrameSet = false
	
	var nextFrameTimer = Timer()
	var prevFrameTimer = Timer()
	
	var firstCall = true
	var interfaceStyle = UIBlurEffect.Style.dark
	
	// MARK: IBOutlets
	
	@IBOutlet weak var videoView: VideoView!
	@IBOutlet weak var waveFormView: FDWaveformView!
	
	@IBOutlet weak var setKeyFrameButton: UIButton! {
		didSet {
			setKeyFrameButton.layer.cornerRadius = 10
		}
	}
	@IBOutlet weak var keyframeDiffLabel: UILabel!
	
	@IBOutlet weak var currentFrameLabel: UILabel!
	@IBOutlet weak var currentTimeLabel: UILabel!
	
	@IBOutlet weak var prevFrameButton: UIButton! {
		didSet {
			prevFrameButton.layer.cornerRadius = 30
		}
	}
	@IBOutlet weak var nextFrameButton: UIButton! {
		didSet {
			nextFrameButton.layer.cornerRadius = 30
		}
	}
	
	// MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
		
		fpsHZ = 1.0 / Double(fps)
    }
	
	override func viewDidAppear(_ animated: Bool) {
		if firstCall {
			videoView.configure(videoURL: videoPath!)
			videoView.play()
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
				self.videoView.player?.currentItem?.step(byCount: 1)
			})
			
			let asset = videoView.player?.currentItem!.asset
			let tracks = asset!.tracks(withMediaType: .video)
			playbackRate = tracks.first!.nominalFrameRate
			
			player = self.videoView.player!
			
			waveFormView.audioURL = videoPath
			waveFormView.doesAllowScrubbing = false
			waveFormView.doesAllowStretch = false
			waveFormView.doesAllowScroll = false
			if #available(iOS 13.0, *) {
				waveFormView.wavesColor = UIColor.label
			} else {
				waveFormView.wavesColor = UIColor.black
			}
			waveFormView.progressColor = UIColor.systemBlue
			
			firstCall = false
			
			updateButtons()
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		nextFrameTimer.invalidate()
		prevFrameTimer.invalidate()
	}
	
	
	// MARK: Keyframe Action
	
	@IBAction func addKeyFrame(sender: Any) {
		if markedFrameSet {
			markedFrameSet = false
			setKeyFrameButton.setTitle("Mark Frame", for: .normal)
			keyframeDiffLabel.text = "Time Diff: 0.00"
			keyframeDiffLabel.alpha = 0.5
		} else {
			markedFrame = frame
			markedFrameSet = true
			setKeyFrameButton.setTitle("Unmark Frame", for: .normal)
			keyframeDiffLabel.alpha = 1.0
		}
	}
	
	// MARK:  Next Frame Actions
	
	@IBAction func nextFrameDown(sender: Any) {
		nextFrame()
		nextFrameTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(nextFrame), userInfo: nil, repeats: true)
	}
	
	@IBAction func nextFrameUp(sender: Any) {
		nextFrameTimer.invalidate()
	}
	
	@objc func nextFrame() {
		updateTimeVals()
		
		if (videoView.player?.currentItem!.canStepForward)! && currentTime < duration {
			videoView.player?.currentItem?.step(byCount: 1)
			frame += 1
		}
		
		updateLabels()
	}
	
	// MARK: Previous Frame Actions
	
	@IBAction func prevFrameDown(sender: Any) {
		prevFrame()
		prevFrameTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(prevFrame), userInfo: nil, repeats: true)
	}
	
	@IBAction func prevFrameUp(sender: Any) {
		prevFrameTimer.invalidate()
	}
	
	@objc func prevFrame() {
		updateTimeVals()
		
		if (videoView.player?.currentItem!.canStepBackward)! && currentTime > 0 {
			videoView.player?.currentItem?.step(byCount: -1)
			frame -= 1
		}
		
		updateLabels()
	}
	
	// MARK: Routine Calculations
	
	func updateLabels() {
		currentFrameLabel.text = "Current Frame: \(frame)"
		currentTimeLabel.text = "Current Time (s): " + String(format: "%.2f", currentTime)
		
		let completionPercentage = (player?.currentItem?.currentTime().seconds)! / (player?.currentItem!.duration.seconds)!
		let topFrame = Int(Double(self.waveFormView.totalSamples) * completionPercentage)
		let range = 0..<topFrame
		waveFormView.highlightedSamples = range
		
		if markedFrameSet {
			keyframeDiffLabel.text = "Time Diff (s): " + String(format: "%.2f", Double(frame - markedFrame) * fpsHZ)
		}
	}
	
	func updateTimeVals() {
		currentTime = Double(frame) * fpsHZ
		duration = (player?.currentItem!.duration.seconds)! * fpsHZ * Double(playbackRate)
	}
	
	
	func updateButtons() {
		if traitCollection.userInterfaceStyle == .dark {
			interfaceStyle = .light
		} else {
			interfaceStyle = .dark
		}
		
		var blur = UIVisualEffectView()
		
		blur = UIVisualEffectView(effect: UIBlurEffect(style: interfaceStyle))
		blur.isUserInteractionEnabled = false
		blur.frame = prevFrameButton.bounds
		prevFrameButton.insertSubview(blur, at: 0)
		
		blur = UIVisualEffectView(effect: UIBlurEffect(style: interfaceStyle))
		blur.isUserInteractionEnabled = false
		blur.frame = nextFrameButton.bounds
		nextFrameButton.insertSubview(blur, at: 0)
		
		if interfaceStyle == .light {
			prevFrameButton.setTitleColor(UIColor.black, for: .normal)
			nextFrameButton.setTitleColor(UIColor.black, for: .normal)
		} else {
			nextFrameButton.setTitleColor(UIColor.white, for: .normal)
			prevFrameButton.setTitleColor(UIColor.white, for: .normal)
		}
	}

}
