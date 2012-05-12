//
//  DataUploader.h
//  GPSTracker
//
//  Created by Nic Jackson on 03/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum networkReachability {
    kNetworkReachability_NONE = 0,
 	kNetworkReachability_WIFI = 1,
	kNetworkReachability_WWAN =2
} kNetworkReachability;

typedef enum uploadStatus {
    kuploadStatus_SUCCESS = 0,
 	kuploadStatus_FAILED = 1,
	kuploadStatus_NETWORK_UNAVIALBLE = 2,
	kuploadStatus_NOTHING_TO_UPLOAD = 3
} kUploadStatus;

@protocol DataUploaderDelegate;

@class PersistantStore,GPSTrackerAppDelegate;

@interface DataUploader : NSObject {
	
	id <DataUploaderDelegate> delegate;
	
	PersistantStore *dataStore;
	BOOL uploading;
	UIBackgroundTaskIdentifier uploadBackgroundTask; // Background Task for uploading data
	
	BOOL manualUpload;
	
	UIApplication *app;
	
	int totalDataSent;
	
}

+ (DataUploader*)sharedInstance;
+ (id)allocWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (id)retain;
- (unsigned)retainCount;
- (void)release;
- (id)autorelease;



- (void) PostDataToServer; // sends the collected data to the server
- (kUploadStatus) PostTracksToServer; // sends the collected track data to the server
- (kUploadStatus) PostImagesToServer; // sends the collected image data to the server
- (kNetworkReachability) connectedToNetwork; // determines if the currently connected to the network

@property (nonatomic) BOOL uploading;
@property (nonatomic) BOOL manualUpload;
@property (nonatomic) int totalDataSent;

@property (nonatomic, assign) id <DataUploaderDelegate> delegate;

@end

@protocol DataUploaderDelegate
	- (void)uploadComplete:(kUploadStatus)status; // alerts the subscriber of upload outcome
@end