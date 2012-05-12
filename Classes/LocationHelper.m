//
//  LocationHelper.m
//  GPSTracker
//
//  Created by Nic Jackson on 15/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LocationDataObject.h"
#import "LocationHelper.h"

@implementation LocationHelper

@synthesize monitorSignificantChanges,app, useAlternateTask,numberEvents,delegate,RefreshInterval,DistanceTraveled,prevLocation,currentLocation,lowPowerMode,GPSRetry,GPSTimeoutInterval,GPSActive;

-(id)init {
	
	if(self = [super init]) {
		
    
    }
        
	return self;
}

#pragma mark -
#pragma mark LocationHelper Methods

- (void)lowPowerMode:(BOOL)mode {

	if(mode) {
		self.GPSTimeoutInterval = kLOWPOWER_GPS_TIMEOUT;
		self.GPSRetry = kLOWPOWER_GPS_ATTEMPTS;
	} else {
		self.GPSTimeoutInterval = kGPS_TIMEOUT;
		self.GPSRetry = kGPS_ATTEMPTS;
	}
			
}

- (void) setupLocationService {

	NSLog(@"LocationHelper :: setupLocationService");
	
	if(isTracking)
		return;
    
    isTracking = YES;
    isFirstStart = NO;
	
    GPSTimeoutInterval = kFIRST_START_TIMEOUT;
	GPSRetry = kGPS_ATTEMPTS;
	DistanceTraveled = 0;
	RefreshInterval = 0; // set the refresh interval to be 0
	numberEvents = 0;
	
	gpsAccuracy = kCLLocationAccuracyHundredMeters;
	gpsDistanceFilter = 50;
    
	if(BestLocationArray != nil)
        [BestLocationArray release];
    
    BestLocationArray = [[NSMutableArray alloc] init];
    
    if(SignificantChangeLocationArray != nil)
        [SignificantChangeLocationArray release];
    
    SignificantChangeLocationArray = [[NSMutableArray alloc] init];
		
	numberEvents = 0;  
	DistanceTraveled = 0;
    
    if(locationManager == nil) {
        // start tracking location
        locationManager = [[CLLocationManager alloc]init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
    }
    
	locationFetchAttempt = 0; // set the fetch attempt to be 0;
    
    //start significant change updates
    [locationManager startMonitoringSignificantLocationChanges];
		
}

- (void) startLocationService {
    
    NSLog(@"LocationHelper :: startLocationService");
    [self setupLocationService];
    
}

- (void) stopLocationService {
    
	NSLog(@"LocationHelper :: stopLocationService");
    
	if(!isTracking)
		return;
	
	isTracking = NO;
    isFirstStart = NO;
    
	[self stopLocationUpdates];
	
	[locationManager release]; // clear and release the memory
	locationManager = nil;
    
}

// starts the search for a location immediately
- (void) startLocationUpdates {
	
    if(GPSActive)
        return;
        
    GPSActive = YES;
    
	NSLog(@"LocationHelper :: startLocationUpdates");
	    
	locationFetchAttempt = 0;
    
	NSAssert(GPSTimeoutTimer == UIBackgroundTaskInvalid, @"Background task GPSTimeoutTimer not invalid");
	
	GPSTimeoutTimer = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
		// Synchronize the cleanup call on the main thread in case
		// the task actually finishes at around the same time.
		dispatch_async(dispatch_get_main_queue(), ^{
			
			if (GPSTimeoutTimer != UIBackgroundTaskInvalid)
			{
                NSLog(@"GPSTimeoutTimer Background Task Execute :: Exit Handler");
				[[UIApplication sharedApplication] endBackgroundTask:GPSTimeoutTimer];
				GPSTimeoutTimer = UIBackgroundTaskInvalid;
			}
		});
	}];
    UIBackgroundTaskIdentifier localTask = GPSTimeoutTimer;
    NSLog(@"GPSTimeoutTimer Background Task Execute :: Init Handler, local task id %d",localTask);
	
	// Start the long-running task and return immediately.
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
        double timeoutTime = 0;
        
        while(GPSTimeoutTimer != UIBackgroundTaskInvalid && 
              timeoutTime < self.GPSTimeoutInterval  &&
              [[UIApplication sharedApplication] backgroundTimeRemaining] > 10
              && localTask == GPSTimeoutTimer) {
            
            [NSThread sleepForTimeInterval:0.3];
            timeoutTime += 0.3;
        }
        
        NSLog(@"GPSTimeoutTimer Background Task Execute :: Wait Complete, taskInvalid: %d, runningTime: %f, timeSeconds %d, local id: %d, global id %d",(bgTaskGPSTimer == UIBackgroundTaskInvalid) ? 1:0,timeoutTime,self.GPSTimeoutInterval,localTask,GPSTimeoutTimer);
        
        if (GPSTimeoutTimer != UIBackgroundTaskInvalid && GPSTimeoutTimer == localTask)
        {
            NSLog(@"GPSTimeoutTimer Background Task Execute :: GPS Timeout, local task id: %d, global task id: %d",localTask,GPSTimeoutTimer);
            [self storeLocation];
        }
        
		dispatch_async(dispatch_get_main_queue(), ^{
			if (localTask != UIBackgroundTaskInvalid)
			{
                NSLog(@"GPSTimeoutTimer Background Task Execute :: Cleanup, local task id: %d, global task id: %d",localTask,GPSTimeoutTimer);
				[[UIApplication sharedApplication] endBackgroundTask:localTask];
			}
		});
		
	});
    
	
    NSLog(@"LocationHelper :: startingGPS");
    [locationManager startUpdatingLocation];
    
}

- (void) stopLocationUpdates {
	
    NSLog(@"LocationHelper :: stopLocationUpdates");
    
    if(GPSActive)
        [locationManager stopUpdatingLocation];
    
    //stop significant change updates
    [locationManager stopMonitoringSignificantLocationChanges];
    
	if(GPSTimeoutTimer != UIBackgroundTaskInvalid) {
		GPSTimeoutTimer = UIBackgroundTaskInvalid;
	}
    
    if(bgTaskGPSTimer != UIBackgroundTaskInvalid) {
		bgTaskGPSTimer = UIBackgroundTaskInvalid;
	}

}

- (void) startGPSWithDelay:(int) timeSeconds{
	
	NSLog(@"Start GPS With Delay: %d",timeSeconds);
    
    // if the GPS is currently active do not start this task
    if(GPSActive)
        return;
    
    // if we are already have a task running but need to start immediately then set th running time to a huge number and the
    // task will begin
    if(bgTaskGPSTimer != UIBackgroundTaskInvalid && timeSeconds == 0) {
        runNow = YES;
        return;
    }
    
	NSAssert(bgTaskGPSTimer == UIBackgroundTaskInvalid, @"Background task bgTaskGPSTimer not invalid");
	
    UIBackgroundTaskIdentifier localTask;
	bgTaskGPSTimer = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
		// Synchronize the cleanup call on the main thread in case
		// the task actually finishes at around the same time.
		dispatch_async(dispatch_get_main_queue(), ^{
			
			if (bgTaskGPSTimer != UIBackgroundTaskInvalid)
			{
                NSLog(@"Background Task Execute :: Exit Handler");
				[[UIApplication sharedApplication] endBackgroundTask:bgTaskGPSTimer];
				bgTaskGPSTimer = UIBackgroundTaskInvalid;
			}
		});
	}];
    
    localTask = bgTaskGPSTimer;
    
    NSLog(@"Background Task Execute :: Init Handler, local task id %d",localTask);
	
	// Start the long-running task and return immediately.
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
        NSDate * StartDate = [NSDate date];
        runNow = NO;
        double runningTime = 0;
        
        while(bgTaskGPSTimer != UIBackgroundTaskInvalid && 
              runningTime < timeSeconds &&
              !runNow &&
              [[UIApplication sharedApplication] backgroundTimeRemaining] > 10
              && localTask == bgTaskGPSTimer) {
        
            [NSThread sleepForTimeInterval:0.3];
            
            runningTime = [[NSDate date] timeIntervalSinceDate:StartDate];
            
        }
        
        NSLog(@"Background Task Execute :: Wait Complete, taskInvalid: %d, runningTime: %f, timeSeconds %d, local id: %d, global id %d",(bgTaskGPSTimer == UIBackgroundTaskInvalid) ? 1:0,runningTime,timeSeconds,localTask,bgTaskGPSTimer);
        
        if (bgTaskGPSTimer != UIBackgroundTaskInvalid && bgTaskGPSTimer == localTask)
        {
            NSLog(@"Background Task Execute :: Start Location Updates, local task id: %d, global task id: %d",localTask,bgTaskGPSTimer);
            [self startLocationUpdates];
        }
        
		dispatch_async(dispatch_get_main_queue(), ^{
			if (localTask != UIBackgroundTaskInvalid)
			{
                NSLog(@"Background Task Execute :: Cleanup, local task id: %d, global task id: %d",localTask,bgTaskGPSTimer);
				[[UIApplication sharedApplication] endBackgroundTask:localTask];
				bgTaskGPSTimer = UIBackgroundTaskInvalid;
			}
		});
		
	});
        
}

- (void) storeLocation {
	
	NSLog(@"LocationHelper :: storeLocation");
    
    if(GPSTimeoutInterval == kFIRST_START_TIMEOUT && !isFirstStart) {
        
        isFirstStart = YES; //ignore future location updates until the first timeout period elapses
        
    } else {
        
        [locationManager stopUpdatingLocation];
        GPSActive = NO;
        
        // we also need to check if we have to kill the timer incase this function 
        // has not been called by the timer
        if(GPSTimeoutTimer != UIBackgroundTaskInvalid) {
            GPSTimeoutTimer = UIBackgroundTaskInvalid;
        }
        
        GPSTimeoutInterval = kGPS_TIMEOUT; // reset this as the first time the GPS runs the timeout is set to 10 minutes
        isFirstStart = NO;
        
    }
		    
	// first get the item from the location array with the best accuracy
	float maxAccuracy = 99999999.0;
	CLLocation * bestLocation = nil;
		
	locationFetchAttempt = 0;// reset the get location try count
	
	if([BestLocationArray count] < 1)
		return;
	
	if([BestLocationArray count] == 1) {
		
		bestLocation = [BestLocationArray objectAtIndex:0];  // we only have one object to add that
		
	}else {
		
		// check for the object with the best accuracy and then add it to the array
		
		for(int n=0;n < [BestLocationArray count];n++) {
			
			if(((CLLocation*)[BestLocationArray objectAtIndex:n]).horizontalAccuracy >0.0f && (double)((CLLocation*)[BestLocationArray objectAtIndex:n]).horizontalAccuracy < maxAccuracy) {
				bestLocation = (CLLocation*)[BestLocationArray objectAtIndex:n];
				maxAccuracy = ((CLLocation*)[BestLocationArray objectAtIndex:n]).horizontalAccuracy;
			}
			
		}
		
	}
	
	BOOL AddObject = YES;
	
	
	// now we need to check at the current location is not the same as the previous location
	if(bestLocation != nil) {
        
		if(currentLocation != nil && currentLocation.LocationObject.coordinate.latitude == bestLocation.coordinate.latitude && currentLocation.LocationObject.coordinate.longitude == bestLocation.coordinate.longitude) {
			AddObject = NO;		
			NSLog(@"Current Location same as Previous Location");
		} else {
			// set the previous location to the current location
		
			prevLocation = currentLocation;
		}
        
        LocationDataObject *dataObject = [[LocationDataObject alloc] initWithDataObject: [bestLocation retain] LocationPosition:numberEvents];
		
        currentLocation = dataObject;
        
	}
	    
    NSMutableArray * significantArray = [NSMutableArray arrayWithCapacity:10];
    
    @synchronized(self) {
        for(int n=0; n < [SignificantChangeLocationArray count];n++) {
            
            [significantArray addObject:[[LocationDataObject alloc] 
                                        initWithDataObject: [[SignificantChangeLocationArray objectAtIndex:n] retain] 
                                        LocationPosition:n SignificantLocation:YES]];
        }
	}
    
	if(AddObject) {
			
		// add the object to our data store
		numberEvents++;
		
		// work out the distance traveled only if the accuracy is resonable
		if(prevLocation != nil && bestLocation.horizontalAccuracy < 200) {			
			CLLocationDistance dist;
			dist = [prevLocation.LocationObject distanceFromLocation:bestLocation];
			NSLog(@"Traveled :%f",dist);
			DistanceTraveled += (int)dist;
		}
		
		
	}
		
	
	// notify our delegate of a new location
	if(delegate != nil)
         [delegate foundLocation: currentLocation: prevLocation: significantArray];
	
    // flush our best location array
	[BestLocationArray removeAllObjects];
    
    @synchronized(self) {
        // flush the significant object array
        [SignificantChangeLocationArray removeAllObjects];
    }
    
	// if we are not using significant location updates then we need to 
	// sleep for a period before restarting the GPS
    
    if(bgTaskGPSTimer != UIBackgroundTaskInvalid) {
        NSLog(@"LocationHelper :: Kill old Task");
        [[UIApplication sharedApplication] endBackgroundTask:bgTaskGPSTimer];
        bgTaskGPSTimer = UIBackgroundTaskInvalid;
        
        // wait for the old thread to be killed before respawning.
        // there can sometimes be a dealy which causes the new thread to be killed not the old
        [NSThread sleepForTimeInterval:1]; 
    }
    
    NSLog(@"LocationHelper :: Start GPS");
    [self startGPSWithDelay:kGPS_SLEEPTIME];
	
}

#pragma mark -
#pragma mark CLLocationManagerDelegate Methods
-(void)locationManager:(CLLocationManager *) manager
   didUpdateToLocation:(CLLocation *)newLocation 
		  fromLocation:(CLLocation *)oldLocation {

    if(GPSActive) {
        
        // we have arrived here from an event from the main gps
        
        BOOL locationFinished = NO;
        
        // first lets check the accuracy of the location
        if(
           ((newLocation.horizontalAccuracy <= gpsAccuracy && newLocation.verticalAccuracy <= gpsAccuracy) || (locationFetchAttempt >= GPSRetry))
           && !isFirstStart
           ) {
            
            NSLog(@"Main GPS Location Stored lat:%f lon:%f acc:%f  %f %f attempt:%d",newLocation.coordinate.latitude,newLocation.coordinate.longitude,gpsAccuracy,newLocation.horizontalAccuracy,newLocation.verticalAccuracy,locationFetchAttempt);
            locationFinished = YES;
            
        } else {
            
            NSLog(@"Main GPS Location Recieved lat:%f lon:%f acc:%f %f %f attempt:%d, firststart: %@",newLocation.coordinate.latitude,newLocation.coordinate.longitude,gpsAccuracy,newLocation.horizontalAccuracy,newLocation.verticalAccuracy,locationFetchAttempt, ((isFirstStart) ? @"true":@"false"));
            
        }
        
        [BestLocationArray addObject:[newLocation retain]]; // store the location in an array when we do decide to store we can search the array for the best value
            
        locationFetchAttempt++;
        
        if(locationFinished) {
            [self storeLocation];
        }
        
    } else {
        
        // this event must be due to a significant notification update
        // add this object to the array but do not store the data
        NSLog(@"Significant Location Recieved lat:%f lon:%f acc:%f %f %f attempt:%d",newLocation.coordinate.latitude,newLocation.coordinate.longitude,gpsAccuracy,newLocation.horizontalAccuracy,newLocation.verticalAccuracy,locationFetchAttempt);
        
        //lock the object to ensure that no other thread is trying to access it
        @synchronized(self) {
            [SignificantChangeLocationArray addObject:[newLocation retain]];
        }
        
    }
	
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	
	NSLog(@"Unable to get Location");
	[self storeLocation];
    
}

@end
