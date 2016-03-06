//
//  SettingsViewController.h
//  frameTest
//
//  Created by Ryan Cobelli on 12/19/15.
//  Copyright © 2015 Rybel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import <Appodeal/Appodeal.h>

@interface SettingsViewController : UIViewController <UITextFieldDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *interval;
@property (weak, nonatomic) IBOutlet UITextField *multiplier;
@property (weak, nonatomic) IBOutlet UIButton *removeAdsOutlet;



@end
