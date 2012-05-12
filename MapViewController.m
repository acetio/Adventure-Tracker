//
//  MapViewController.m
//  GPSTracker
//
//  Created by Nic Jackson on 22/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationDataObject.h"

@implementation MapViewController

@synthesize mapView,annotationArray;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
	
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	isInView = NO;
	
	
	

}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)viewDidAppear:(BOOL)animated {
	
	isInView = YES;
	
	// draw the Annontations onto the map

	[mapView addAnnotations:annotationArray];
	
	// set the zoom
	MKCoordinateSpan span;
	span.latitudeDelta = 0.05;
	span.longitudeDelta = 0.05;
	
	MKCoordinateRegion region;
	region.span = span;
	region.center = lastLocation.LocationObject.coordinate;
	
	// zoom
	mapView.region = region;
	
}

- (void)viewDidDisappear:(BOOL)animated {

	// clear the annnotations
	[mapView removeAnnotations:annotationArray];
	isInView = NO;
}

- (void)setCurrentLocation:(LocationDataObject *) location {

	// create an annotation object then add it to the map
	MKPointAnnotation * annotation = [[MKPointAnnotation alloc] init];
	annotation.coordinate = location.LocationObject.coordinate;
	
	lastLocation = location;
	
	if(annotationArray == nil)
		annotationArray = [[NSMutableArray alloc]init];
	[annotationArray addObject:[annotation retain]];
	
	if(isInView) {
		// draw the Annontations onto the map
		[mapView addAnnotation:annotation];
	
		MKCoordinateSpan span;
		span.latitudeDelta = 0.05;
		span.longitudeDelta = 0.05;
		
		MKCoordinateRegion region;
		region.span = span;
		region.center = lastLocation.LocationObject.coordinate;
		
		// zoom
		mapView.region = region;
		
	}
	
}

- (void)clearLocations {

	for(int n=0;n < [annotationArray count];n++) {
	
		// clean up
		[[annotationArray objectAtIndex:n] release];
		
	}
	
	[annotationArray removeAllObjects];
	
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
