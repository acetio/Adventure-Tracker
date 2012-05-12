//
//  LocationImage.h
//  GPSTracker
//
//  Created by Nic Jackson on 12/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationDataObject.h"

// this class contains 
@interface LocationImage : NSObject {

	LocationDataObject *LocationObject; // location object relating to image
	NSString *imagePath; // path to image object
		
}

-(id)init;

- (id)initWithCoder:(NSCoder *)coder;// used to de-serialise the class

- (void)encodeWithCoder:(NSCoder *)coder; // used to serialise the class


@property (nonatomic,retain) NSString *imagePath;
@property (nonatomic,retain) LocationDataObject *LocationObject;

@end
