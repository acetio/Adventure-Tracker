//
//  LogViewController.m
//  GPSTracker
//
//  Created by Nic Jackson on 17/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LogViewController.h"

@implementation LogViewController

@synthesize textView,loggingSwitch;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    [super viewDidLoad];
		
	loaded = YES;
	
	if(tempText != nil) {
		textView.text = tempText;
		tempText = nil;
	}
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void) updateLog:(NSString*)data {
	
	if(!loggingSwitch.on)
		return;
	
	if(!loaded || runnningInBackground) {
		if(tempText == nil)
			tempText = [[NSString alloc] initWithFormat:@"%@: %@",[[NSDate date] descriptionWithLocale:nil],data];
		else
			tempText = [[NSString alloc] initWithFormat:@"%@\n%@: %@",tempText,[[NSDate date] descriptionWithLocale:nil],data];

	} else {
	
		textView.text = [NSString stringWithFormat:@"%@\n%@: %@",textView.text,[[NSDate date] descriptionWithLocale:nil],data];
		
	}
	
}
- (void) clearLog {

	textView.text = @"";
	
}

- (void) applicationRunningInBackground:(BOOL) background {	

	runnningInBackground = background;
	
	if(!background) {
	
		// check if we have any text to update
		if(tempText != nil) {
			textView.text = [NSString stringWithFormat:@"%@\n%@",textView.text,tempText];
			tempText = nil;
		}
		
	}
	
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[textView release];
    [super dealloc];
}


@end
