//
//  LogViewController.h
//  GPSTracker
//
//  Created by Nic Jackson on 17/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LogViewController : UIViewController {

	UITextView * textView;
	BOOL loaded;
	NSString *tempText;
	
	BOOL runnningInBackground;
	
	UISwitch * loggingSwitch;
	
}

@property (nonatomic,retain) IBOutlet UITextView * textView;
@property (nonatomic,retain) IBOutlet UISwitch * loggingSwitch;

- (void) updateLog:(NSString*)data;
- (void) clearLog;
- (void) applicationRunningInBackground:(BOOL) background; // called by the main view to notify that the application is now running in the background

@end
