//
//  SettingsViewController.h
//  GPSTracker
//
//  Created by Nic Jackson on 25/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsDetailController.h"

@class GPSTrackerAppDelegate;

@interface SettingsViewController : UIViewController <SettingsDetailControllerDelegate> {


	UITableView *table;
	GPSTrackerAppDelegate *app;
	
}

@property (nonatomic,retain) IBOutlet UITableView *table;

@end
