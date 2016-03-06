//
//  ViewController.m
//  frameTest
//
//  Created by Ryan Cobelli on 8/5/15.
//  Copyright (c) 2015 Rybel. All rights reserved.
//

#import "ViewController.h"
#import "OnboardingViewController.h"
#import <Appodeal/Appodeal.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MPMoviePlayerPlaybackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
    timeStamp = 0;
    highSpeedTimeStamp = 0;
    
    viewingFrame = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:viewingFrame];
	[viewingFrame setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[self.view setAutoresizesSubviews:true];
    [self.view sendSubviewToBack:viewingFrame];
    
    
    statusBar = [CWStatusBarNotification new];
    statusBar.notificationLabelTextColor = [UIColor colorWithRed:255.0 green:210.0 blue:46.0 alpha:1.0];
    statusBar.notificationLabelBackgroundColor = [UIColor colorWithRed:0.133f green:0.133f blue:0.133f alpha:1.00f];;
    statusBar.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    statusBar.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
    
    statusBar.notificationTappedBlock = ^(void) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Rate Us On The App Store", @"")
                                                        message: NSLocalizedString(@"Would you like to leave a rating on the app store?", @"")
                                                       delegate:self
                                              cancelButtonTitle: NSLocalizedString(@"Yes", @"")
                                              otherButtonTitles: NSLocalizedString(@"No", @""), nil];
        alert.tag = 1;
        [alert show];
        [statusBar dismissNotification];
    };

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
	
	if ([[[NSProcessInfo processInfo] arguments] containsObject:@"testing"]) {

		UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"example.jpg"]];
		backgroundImage.frame = self.view.frame;
    
		[self.view addSubview:backgroundImage];
		[self.view sendSubviewToBack:backgroundImage];
    
    
		_timeLabel.text = [NSString stringWithFormat:@"1.23 s."];
	}
}

- (void)didChangeOrientation:(NSNotification *)notification
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [_player.view setFrame: CGRectMake(10, 10, self.view.frame.size.width-20, self.view.frame.size.height-20)];
    }
    else {
        [_player.view setFrame: CGRectMake(10, 10, self.view.frame.size.height-20, self.view.frame.size.width-20)];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1 && buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"https://itunes.apple.com/us/app/id1023278352"]];
    }
}

-(void)viewDidAppear:(BOOL)animated {
	
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"frameRateType"];
		[[NSUserDefaults standardUserDefaults] setDouble:0.02 forKey:@"interval"];
		[[NSUserDefaults standardUserDefaults] setDouble:4.0 forKey:@"multiplier"];
		[[NSUserDefaults standardUserDefaults] setBool:true forKey:@"firstLaunch"];
		justShowedAd = !justShowedAd;
		
		
		
		if (![[[NSProcessInfo processInfo] arguments] containsObject:@"testing"]) {
			
			OnboardingContentViewController *firstPage = [OnboardingContentViewController contentWithTitle: NSLocalizedString(@"Welcome To Frame Timer!", "") body: NSLocalizedString(@"Slide to get started", "") image:nil buttonText:nil action:nil];
													  
			OnboardingContentViewController *secondPage = [OnboardingContentViewController contentWithTitle: NSLocalizedString(@"Step 1:", "") body: NSLocalizedString(@"Record video in the camera app (slowmotion and normal video accepted)", "") image:nil buttonText:nil action:nil];
		
			OnboardingContentViewController *thirdPage = [OnboardingContentViewController contentWithTitle: NSLocalizedString(@"Step 2:", "") body: NSLocalizedString(@"Select video from camera roll and analyze!", "") image:nil buttonText: NSLocalizedString(@"Get Started!", "") action:^{
				[self dismissViewControllerAnimated:true completion:nil];
			}];
		
			OnboardingViewController *onboardingVC = [OnboardingViewController onboardWithBackgroundImage:[UIImage imageNamed:@"example.jpg"] contents:@[firstPage, secondPage, thirdPage]];
	
			onboardingVC.shouldFadeTransitions = YES;
			onboardingVC.fadePageControlOnLastPage = YES;
			onboardingVC.fadeSkipButtonOnLastPage = true;

			onboardingVC.allowSkipping = YES;
			onboardingVC.skipHandler = ^{
				[self dismissViewControllerAnimated:true completion:nil];
			};
		
			[self presentViewController:onboardingVC animated:true completion:nil];

		}

	}
	else {
		if (!justShowedAd && ![[[NSProcessInfo processInfo] arguments] containsObject:@"testing"] && [Appodeal isReadyForShowWithStyle:AppodealShowStyleInterstitial] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"removedAds"]) {
			[Appodeal showAd:AppodealShowStyleInterstitial rootViewController:self];
			justShowedAd = true;
		}
		else {
			NSLog(@"Ready to show ad: %@", [Appodeal isReadyForShowWithStyle:AppodealShowStyleInterstitial] ? @"true" : @"false");
			justShowedAd = false;
		}
		
		
		
		NSString *key = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
		if ([[NSUserDefaults standardUserDefaults] integerForKey:key] == 5 && ![[[NSProcessInfo processInfo] arguments] containsObject:@"testing"]) {
			[statusBar displayNotificationWithMessage: NSLocalizedString(@"Pssst! Want a piece of candy?", @"") completion:nil];
			[[NSUserDefaults standardUserDefaults] setInteger:6 forKey:key];
		}
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        NSString *moviePath = [videoUrl path];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum (moviePath, nil, nil, nil);
        }
        
        url = [NSURL fileURLWithPath:moviePath];
    }
    
	[self dismissViewControllerAnimated:true completion:^{
		if (url != nil) {
			[self setUpMediaFile];
			timeStamp = 0.0;
			highSpeedTimeStamp = 0.0;
			[self next:nil];
		}
		
		if (![[[NSProcessInfo processInfo] arguments] containsObject:@"testing"] && [Appodeal isReadyForShowWithStyle:AppodealShowStyleSkippableVideo] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"removedAds"]) {
			[Appodeal showAd:AppodealShowStyleSkippableVideo rootViewController:self];
		}
		else {
			NSLog(@"Ready to show ad: %@", [Appodeal isReadyForShowWithStyle:AppodealShowStyleSkippableVideo] ? @"true" : @"false");
		}
//		justShowedAd = !justShowedAd;
	}];
}

-(void)imagePickerControllerDidCancel:(nonnull UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:true completion:nil];
    [self.navigationController popToRootViewControllerAnimated:false];
}

-(void)setUpMediaFile {
    _player = [[MPMoviePlayerController alloc] initWithContentURL:url];
    [self didChangeOrientation:nil];
    [self.view addSubview: _player.view];
    [_player stop];
    [_player.view removeFromSuperview];
    [self getFirstFrameFromVideoFile];
}

- (void)MPMoviePlayerPlaybackStateDidChange:(NSNotification *)notification
{
    if (_player.playbackState == MPMoviePlaybackStatePlaying)
    {
       [self getFirstFrameFromVideoFile];
    }
    if (_player.playbackState == MPMoviePlaybackStateStopped)
    { //stopped
    }if (_player.playbackState == MPMoviePlaybackStatePaused)
    { //paused
    }if (_player.playbackState == MPMoviePlaybackStateInterrupted)
    { //interrupted
    }if (_player.playbackState == MPMoviePlaybackStateSeekingForward)
    { //seeking forward
    }if (_player.playbackState == MPMoviePlaybackStateSeekingBackward)
    { //seeking backward
    }
    
}

- (IBAction)last:(UIButton*)sender {
	if (url != nil) {
		timeStamp = timeStamp - ([[NSUserDefaults standardUserDefaults] doubleForKey:@"interval"] * sender.tag);
		highSpeedTimeStamp = highSpeedTimeStamp - ([[NSUserDefaults standardUserDefaults] doubleForKey:@"interval"] * [[NSUserDefaults standardUserDefaults] doubleForKey:@"multiplier"] * sender.tag);
		[self getFirstFrameFromVideoFile];
	}
}
- (IBAction)next:(UIButton*)sender {
	if (url != nil) {
		timeStamp = timeStamp + ([[NSUserDefaults standardUserDefaults] doubleForKey:@"interval"] * sender.tag);
		highSpeedTimeStamp = highSpeedTimeStamp + ([[NSUserDefaults standardUserDefaults] doubleForKey:@"interval"] * [[NSUserDefaults standardUserDefaults] doubleForKey:@"multiplier"] * sender.tag);
		[self getFirstFrameFromVideoFile];
	}
}

-(void)getFirstFrameFromVideoFile {
    viewingFrame.image = [_player thumbnailImageAtTime:highSpeedTimeStamp timeOption:MPMovieTimeOptionExact];
    [_player pause];
    _timeLabel.text = [NSString stringWithFormat:@"%0.2f s.", timeStamp];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)choose:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,      nil];
    imagePicker.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:imagePicker animated:true completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
