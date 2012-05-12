//
//  GPSTrackerViewController.m
//  GPSTracker
//
//  Created by Nic Jackson on 09/06/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "GPSTrackerViewController.h"
#import "GPSTrackerAppDelegate.h"
#import "LocationDataObject.h"
#import "LocationImage.h"
#import "LogViewController.h"
#import "PersistantStore.h"
#import "SettingsViewController.h"
#import "MapViewController.h"
#import "NSDataAdditions.h"
#import "DataUploader.h"

@implementation GPSTrackerViewController

@synthesize startButton,uidLabel,emailButton,latLabel,lonLabel,dataSendLabel,dataPointLabel,accLabel;
@synthesize distLabel,dataSentLabel,locationHelper,uploadButton,uploadLabel,emailLabel,isTracking;
@synthesize positionRetrievedLabel;

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    [super viewDidLoad];
	
	UIDevice* device = [UIDevice currentDevice];
	backgroundSupported = NO;
	if ([device respondsToSelector:@selector(isMultitaskingSupported)])
		backgroundSupported = device.multitaskingSupported;
	
	locationHelper = [[LocationHelper alloc] init];
	locationHelper.delegate = self;
	
	
	app = (GPSTrackerAppDelegate*)[UIApplication sharedApplication].delegate;
	
	locationHelper.app = app.app;
	
	dataStore = app.dataStore;
	
	awaitingImageLocation = NO;
    
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    
    numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setPositiveFormat:@"###0.##"];
    [numberFormatter setNegativeFormat:@"-###0.##"];
    
	[self checkUpload];
	[self checkEmail];
	
}

- (void) checkUpload {

	if([dataStore.locationArray count] > 0 || [dataStore.imageLocationArray count] > 0) {
	
		uploadLabel.hidden = NO;
		uploadButton.hidden = NO;
		
	} else {
	
		uploadLabel.hidden = YES;
		uploadButton.hidden = YES;
		
	}
	
}

- (void) checkEmail {

	if([dataStore.GUID length] > 0) {
		
		emailLabel.hidden = NO;
		emailButton.hidden = NO;
		
	} else {
		
		emailLabel.hidden = YES;
		emailButton.hidden = YES;
		
	}
	
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void) setViewData {
	
	if(locationHelper.currentLocation != nil) {
	
		NSLog(@"setViewData");
		
		// get the last item
		LocationDataObject *location = locationHelper.currentLocation;
				
		// update the view
		latLabel.text = [NSString stringWithFormat:@"%f",location.LocationObject.coordinate.latitude];
		lonLabel.text = [NSString stringWithFormat:@"%f",location.LocationObject.coordinate.longitude];
        
        NSNumber * accuracy = [NSNumber numberWithFloat:location.LocationObject.horizontalAccuracy];
        
        
		accLabel.text = [NSString stringWithFormat:@"%@m",[numberFormatter stringFromNumber:accuracy]];
		dataPointLabel.text = [NSString stringWithFormat:@"%d",locationHelper.numberEvents];
		//dataSentLabel.text = [NSString stringWithFormat:@"Total Data Sent: %d",totalDataSent];
		
        
        
		if(locationHelper.DistanceTraveled < 1000) {
            NSNumber * distance = [NSNumber numberWithInt:locationHelper.DistanceTraveled];
			distLabel.text = [NSString stringWithFormat:@"%@m",[numberFormatter stringFromNumber:distance]];
		} else {
            NSNumber * distance = [NSNumber numberWithFloat:(locationHelper.DistanceTraveled / 1000)];
			distLabel.text = [NSString stringWithFormat:@"%@km",[numberFormatter stringFromNumber:distance]];
		}
		
		if(lastSendTime != nil)
			dataSendLabel.text = [dateFormat stringFromDate:lastSendTime];
		
		if(lastPostionTime != nil)
			positionRetrievedLabel.text = [dateFormat stringFromDate:lastPostionTime];
		
		[self checkUpload];
		[self checkEmail];
		
	}
	
}

- (NSString *)GetUUID {

	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	
	NSString *guid = [NSString stringWithString:(NSString*)string]; // create an NSString which will autorelease
	
	CFRelease(string); // release the CF string
	
	return (NSString *)guid;
	
}

- (BOOL) startTracking {
	
	
	// redirect the output to a file
	//NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	//NSString *logPath = [basePath stringByAppendingPathComponent:@"output.log"];
	//freopen([logPath fileSystemRepresentation], "w", stderr);
	
	totalDataSent = 0;
		
	//locationHelper.monitorSignificantChanges = dataStore.useSignificant;
	locationHelper.RefreshInterval = -1;
	
	BOOL CheckUsername = NO;
	if(dataStore.username == nil) {
		CheckUsername = YES;
	}else {
		if([dataStore.username length] < 4) {
			CheckUsername = YES;
		}
	}
	
	BOOL CheckGUID = YES;
	if(dataStore.GUID == nil) {
		CheckGUID = NO;
	}else {
		if([dataStore.GUID length] < 4) {
			CheckGUID = NO;
		}
	}
				
	if(CheckUsername && !dontBugUsername) {
		
		// check to see that we have a username configured
		UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@"Alert" message:@"You have not configured your username, would you like to do this now?" 
								  delegate:self 
								  cancelButtonTitle:@"Continue" 
								  otherButtonTitles:@"Configure",nil];
		[alert show];

		dontBugUsername = YES;
			
	} else if(CheckGUID && !dontBugSession) {
		
		// check to see if we have a previous session if so then ask the user
		// and restore it
		
		NSLog(@"guid: %@",dataStore.GUID);
			
		UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@"Alert" message:@"You have a previous tracking session, would you like to continue?" 
								  delegate:self 
								  cancelButtonTitle:@"New Session" 
								  otherButtonTitles:@"Continue",nil];
		[alert show];
		
		dontBugSession = YES;
		
	} else {
		
		if(startNewSession) {
            
            startNewSession= NO;
            
            // reset the location service
            [locationHelper stopLocationService];
            
            // start a new session
			currentGUID = [self GetUUID];
			dataStore.GUID = currentGUID;
			locationHelper.DistanceTraveled = 0; // reset the location helper
			numberEvents = 0;
			locationHelper.numberEvents=0;
			
		} else {
			
			// restore the previous session
			currentGUID = dataStore.GUID;
			locationHelper.numberEvents = dataStore.numberEvents +1;
            
		}
        
        locationHelper.currentLocation = nil; // reset the location helper
        locationHelper.prevLocation = nil; // reset the location helper
		
		//[uidLabel setText:[NSString stringWithFormat:@"Unique ID: %@",currentGUID]];
        
        NSLog(@"startTracking startLocationUpdates");
        [locationHelper startLocationService];
		[locationHelper startGPSWithDelay:0];
		
		// clear the annotation view on the map
		[app.mapView clearLocations];
	
		//[app.logView updateLog:@" Start Tracking"];
		dontBugSession = NO;
		dontBugUsername = NO;
				
		// start tracking location
		isTracking = YES;
        
        NSString * bundleFolder = [[NSBundle mainBundle] resourcePath];
        UIImage *normalImage = [UIImage imageWithContentsOfFile:[bundleFolder stringByAppendingPathComponent:@"button-red.png"]];
        UIImage *highlightImage = [UIImage imageWithContentsOfFile:[bundleFolder stringByAppendingPathComponent:@"button-red-highlight.png"]];
        
		[startButton setTitle: @" Stop Tracking" forState:UIControlStateNormal];
        [startButton setBackgroundImage:normalImage forState:UIControlStateNormal];
        [startButton setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
        
        [self setViewData];
        
		return YES;
	}
	
	return NO;
		
}

- (void) stopTracking {
		
	[uidLabel setText:[NSString stringWithFormat:@"Unique ID:"]];
	isTracking = NO;
    
    [locationHelper stopLocationUpdates];
	[locationHelper stopLocationService]; // stop the location service
	//[app.logView updateLog:@" Stop Tracking"];
		
	// flush any data to the server run as background task
	[self uploadClick:nil];
	
    NSString * bundleFolder = [[NSBundle mainBundle] resourcePath];
    UIImage *normalImage = [UIImage imageWithContentsOfFile:[bundleFolder stringByAppendingPathComponent:@"button-green.png"]];
    UIImage *highlightImage = [UIImage imageWithContentsOfFile:[bundleFolder stringByAppendingPathComponent:@"button-green-highlight.png"]];
    
    [startButton setTitle: @" Start Tracking" forState:UIControlStateNormal];
    [startButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [startButton setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
	
}



- (void) applicationRunningInBackground:(BOOL) background {	
	
	runnningInBackground = background;
	/*
	if(background) {
		NSLog(@"Switching to Background");
		// we need to tell the GPS to go into super low power mode if we are not already
		if(!locationSwitch.on)
			[locationHelper enableSignificantChanges:YES];
		
	} else {
		NSLog(@"Resume from Background");
		// resuming from background running
		if(!locationSwitch.on)
			[locationHelper enableSignificantChanges:NO];
		
	}
	 */
	
}

- (void) newPictureTaken: (NSString*) filePath {
	
    NSLog(@"New Picture %@", filePath); 
    
	// we have a new image so lets add it to the temporary locaiton and get its location
	LocationImage * newImage = [[LocationImage alloc] init];
	newImage.imagePath = filePath;

	if(locationPictures == nil)
		locationPictures = [[NSMutableArray alloc] init];
	
	[locationPictures addObject:[newImage retain]];
	
	awaitingImageLocation = YES;
	
	// start the location manager
	if(!locationHelper.GPSActive) {
        NSLog(@"newPictureTaken startLocationUpdates");
		[locationHelper startGPSWithDelay:0];
	 }
	
}

#pragma mark -
#pragma mark Button Actions
- (IBAction)emailClick:(id)sender {

	if([dataStore.GUID length] <1)
		return;
	
	MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
	controller.mailComposeDelegate = self;
	[controller setSubject:@"GPS Tracker Location Update"];
	[controller setMessageBody:[NSString stringWithFormat:@"Hello there!\n\n You can follow my location by visiting ...\n\n http://adventuretracker.net/ViewTrack.html?GUID=%@\n",dataStore.GUID,nil] isHTML:NO]; 
	[self presentModalViewController:controller animated:YES];
	[controller release];
	
}

- (IBAction)startClick:(id)sender {
	
	
	if(!isTracking) {
		
		[self startTracking];
		
	} else {
		
		[self stopTracking];
		
	}
	
}

- (IBAction)uploadClick:(id)sender {
	
	[self DoUpload: YES];
	
	
}

- (void) DoUpload:(BOOL) uploadImages {

	if([DataUploader sharedInstance].uploading)
		return;
	
	self.uploadButton.hidden = YES;
	self.uploadLabel.hidden = YES;
	
	[DataUploader sharedInstance].manualUpload = uploadImages;
	
	// wire up a delegate
	[DataUploader sharedInstance].delegate = self;
	[[DataUploader sharedInstance] PostDataToServer];
	
}


#pragma mark -
#pragma mark alertViewDelegate
- (void)alertView:(UIAlertView*) alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

	if([alertView buttonTitleAtIndex:1] == @"Configure") {
	
		// configure dialog
		if(buttonIndex == 1) {
		
			// change the view to settings
			app.tabBarController.selectedIndex = 3;
			
		} else {
			// restart
			[self startTracking];
		}
		
		
	} else {
	
		// start session dialog
		startNewSession = (buttonIndex == 0);
		
		// restart
		[self startTracking];
		
	}
	
	[alertView release];

}

#pragma mark -
#pragma mark LocationHelperDelegate methods
- (void)foundLocation: (LocationDataObject*) currentLocation: (LocationDataObject*) previousLocation: (NSArray*) SignificantChangeLocations; {
	
	// we have a new location so update if need be
	NSLog(@"new Location");
	//[app.logView updateLog:@"New Location"]; // update the log window
	
	if(previousLocation.LocationObject.coordinate.latitude != currentLocation.LocationObject.coordinate.latitude 
       && previousLocation.LocationObject.coordinate.longitude != currentLocation.LocationObject.coordinate.longitude) {
		
		// update the location array with the GUID
		currentLocation.GUID = currentGUID;
			
		// update the order
		dataStore.numberEvents = currentLocation.LocationPosition;
	
		// update our temporary cache with the new data
		[dataStore addDataToLocationArray:currentLocation];
        
        // do we have any significant change objects to add to the array?
        if(SignificantChangeLocations != NULL && [SignificantChangeLocations count] > 0) {
            
            for(int n=0; n < [SignificantChangeLocations count]; n++) {
                ((LocationDataObject*)[SignificantChangeLocations objectAtIndex:n]).GUID = currentGUID;
                [dataStore addDataToLocationArray: [SignificantChangeLocations objectAtIndex:n]];
                NSLog(@"Adding Significant Location Changed");
            }
            
        }
		
		// update the map window
		[app.mapView setCurrentLocation: currentLocation];
		
		lastPostionTime = [[NSDate date] retain]; // get the current date
		
	}else {
		NSLog(@"previous location same as current");
	}
	
	// do we have a cached images awaiting a location?
	if(awaitingImageLocation) {
		
		// update the images in the temp array then add them to the dataStore
		for(int n=0; n < [locationPictures count]; n++) {
		
			((LocationImage*)[locationPictures objectAtIndex:n]).LocationObject = [currentLocation retain];
			
		}
		
		// now update the data store
		[dataStore addDataToPicturesArray:locationPictures];
		[locationPictures removeAllObjects];
		
		awaitingImageLocation = NO;
	}
	
	
	//save the cache
	[dataStore saveData];
	[self setViewData];
    
	// update the server - in background
	[self DoUpload: NO];
	
}

- (void)newMessage:(NSString*)message {

	// new message recieved send it to the log
	//[app.logView updateLog:message];
	
}


#pragma mark -
#pragma mark mailComposeDelegate methods
- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
	if (result == MFMailComposeResultSent) {
		NSLog(@"It's away!");
	}
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark dataUploaderDelegate
- (void)uploadComplete:(kUploadStatus)status {

	if(lastSendTime != nil)
		[lastSendTime release];
	
	lastSendTime = [[NSDate alloc] init];
	
	[self setViewData];
	
	if(status == kuploadStatus_FAILED)
		[self checkUpload];
	
}

- (void)dealloc {
	
    [startButton release];
	[emailButton release];
	
    [super dealloc];
}

@end
