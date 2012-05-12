//
//  LocationImage.m
//  GPSTracker
//
//  Created by Nic Jackson on 12/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LocationImage.h"

@implementation LocationImage

@synthesize LocationObject,imagePath;
-(id)init {
	
	if(self = [super init]) {
		
		
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	
	self.LocationObject = [[coder decodeObjectForKey:@"MVLocationObject"] retain];
	self.imagePath = [[coder decodeObjectForKey:@"MVimagePath"] retain];
	
	return self;
	
}

- (void)encodeWithCoder:(NSCoder *)coder {
	
	[coder encodeObject:self.LocationObject forKey:@"MVLocationObject"];
	[coder encodeObject:self.imagePath forKey:@"MVimagePath"];
	
}

@end
