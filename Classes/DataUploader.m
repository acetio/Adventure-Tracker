//
//  DataUploader.m
//  GPSTracker
//
//  Created by Nic Jackson on 03/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DataUploader.h"
#import "PersistantStore.h"
#import "GPSTrackerAppDelegate.h"
#import "LocationDataObject.h"
#import "LocationImage.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

static DataUploader *sharedInstance = nil;

@implementation DataUploader

@synthesize uploading,manualUpload,totalDataSent,delegate;

-(id)init {
	
	if(self = [super init]) {
		
		app = [UIApplication sharedApplication];
		uploadBackgroundTask = UIBackgroundTaskInvalid;
		dataStore = ((GPSTrackerAppDelegate*)[UIApplication sharedApplication].delegate).dataStore;
		
	}
	
	return self;
}


#pragma mark -
#pragma mark Singleton methods
+ (DataUploader*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
			sharedInstance = [[DataUploader alloc] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

#pragma mark -
#pragma mark Adventure Tracker Server Communication Methods
- (void) PostDataToServer {
	
	// first check our network connection
	kNetworkReachability networkStatus = [self connectedToNetwork];
	
	if(networkStatus == kNetworkReachability_NONE) {
		NSLog(@"Unable to Send Data to Server - No Network Connection");
		//[app.logView updateLog:@"Unable to Send Data to Server"];
		return; // not connected dont bother
	}
	
	if(uploading)
		return;
	
	uploading = YES;
	
	// implement the background task
	// Request permission to run in the background. Provide an
	// expiration handler in case the task runs long.
	NSAssert(uploadBackgroundTask == UIBackgroundTaskInvalid, @"Background task PostDataToServer not invalid");
	
	uploadBackgroundTask = [app beginBackgroundTaskWithExpirationHandler:^{
		// Synchronize the cleanup call on the main thread in case
		// the task actually finishes at around the same time.
		dispatch_async(dispatch_get_main_queue(), ^{
			
			if (uploadBackgroundTask != UIBackgroundTaskInvalid)
			{
				[app endBackgroundTask:uploadBackgroundTask];
				uploadBackgroundTask = UIBackgroundTaskInvalid;
			}
		});
	}];
	
	// Start the long-running task and return immediately.
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
		kUploadStatus status;
		
		// send the track data to the server
		status = [self PostTracksToServer];
		
		// now try to send any image data to the server only if we are doing a manual upload
		// should we send the data over a 3G connection
		if(networkStatus != kNetworkReachability_WWAN || manualUpload)
			status = [self PostImagesToServer];

		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
				
		//[pool release];
		
		// notify our delegate of upload status
		if(delegate != nil)
			[delegate uploadComplete:status];
		
        uploading = NO;
        manualUpload = NO;
        
		dispatch_async(dispatch_get_main_queue(), ^{
			if (uploadBackgroundTask != UIBackgroundTaskInvalid)
			{
				[app endBackgroundTask:uploadBackgroundTask];
				uploadBackgroundTask = UIBackgroundTaskInvalid;
			}
		});
		
				
	});
	
	
	
}

- (kUploadStatus) PostTracksToServer {
	
	if([dataStore.locationArray count] < 1) {
		NSLog(@"No data to upload");
		//[app.logView updateLog:@"No data to upload"];
		return kuploadStatus_NOTHING_TO_UPLOAD;
	}else {
		NSLog(@"Sending Data to Server");
		//[app.logView updateLog:@"Sending Data to Server"];
	}
	
	kUploadStatus status;
	
	BOOL sending = YES;
	
	while(sending) {
		
		// build our XML Datastring
		NSMutableString * dataString = [[NSMutableString alloc] init];
		
		[dataString appendString:@"<root>"];
		
		// sort the location Array into GUID order
		[dataStore sortLocationArray];
		
		// get the first GUID
		NSString * GUID = ((LocationDataObject*)[dataStore.locationArray objectAtIndex:0]).GUID;
		
		NSLog(@"Sending Data for track %@",GUID);
		
		//add a node to associate the user to the track
		if(dataStore.username != nil && GUID != nil && GUID.length == 36) {
			
			if([dataStore.username length] > 4) {
				
				[dataString appendFormat:@"<u user=\"%@\" GUID=\"%@\" qFollow=\"%d\"/>",dataStore.username,GUID,((dataStore.useQuickFollow) ? 1 : 0)];
				
			}
			
		}
		
		int endNo = 1; // the index where the current track cache ends
		
		for(int n=0; n < [dataStore.locationArray count];n++) {
			
			LocationDataObject *location = (LocationDataObject*)[dataStore.locationArray objectAtIndex:n];
			
			if([GUID compare:location.GUID] != NSOrderedSame) {
				
				// we have the data for a track so lets quit and continue uploading later
				endNo = n;
				break;
			}
			
			if(GUID != nil && GUID.length == 36) {
                double acc = (double)location.LocationObject.horizontalAccuracy;
                [dataString appendFormat:@"<d la=\"%f\" lo=\"%f\" ti=\"%@\" ac=\"%d\" po=\"%d\" sl=\"%d\"/>",location.LocationObject.coordinate.latitude,location.LocationObject.coordinate.longitude,[location.LocationObject.timestamp descriptionWithLocale:nil],(int)acc,(int)location.LocationPosition,((location.SignificantLocation) ? 0 : 1),nil];
			}
		}
		
		
		[dataString appendString:@"</root>"];
		
		
		NSString *post =[[NSString alloc] initWithFormat:@"GUID=%@&XMLData=%@",GUID,dataString];
		
		NSURL *url=[NSURL URLWithString:@"http://www.adventuretracker.net/SubmitTrack.aspx"];
		
		NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
		
		NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
		
		totalDataSent += [postData length]; // update the total data sent to the server this is bytes
		
		NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
		[request setURL:url]; 
		[request setHTTPMethod:@"POST"]; 
		[request setValue:postLength forHTTPHeaderField:@"Content-Length"]; 
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]; 
		[request setHTTPBody:postData];
		[request setTimeoutInterval:8];
		
		NSError *error;
		NSURLResponse *response; 
		NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		NSString * data = [[[NSString alloc] initWithData:urlData encoding: NSUTF8StringEncoding] autorelease];
		
		[dataString release]; // clean up our request string
		
		int statusCode = [((NSHTTPURLResponse *)response) statusCode];
		
		NSLog(@"Upload End status: %@, errorCode: %d",data, statusCode);
		
		if(statusCode == 200) {
			
			// all done remove the cache
			for(int n=0; n < endNo;n++) {
				
				[dataStore.locationArray removeObjectAtIndex:0];
				
			}
			
			status = kuploadStatus_SUCCESS;
			
			
		} else {
			
			sending = NO; // we have an error so stop trying to update the server
			status = kuploadStatus_FAILED;
		}
		
		if([dataStore.locationArray count] == 0)
			sending = NO;
		
		// save the location store
		[dataStore saveData];
		
	}
	
	return status;
	
}

- (kUploadStatus) PostImagesToServer {
	
	if([dataStore.imageLocationArray count] < 1) {
		NSLog(@"No images to upload");
		//[app.logView updateLog:@"No data to upload"];
		return kuploadStatus_NOTHING_TO_UPLOAD;
	}else {
		NSLog(@"Sending images to Server");
		//[app.logView updateLog:@"Sending Data to Server"];
	}
	
	kUploadStatus status;
	
	// we need to implement a timeout here to stop any uploads breaking the conditions of a background task
	BOOL sending = YES;
	
	while(sending) {
		
		// build our XML Datastring
		NSMutableString * dataString = [[NSMutableString alloc] init];
		
		[dataString appendString:@"<root>"];
		
		// get the GUID
		NSString * GUID = ((LocationImage*)[dataStore.imageLocationArray objectAtIndex:0]).LocationObject.GUID;
		NSString * imagePath = ((LocationImage*)[dataStore.imageLocationArray objectAtIndex:0]).imagePath;
		
		NSLog(@"Sending Data for image %@, %@",GUID,imagePath);
		
		LocationImage *locationImage = (LocationImage*)[dataStore.imageLocationArray objectAtIndex:0];
		LocationDataObject *location = locationImage.LocationObject;
		
		double acc = (double)location.LocationObject.horizontalAccuracy;
		[dataString appendFormat:@"<d la=\"%f\" lo=\"%f\" ti=\"%@\" ac=\"%d\" po=\"%d\"/>",location.LocationObject.coordinate.latitude,location.LocationObject.coordinate.longitude,[location.LocationObject.timestamp descriptionWithLocale:nil],(int)acc,(int)location.LocationPosition,nil];
		
		// now base64 encode the image and add it to the XML
		NSError *fileError = nil;
		
		NSData *imageData = [NSData dataWithContentsOfFile:locationImage.imagePath];
		
		NSString * base64File = [imageData base64Encoding]; // get the base 64 encoding
		
		[dataString appendString:@"<im>"];
		[dataString appendString:base64File];
		[dataString appendString:@"</im>"];
		
		[dataString appendString:@"</root>"];
		
		NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"http://www.adventuretracker.net/SubmitImage.aspx?GUID=%@",GUID]];
		
		NSLog(@"url: %@",url);
		
		NSString *boundary = @"0xKhTmLbOuNdArY---This_Is_ThE_BoUnDaRyy---pqo";
		
		NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
		[req setHTTPMethod:@"POST"];
		
		NSString *contentType = [NSString stringWithFormat:@"multipart/form-data, boundary=%@", boundary];
		[req setValue:contentType forHTTPHeaderField:@"Content-Type"];
		
		NSMutableData *postBody = [NSMutableData data];
		
		[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[@"Content-Disposition: form-data; name=\"XMLData\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		
		[req setHTTPBody:postBody];
		[req setTimeoutInterval:60]; // set the upload timeout to 60 seconds	
		
		NSError *error;
		NSURLResponse *response; 
		
		NSLog(@"Begin Send");
		NSData *urlData=[NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
		
		int statusCode = [((NSHTTPURLResponse *)response) statusCode];
		NSString * data = [[[NSString alloc] initWithData:urlData encoding: NSUTF8StringEncoding] autorelease];
		
		NSLog(@"Upload End status: %@, errorCode: %d",data, statusCode);
		
		if(statusCode == 200) {
			
			// delete the image from the bundle
			NSError *fileError = nil;
			[[NSFileManager defaultManager] removeItemAtPath:locationImage.imagePath  error:&fileError];
			
			// all done remove the cache
			[dataStore.imageLocationArray removeObjectAtIndex:0];
			status = kuploadStatus_SUCCESS;
			
		} else {
			
			sending = NO; // we have an error so stop trying to update the server
			status = kuploadStatus_FAILED;
		}
		
		if([dataStore.imageLocationArray count] == 0)
			sending = NO;
		
		// release our data string
		[dataString release];
		
		// save the location store
		[dataStore saveData];
		
	}
	
	return status;
	
}

- (kNetworkReachability) connectedToNetwork {
	
	// crete a 0.0.0.0 address
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress,sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family  = AF_INET;
	
	// recover reachability flags
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL,(struct sockaddr *)&zeroAddress);
	SCNetworkReachabilityFlags flags;
	
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability,&flags);
	CFRelease(defaultRouteReachability);
	
	if(!didRetrieveFlags) {
		
		NSLog(@"Error could not recover network flags");
		return 0;
	}
	
	BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	
	if ((flags & kSCNetworkReachabilityFlagsIsWWAN)  && !needsConnection)
		return kNetworkReachability_WWAN;
	else if ((flags & kSCNetworkFlagsReachable) && !needsConnection)
		return kNetworkReachability_WIFI;
	else
		return kNetworkReachability_NONE;
	
}

@end
