//
//  GPSTrackerAppDelegate.h
//  GPSTracker
//
//  Created by Nic Jackson on 09/06/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraViewController.h"
#import "ABNotifier.h"

@class GPSTrackerViewController,LogViewController,MMPDeepSleepPreventer,MapViewController,SettingsViewController,PJSIPObject,PersistantStore;

@interface GPSTrackerAppDelegate : NSObject <UIApplicationDelegate,ABNotifierDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	
	BOOL runningInBackground;
    	
	GPSTrackerViewController * trackerView;
	//LogViewController * logView;
	CameraViewController * cameraView;
	MapViewController * mapView;
	SettingsViewController *settingsView;
	
	MMPDeepSleepPreventer *deepSleepPreventer;
	
	UIApplication * app;

	PJSIPObject *pjsip;
	
	int CurrentInterval;
	
	PersistantStore * dataStore;
	
	UIBackgroundTaskIdentifier bgTask;
	
	int testN;
	NSTimer * timer;
}

- (BOOL) currentlyTracking;
- (UIImage *) scaleAndRotateImage:(UIImage *)image;

@property (nonatomic,retain) PersistantStore * dataStore;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) GPSTrackerViewController * trackerView;
@property (nonatomic, retain) CameraViewController * cameraView;
@property (nonatomic, retain) MapViewController * mapView;
@property (nonatomic, retain) SettingsViewController *settingsView;
@property (nonatomic, retain) MMPDeepSleepPreventer *deepSleepPreventer;

@property (nonatomic, retain) UIApplication * app;

@property (nonatomic) BOOL runningInBackground;

@end

