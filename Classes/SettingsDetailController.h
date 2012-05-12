//
//  SettingsDetailController.h
//  GPSTracker
//
//  Created by Nic Jackson on 12/07/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum detailViewEditingMode {
    kDetailViewEditingMode_REFRESHINTERVAL = 0,
 	kDetailViewEditingMode_USERNAME = 1,
	kDetailViewEditingMode_SIGNIFICANTLOCATION =2,
	kDetailViewEditingMode_UPLOADWIFI =3,
	kDetailViewEditingMode_QUICKFOLLOW=4
} kDetailViewEditingMode;

@protocol SettingsDetailControllerDelegate;

@class GPSTrackerAppDelegate;

@interface SettingsDetailController : UIViewController {

	id <SettingsDetailControllerDelegate> delegate;
	
	UILabel *refreshLabel;
	
	UILabel *titleLocationLabel;
	UILabel *titleLocationLabel2;
	UILabel *titleRefreshLabel;
	
	UILabel *titleUploadLabel;
	UILabel *titleUploadLabel2;
	
	UILabel *titleQuickViewLabel;
	UILabel *titleQuickViewLabel2;
	
	UILabel *titleUsernameLabel1;
	UILabel *titleUsernameLabel2;
	UILabel *titleUsernameLabel3;
	
	UISwitch *locationSwitch;
	UISwitch *quickViewSwitch;
	UISlider *refreshSlider;
	
	UITextField *userName;
	
	UIToolbar *toolbar;
	
	GPSTrackerAppDelegate *app;
	
	kDetailViewEditingMode editingMode;

}

- (IBAction)sliderChanged:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@property (nonatomic,assign) kDetailViewEditingMode editingMode;

@property (nonatomic, assign) id <SettingsDetailControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet UILabel * refreshLabel;

@property (nonatomic,retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic, retain) IBOutlet UILabel * titleLocationLabel;
@property (nonatomic, retain) IBOutlet UILabel * titleLocationLabel2;
@property (nonatomic, retain) IBOutlet UILabel * titleRefreshLabel;
@property (nonatomic, retain) IBOutlet UILabel * titleUsernameLabel1;
@property (nonatomic, retain) IBOutlet UILabel * titleUsernameLabel2;
@property (nonatomic, retain) IBOutlet UILabel * titleUsernameLabel3;

@property (nonatomic, retain) IBOutlet UILabel * titleUploadLabel;
@property (nonatomic, retain) IBOutlet UILabel * titleUploadLabel2;

@property (nonatomic, retain) IBOutlet UILabel * titleQuickViewLabel;
@property (nonatomic, retain) IBOutlet UILabel * titleQuickViewLabel2;

@property (nonatomic,retain) IBOutlet UITextField *userName;
@property (nonatomic, retain) IBOutlet UISlider * refreshSlider;
@property (nonatomic, retain) IBOutlet UISwitch * locationSwitch;

@end

@protocol SettingsDetailControllerDelegate
- (void)settingsDetailController:(SettingsDetailController *)controller didFinishWithSave:(BOOL)save;
@end
