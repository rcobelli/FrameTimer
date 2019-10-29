//
//  ViewController.swift
//  FrameTime
//
//  Created by Ryan Cobelli on 10/28/19.
//  Copyright © 2019 rybel-llc. All rights reserved.
//

import UIKit
import Gallery
import AVFoundation
import AVKit

class ViewController: UIViewController, GalleryControllerDelegate {
	
	var videoURL : URL?
	
	var spinner = UIActivityIndicatorView()
	
	// MARK: IBOutlets
	
	@IBOutlet weak var fpsSelector: UISegmentedControl!
	@IBOutlet weak var selectVideoButton: UIButton! {
		didSet {
			selectVideoButton.layer.cornerRadius = 10
		}
	}
	@IBOutlet weak var goButton: UIButton! {
		didSet {
			if (!ProcessInfo.processInfo.arguments.contains("testing")) {
				goButton.alpha = 0.5
				goButton.isEnabled = false
			} else {
				goButton.alpha = 1.0
				goButton.isEnabled = true
			}
			goButton.layer.cornerRadius = 10
		}
	}

	// MARK: Override Functions
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if (ProcessInfo.processInfo.arguments.contains("testing")) {
			videoURL = Bundle.main.url(forResource: "demo", withExtension: "MOV")
			fpsSelector.selectedSegmentIndex = 0
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "analyzeVideo" {
			let destVC = segue.destination as! AnalyzeViewController
			destVC.videoPath = videoURL
			destVC.fps = getFPSforIndex(index: fpsSelector.selectedSegmentIndex)
		}
	}
	
	// MARK: IBActions
	
	@IBAction func selectVideo(sender: Any) {
		let gallery = GalleryController()
		gallery.delegate = self
		
		Config.Camera.recordLocation = true
		Config.VideoEditor.maximumDuration = 60
		Config.tabsToShow = [.videoTab]
		
		if #available(iOS 13.0, *) {
			spinner = UIActivityIndicatorView(style: .large)
		} else {
			spinner = UIActivityIndicatorView(style: .gray)
		}
		spinner.center = view.center
		view.addSubview(spinner)
		spinner.startAnimating()
		
		present(gallery, animated: true, completion: nil)
	}
	
	@IBAction func fpsCheck(sender: Any) {
		let alertController = UIAlertController(title: "FPS Explained", message: "To determine what FPS (frames per second) you are filming at, please go to Settings > Camera. Here you will find your settings and what FPS you are filming at. Please note that Video and Slo-mo record at different frame rates!", preferredStyle: .alert)
		let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
		alertController.addAction(action)
		self.present(alertController, animated: true, completion: nil)
	}
	
	@IBAction func start(sender: Any) {
		goButton.alpha = 0.5
		goButton.isEnabled = false
		self.performSegue(withIdentifier: "analyzeVideo", sender: self)
	}
	
	// MARK: Gallery Methods
	
	func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
	  controller.dismiss(animated: true, completion: nil)

	  let editor = VideoEditor()
	  editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
		DispatchQueue.main.async {
		  if let tempPath = tempPath {
			self.videoURL = tempPath
			self.goButton.alpha = 1.0
			self.goButton.isEnabled = true
			self.spinner.removeFromSuperview()
		  }
		}
	  }
	}
	
	func galleryControllerDidCancel(_ controller: GalleryController) {
		self.spinner.removeFromSuperview()
		controller.dismiss(animated: true, completion: nil)
	}
	
	func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {}
	
	func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {}
	
	func getFPSforIndex(index: Int) -> Int {
		switch (index) {
		case 0:
			return 240
		case 1:
			return 120
		case 2:
			return 60
		case 3:
			return 30
		default:
			return 24
		}
	}
	
}

