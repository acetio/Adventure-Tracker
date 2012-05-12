//
//  MapViewController.h
//  GPSTracker
//
//  Created by Nic Jackson on 22/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKMapView;
@class LocationDataObject;

@interface MapViewController : UIViewController {

	MKMapView *mapView;
	LocationDataObject *lastLocation;
	
	NSMutableArray *annotationArray; // arry of MKPointAnnotation*
	
	BOOL isInView;
	
}

- (void)setCurrentLocation:(LocationDataObject *) location; // inoform the map that it has a new location

- (void)clearLocations; // clear the annotations from the map

@property (nonatomic,retain) IBOutlet MKMapView *mapView;
@property (nonatomic,retain) NSMutableArray *annotationArray;

@end
