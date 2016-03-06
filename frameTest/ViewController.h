//
//  ViewController.h
//  frameTest
//
//  Created by Ryan Cobelli on 8/5/15.
//  Copyright (c) 2015 Rybel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <CoreMedia/CoreMedia.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "CWStatusBarNotification.h"

double timeStamp;
double highSpeedTimeStamp;
UIImageView *viewingFrame;
NSURL *url;
CWStatusBarNotification *statusBar;
UITextField *frameValueField;
bool justShowedAd = false;

@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) MPMoviePlayerController *player;

@end