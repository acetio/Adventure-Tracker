//
//  LocationDataObject.m
//  GPSTracker
//
//  Created by Nic Jackson on 11/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LocationDataObject.h"


@implementation LocationDataObject

@synthesize LocationObject,LocationPosition,GUID,SignificantLocation;

-(id)init {
	
	if(self = [super init]) {
	
		
	}
	
	return self;
}

-(id)initWithDataObject: (CLLocation *)dataObject LocationPosition: (int)position LocationGUID: (NSString*) guid {

	if(self = [super init]) {
		
		self.LocationObject = dataObject;
		self.LocationPosition = position;
		self.GUID = guid;
	}
	
	return self;
	
}

-(id)initWithDataObject: (CLLocation *)dataObject LocationPosition: (int)position {
	
	if(self = [super init]) {
		
		self.LocationObject = dataObject;
		self.LocationPosition = position;
	}
	
	return self;
	
}

-(id)initWithDataObject: (CLLocation *)dataObject LocationPosition: (int)position SignificantLocation:(BOOL)significantLocation {
	
	if(self = [super init]) {
		
		self.LocationObject = dataObject;
		self.LocationPosition = position;
        self.SignificantLocation = significantLocation;
	}
	
	return self;
	
}

- (id)initWithCoder:(NSCoder *)coder {

	self.LocationObject = [[coder decodeObjectForKey:@"MVLocationObject"] retain];
	self.LocationPosition = [coder decodeIntForKey:@"MVLocationPosition"];
	self.GUID = [[coder decodeObjectForKey:@"MVGUID"] retain];
	self.SignificantLocation = [coder decodeBoolForKey:@"MVSignificantLocation"];
	
	return self;
	
}

- (void)encodeWithCoder:(NSCoder *)coder {

	[coder encodeObject:self.LocationObject forKey:@"MVLocationObject"];
	[coder encodeObject:self.GUID forKey:@"MVGUID"];
	[coder encodeInt:self.LocationPosition forKey:@"MVLocationPosition"];
	[coder encodeBool:self.SignificantLocation forKey:@"MVSignificantLocation"];
}


@end
