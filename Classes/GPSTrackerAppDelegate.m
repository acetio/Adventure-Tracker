//
//  GPSTrackerAppDelegate.m
//  GPSTracker
//
//  Created by Nic Jackson on 09/06/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "GPSTrackerAppDelegate.h"
#import "GPSTrackerViewController.h"
#import "LogViewController.h"
#import "MapViewController.h"
#import "SettingsViewController.h"
#import "PersistantStore.h"
#import "LocationHelper.h"

@implementation GPSTrackerAppDelegate

@synthesize window;
@synthesize tabBarController;

@synthesize runningInBackground,trackerView,deepSleepPreventer, mapView,settingsView,dataStore,app,cameraView;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    [ABNotifier startNotifierWithAPIKey:@"69c4a465948e6333ea12f60822b56b3a"
                        environmentName:ABNotifierAutomaticEnvironment
                                 useSSL:YES // only if your account supports it
                               delegate:self];
    
    // Override point for customization after application launch.
	self.app = application;
	
	runningInBackground = NO;
	CurrentInterval = 0;
	
	// set up the persistant store for settings
	self.dataStore = [[PersistantStore alloc]init];

    // Add the view controller's view to the window and display.
    [window addSubview:tabBarController.view];
	
	self.trackerView = (GPSTrackerViewController*)[tabBarController.viewControllers objectAtIndex:0];
	self.mapView = (MapViewController*)[tabBarController.viewControllers objectAtIndex:1];
	self.cameraView = (CameraViewController*)[tabBarController.viewControllers objectAtIndex:2];
	self.settingsView = (SettingsViewController*)[tabBarController.viewControllers objectAtIndex:3];
    
    ////set standard errror to file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
    //freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
    
    
	[window makeKeyAndVisible];
        
	return YES;
}


- (BOOL) currentlyTracking {

	return trackerView.isTracking;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	runningInBackground = YES;
	[trackerView applicationRunningInBackground:YES];
	
	NSLog(@" The applicationDidEnterBackground");
		
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	//[self.deepSleepPreventer startPreventSleep];
	runningInBackground = NO;
	[trackerView setViewData]; // tell the view to update
	[trackerView applicationRunningInBackground:NO];
	
	NSLog(@" The applicationDidEnterForeground");
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	
	NSLog(@"Application Terminaged");
	
}

#pragma mark -
#pragma mark ImagePickerController Methods from Camera View
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
	[cameraView dismissModalViewControllerAnimated:YES];
	tabBarController.selectedIndex = 0;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	

	UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	// save the image to disk (photos album)
	UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
		
	// create a GUID filename
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);

	
	NSString * folder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Pictures"];
	NSString * fileName = [NSString stringWithFormat:@"%@.png", string];
	NSString * filePath = [folder stringByAppendingPathComponent:fileName];
	
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:folder isDirectory:NULL]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:folder attributes:nil];
	}
	
	UIImage * rescaledImage = [self scaleAndRotateImage:image];
	
	// Write image to PNG
	[UIImagePNGRepresentation(rescaledImage) writeToFile:filePath atomically:YES];
		
	[cameraView dismissModalViewControllerAnimated:YES];
	tabBarController.selectedIndex = 0;
	
	// notify the GPSTrackerView that there is a new image
	[trackerView newPictureTaken:filePath];
}

- (UIImage *) scaleAndRotateImage:(UIImage *)image
{
	int kMaxResolution = 800; // Or whatever
	
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > kMaxResolution || height > kMaxResolution) {
		CGFloat ratio = width/height;
		if (ratio > 1) {
			bounds.size.width = kMaxResolution;
			bounds.size.height = bounds.size.width / ratio;
		}
		else {
			bounds.size.height = kMaxResolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	UIImageOrientation orient = image.imageOrientation;
	switch(orient) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}


@end
