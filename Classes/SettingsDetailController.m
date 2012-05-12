//
//  SettingsDetailController.m
//  GPSTracker
//
//  Created by Nic Jackson on 12/07/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingsDetailController.h"
#import "GPSTrackerAppDelegate.h"
#import "PersistantStore.h"

@implementation SettingsDetailController

@synthesize refreshLabel, titleLocationLabel,titleLocationLabel2, titleRefreshLabel, titleUsernameLabel1, titleUsernameLabel2, titleUsernameLabel3;
@synthesize locationSwitch,refreshSlider,delegate,toolbar,userName,editingMode,titleUploadLabel,titleUploadLabel2,titleQuickViewLabel,titleQuickViewLabel2;

UITextField *userName;

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad {

	app = (GPSTrackerAppDelegate*)[UIApplication sharedApplication].delegate;
	
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];

	refreshLabel.hidden = YES;
	
	titleLocationLabel.hidden = YES;
	titleLocationLabel2.hidden = YES;
	titleRefreshLabel.hidden = YES;
	
	titleUsernameLabel1.hidden = YES;
	titleUsernameLabel2.hidden = YES;
	titleUsernameLabel3.hidden = YES;
	
	locationSwitch.hidden = YES;
	refreshSlider.hidden = YES;
	
	titleUploadLabel.hidden = YES;
	titleUploadLabel2.hidden = YES;
	
	titleQuickViewLabel.hidden = YES;
	titleQuickViewLabel2.hidden = YES;
	
	userName.hidden = YES;
	
	switch(editingMode) {
	
		case kDetailViewEditingMode_REFRESHINTERVAL:
			refreshLabel.hidden = NO;
			titleRefreshLabel.hidden = NO;
			refreshSlider.hidden = NO;
			self.refreshSlider.value = app.dataStore.refreshInterval;
			break;
			
		case kDetailViewEditingMode_USERNAME:
			titleUsernameLabel1.hidden = NO;
			titleUsernameLabel2.hidden = NO;
			titleUsernameLabel3.hidden = NO;
			userName.hidden = NO;
			self.userName.text = app.dataStore.username;
			break;
		
		case kDetailViewEditingMode_SIGNIFICANTLOCATION:
			locationSwitch.hidden = NO;
			titleLocationLabel.hidden = NO;
			titleLocationLabel2.hidden = NO;
			self.locationSwitch.on = app.dataStore.useSignificant;
			break;
			
		case kDetailViewEditingMode_UPLOADWIFI:
			locationSwitch.hidden = NO;
			titleUploadLabel.hidden = NO;
			titleUploadLabel2.hidden = NO;
			self.locationSwitch.on = app.dataStore.autoUploadImagesWIFI;
			break;
			
		case kDetailViewEditingMode_QUICKFOLLOW:
			locationSwitch.hidden = NO;
			titleQuickViewLabel.hidden = NO;
			titleQuickViewLabel2.hidden = NO;
			self.locationSwitch.on = app.dataStore.useQuickFollow;
			break;
	}
	
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(IBAction)sliderChanged:(id)sender; {
	
	self.refreshLabel.text = [NSString stringWithFormat:@"%d minutes",(int)self.refreshSlider.value];
	
}

- (IBAction)cancel:(id)sender {
	
	[delegate settingsDetailController:self didFinishWithSave:NO];
	
}

- (IBAction)save:(id)sender {

	switch(editingMode) {
			
		case kDetailViewEditingMode_REFRESHINTERVAL:
			app.dataStore.refreshInterval = (int)self.refreshSlider.value;
			break;
		
		case kDetailViewEditingMode_USERNAME:
			app.dataStore.username = self.userName.text;
			break;
			
		case kDetailViewEditingMode_SIGNIFICANTLOCATION:
			app.dataStore.useSignificant = self.locationSwitch.on;
			break;
			
		
		case kDetailViewEditingMode_UPLOADWIFI:
			app.dataStore.autoUploadImagesWIFI = self.locationSwitch.on;
			break;
			
		case kDetailViewEditingMode_QUICKFOLLOW:
			app.dataStore.useQuickFollow = self.locationSwitch.on;
			break;
			
	}
	
	[app.dataStore saveData];
	[delegate settingsDetailController:self didFinishWithSave:YES];
			
}

- (void)dealloc {
	
	[refreshLabel release];
	
	[titleLocationLabel release];
	[titleRefreshLabel release];
	
	[titleUsernameLabel1 release];
	[titleUsernameLabel2 release];
	[titleUsernameLabel3 release];
	
	[titleLocationLabel2 release];
	
	[titleUploadLabel release];
	[titleUploadLabel2 release];
	
	[titleQuickViewLabel release];
	[titleQuickViewLabel2 release];
	
	[locationSwitch release];
	
	[userName release];
    [super dealloc];
}


@end
