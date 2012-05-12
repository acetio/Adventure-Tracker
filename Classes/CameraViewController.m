//
//  CameraViewController.m
//  GPSTracker
//
//  Created by Nic Jackson on 12/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CameraViewController.h"
#import "GPSTrackerAppDelegate.h"


@implementation CameraViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void)viewDidAppear:(BOOL)animated {
	
	GPSTrackerAppDelegate * app = (GPSTrackerAppDelegate*)[UIApplication sharedApplication].delegate;
	
	if(![app currentlyTracking]) {
		// check if we are currently tracking?
		NSString *alertMessage = [NSString stringWithFormat:@"You are not currently tracking start a tracking session before taking pictures"];
		NSString *ok = [NSString stringWithFormat:@"Ok"];               
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to take picture" message:alertMessage  delegate:self cancelButtonTitle:ok otherButtonTitles:nil];
		
		[alert show];
		[alert release];
		
		return;
		
	}
	
	UIImagePickerController * imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.allowsImageEditing = NO;
    imgPicker.delegate = app;
	
    imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	
    [self presentModalViewController:imgPicker animated:YES];
	
	[imgPicker release];
	
}

- (void)alertView:(UIAlertView *)alertView didDisMissWithButtonIndex:(NSInteger)buttonIndex{
	GPSTrackerAppDelegate * app = (GPSTrackerAppDelegate*)[UIApplication sharedApplication].delegate;
    app.tabBarController.selectedIndex = 0;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
    [super dealloc];
}


@end
