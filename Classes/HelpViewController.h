//
//  HelpViewController.h
//  GPSTracker
//
//  Created by Nic Jackson on 05/07/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HelpViewController : UIViewController {

	UIWebView * webView;
	
}

@property (nonatomic,retain) IBOutlet UIWebView * webView;

@end
