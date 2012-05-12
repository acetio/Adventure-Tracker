//
//  LocationHelper.h
//  GPSTracker v1.0
//
//  Created by Nic Jackson on 15/06/2010.
//  Copyright 2010 thatlondon. All rights reserved.
//  
//	This class is a reusable data class to initiate GPS monitoring
//  it includes iPhone 4.0 features
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define kGPS_SLEEPTIME 550

#define kGPS_TIMEOUT 15
#define kGPS_ATTEMPTS 5

#define kLOWPOWER_GPS_TIMEOUT 5
#define kLOWPOWER_GPS_ATTEMPTS 2

#define kFIRST_START_TIMEOUT 550

@protocol LocationHelperDelegate;

@class CLLocationManager,AVAudioPlayer,LocationDataObject;

@interface LocationHelper : NSObject <CLLocationManagerDelegate> {
	
	id <LocationHelperDelegate> delegate;
	
	CLLocationManager *locationManager;  // reference to the location manager object
		
	BOOL isTracking; // are we currently tracking for events
	
	int numberEvents; // number of location events receieved from the server
	
	NSMutableArray *BestLocationArray; // temporary list of locations whilst attempting to get a good fix
    NSMutableArray *SignificantChangeLocationArray; // temporary list of locations from the significant change events
	
	BOOL monitorSignificantChanges; // SHOULD we monitor for significant changes
	
	int locationFetchAttempt;  // number of attempts at getting a good location
	
	int RefreshInterval; // number of seconds to check location 0 = permenantly on
	
	int DistanceTraveled; // total distancec traveld in current session
	
	LocationDataObject * prevLocation; // previous location
	LocationDataObject * currentLocation; // previous location
	
	BOOL lowPowerMode;
	
	int GPSTimeoutInterval;
	int GPSRetry;
    BOOL runNow;
    
    BOOL isFirstStart; // if this is the first time the GPS has been activated then run the GPS for 10 minutes to get a really good fix.
    
	UIApplication * app;
	
	NSDate *taskDate;
	
	UIBackgroundTaskIdentifier bgTaskGPSTimer; // GPS On Task
    UIBackgroundTaskIdentifier GPSTimeoutTimer; // GPS TimeoutTimer
	
	CLLocationAccuracy gpsAccuracy; // constant value for current accuracy
	CLLocationDistance gpsDistanceFilter;  // the number of meters that a possition must change before an update is reported
}

-(id)init;

- (void) storeLocation; // executed when we store a location that meets our accuracy requirement.

- (void) startLocationService; // start the location service
- (void) stopLocationService; // stop the location service
- (void) enableSignificantChanges: (BOOL)enabled; // enable the low power significant change notification service

- (void) startLocationUpdates; // helper function to call locationManager and set up timers
- (void) stopLocationUpdates; // helper function to call locationManager and set up timers
- (void) startGPSWithDelay:(int) timeSeconds; // starts the GPS Timer after N seconds
- (void) resetTimers; // helper function to reset the GPS timers

- (void)lowPowerMode:(BOOL)mode; // switch GPS to low power mode // not implemented

@property (nonatomic) BOOL monitorSignificantChanges;
@property (nonatomic) BOOL useAlternateTask;
@property (nonatomic) int numberEvents;
@property (nonatomic) int DistanceTraveled;
@property (nonatomic) int RefreshInterval;
@property (nonatomic) int GPSTimeoutInterval;
@property (nonatomic) int GPSRetry;
@property (nonatomic,retain) LocationDataObject * prevLocation;
@property (nonatomic,retain) LocationDataObject * currentLocation;
@property (nonatomic) BOOL lowPowerMode;
@property (nonatomic) BOOL GPSActive;

@property (nonatomic,retain) UIApplication * app;

@property (nonatomic, assign) id <LocationHelperDelegate> delegate;

@end

@protocol LocationHelperDelegate
- (void)foundLocation: (LocationDataObject*) currentLocation: (LocationDataObject*) previousLocation: (NSArray*) SignificantChangeLocations; // sent when the location service has a new location
- (void)newMessage:(NSString*)message; // sends variaous messages such as GPS Timeout, Searching For Location
@end
