//
//  SettingsViewController.m
//  frameTest
//
//  Created by Ryan Cobelli on 12/19/15.
//  Copyright © 2015 Rybel. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"removedAds"]) {
		_removeAdsOutlet.hidden = true;
	}
	
	_segmentedControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"frameRateType"];
	if (_segmentedControl.selectedSegmentIndex == 2) {
		_interval.hidden = false;
		_interval.enabled = true;
		_multiplier.hidden = false;
		_multiplier.enabled = true;
	}
	else {
		_interval.hidden = true;
		_interval.enabled = false;
		_multiplier.hidden = true;
		_multiplier.enabled = false;
	}
}

-(void)viewDidAppear:(BOOL)animated {
	if (![[[NSProcessInfo processInfo] arguments] containsObject:@"testing"] && [Appodeal isReadyForShowWithStyle:AppodealShowStyleBannerCenter] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"removedAds"]) {
		[Appodeal showAd:AppodealShowStyleBannerCenter rootViewController:self];
	}
	else {
		NSLog(@"Ready to show ad: %@", [Appodeal isReadyForShowWithStyle:AppodealShowStyleBannerCenter] ? @"true" : @"false");
	}
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[self.view endEditing:true];
}

- (IBAction)segmentedControlValueChanged:(id)sender {
	if (_segmentedControl.selectedSegmentIndex == 2) {
		_interval.hidden = false;
		_interval.enabled = true;
		_multiplier.hidden = false;
		_multiplier.enabled = true;
	}
	else {
		_interval.hidden = true;
		_interval.enabled = false;
		_multiplier.hidden = true;
		_multiplier.enabled = false;
	}
}

- (IBAction)removeAds:(id)sender {
	if([SKPaymentQueue canMakePayments]) {
		SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"com.rybel_llc.frame_counter.remove_ads"]];
		productsRequest.delegate = self;
		[productsRequest start];
		
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Unable To Complete Request", @"")
														message: NSLocalizedString(@"Parental controls have disabled In App Purchases on this device", @"")
													   delegate:self
											  cancelButtonTitle: NSLocalizedString(@"Ok", @"")
											  otherButtonTitles:nil];
		[alert show];
	}
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
	SKProduct *validProduct = nil;
	int count = (int)[response.products count];
	if(count > 0){
		validProduct = [response.products objectAtIndex:0];
		NSLog(@"Products Available!");
		[self purchase:validProduct];
	}
	else if(!validProduct){
		NSLog(@"No products available");
		//this is called if your product id is not valid, this shouldn't be called unless that happens.
	}
}

- (IBAction)purchase:(SKProduct *)product{
	SKPayment *payment = [SKPayment paymentWithProduct:product];
	
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (IBAction) restore{
	//this is called when the user restores purchases, you should hook this up to a button
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
	NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
	for(SKPaymentTransaction *transaction in queue.transactions){
		if(transaction.transactionState == SKPaymentTransactionStateRestored){
			//called when the user successfully restores a purchase
			NSLog(@"Transaction state -> Restored");
			
			[[NSUserDefaults standardUserDefaults] setBool:true forKey:@"removedAds"];
			[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
			break;
		}
	}
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
	for(SKPaymentTransaction *transaction in transactions){
		switch(transaction.transactionState){
			case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
				//called when the user is in the process of purchasing, do not add any of your own code here.
				break;
			case SKPaymentTransactionStatePurchased:
				//this is called when the user has successfully purchased the package (Cha-Ching!)
				[[NSUserDefaults standardUserDefaults] setBool:true forKey:@"removedAds"];
				[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
				NSLog(@"Transaction state -> Purchased");
				break;
			case SKPaymentTransactionStateRestored:
				NSLog(@"Transaction state -> Restored");
				//add the same code as you did from SKPaymentTransactionStatePurchased here
				[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
				break;
			case SKPaymentTransactionStateFailed:
				//called when the transaction does not finish
				if(transaction.error.code == SKErrorPaymentCancelled){
					NSLog(@"Transaction state -> Cancelled");
					//the user cancelled the payment ;(
				}
				[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
				break;
			case SKPaymentTransactionStateDeferred:
				NSLog(@"Transaction state -> Deferred");
				[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
				break;
		}
	}
}

- (IBAction)save:(id)sender {
	[[NSUserDefaults standardUserDefaults] setInteger:_segmentedControl.selectedSegmentIndex forKey:@"frameRateType"];
	if (_segmentedControl.selectedSegmentIndex == 2) { // Custom
		[[NSUserDefaults standardUserDefaults] setDouble:[_interval.text doubleValue] forKey:@"interval"];
		[[NSUserDefaults standardUserDefaults] setDouble:[_multiplier.text doubleValue] forKey:@"multiplier"];
	}
	else if (_segmentedControl.selectedSegmentIndex == 1) { // 120
		[[NSUserDefaults standardUserDefaults] setDouble:0.02 forKey:@"interval"];
		[[NSUserDefaults standardUserDefaults] setDouble:4.0 forKey:@"multiplier"];
	}
	else { // 30
		[[NSUserDefaults standardUserDefaults] setDouble:0.25 forKey:@"interval"];
		[[NSUserDefaults standardUserDefaults] setDouble:1.0 forKey:@"multiplier"];
	}
	
	[self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)cancel:(id)sender {
	[self dismissViewControllerAnimated:true completion:nil];
}


@end
