//
//  LocationDataObject.h
//  GPSTracker
//
//  Created by Nic Jackson on 11/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface LocationDataObject : NSObject {

	CLLocation * LocationObject; // the CLLocation object received from the GPS Device
	int LocationPosition; // the order that the object is recieved.  We use this when sending to the server as data is not always send syncronsly
	NSString * GUID; // Unique ID to which this location refers
	
	BOOL SignificantLocation;// is this object recorded with significant location updates?
	
}

-(id)init;
-(id)initWithDataObject: (CLLocation *)dataObject LocationPosition: (int)position LocationGUID: (NSString*) guid;
-(id)initWithDataObject: (CLLocation *)dataObject LocationPosition: (int)position;
-(id)initWithDataObject: (CLLocation *)dataObject LocationPosition: (int)position SignificantLocation: (BOOL) significantLocation;

- (id)initWithCoder:(NSCoder *)coder;// used to de-serialise the class
- (void)encodeWithCoder:(NSCoder *)coder; // used to serialise the class

@property (nonatomic,retain) CLLocation * LocationObject;
@property (nonatomic,retain) NSString * GUID;
@property (nonatomic) BOOL SignificantLocation;
@property (nonatomic) int LocationPosition;

@end
