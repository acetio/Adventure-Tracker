//
//  PersistantStore.m
//  GPSTracker
//
//  Created by Nic Jackson on 23/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PersistantStore.h"
#import "LocationDataObject.h"

#define kFilename @"data.arch"

@implementation PersistantStore

@synthesize locationArray,GUID,username,refreshInterval,useSignificant,numberEvents,imageLocationArray,autoUploadImagesWIFI,useQuickFollow;

-(id)init {
	
	if(self = [super init]) {
		
		[self loadData];
		
	}
	
	return self;
	
}

- (NSString *)dataFilePath {    

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:kFilename]; 

}

-(void)addDataToLocationArray: (LocationDataObject *) location {

	[locationArray addObject:[location retain]];
	
}

- (void) addDataToPicturesArray: (NSMutableArray *) pictures {
	
	for(int n=0; n < [pictures count]; n++) {
		
		[imageLocationArray addObject:[[pictures objectAtIndex:n] retain]];
		
	}
	
}

NSInteger lastNameFirstNameSort(id location1, id location2, void *reverse)
{
	
	NSString *guid1 = ((LocationDataObject*)location1).GUID;
	NSString *guid2 = ((LocationDataObject*)location2).GUID;
	
	NSComparisonResult comparison = [guid1 localizedCaseInsensitiveCompare:guid2];
	
	if (comparison == NSOrderedSame) {
		
		NSNumber * pos1 = [NSNumber numberWithInt:((LocationDataObject*)location1).LocationPosition];
		NSNumber * pos2 = [NSNumber numberWithInt:((LocationDataObject*)location2).LocationPosition];
		comparison = [pos1 compare:pos2];
		
	}
	
	if ((BOOL *)reverse == NO) {
		return 0 - comparison;
	}
	
	return comparison;
	
}
		 
-(void)sortLocationArray {

	BOOL reverseSort = YES;
	[locationArray sortUsingFunction:lastNameFirstNameSort context:&reverseSort];
	
}

-(void)loadData {

	if([[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath]]) {
	
		storeArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self dataFilePath]];
		
		if([storeArray count] == 9) {
			
			// load from the settings file
			self.GUID = (NSString*)[storeArray objectAtIndex:0];
			self.locationArray = [NSMutableArray arrayWithArray:(NSArray*)[storeArray objectAtIndex:1]];
			self.username = (NSString*)[storeArray objectAtIndex:2];
			self.refreshInterval = [(NSNumber*)[storeArray objectAtIndex:3] intValue];
			self.useSignificant = [(NSNumber*)[storeArray objectAtIndex:4] boolValue];
			self.numberEvents = [(NSNumber*)[storeArray objectAtIndex:5] intValue];
			self.imageLocationArray = [NSMutableArray arrayWithArray:(NSArray*)[storeArray objectAtIndex:6]];
			self.autoUploadImagesWIFI = [(NSNumber*)[storeArray objectAtIndex:7] boolValue];
			self.useQuickFollow  = [(NSNumber*)[storeArray objectAtIndex:8] boolValue];
			
			return;
			
		} 
		
	}
	
	// if we have no settings to load then set defaults
	[self setDefaults];
	
}

-(void)saveData {

	if(GUID == nil)
		GUID = [NSString stringWithString:@""];
	
	if(locationArray == nil)
		locationArray = [[NSMutableArray alloc] init];
	
	if(imageLocationArray == nil)
		imageLocationArray = [[NSMutableArray alloc] init];
	
	if(username == nil)
		username = [NSString stringWithString:@""];
	
	NSMutableArray * tempArray = [[NSMutableArray alloc] init];
	[tempArray addObject:GUID];
	[tempArray addObject:locationArray];
	[tempArray addObject:username];
	[tempArray addObject:[NSNumber numberWithInt:refreshInterval]];
	[tempArray addObject:[NSNumber numberWithBool:useSignificant]];
	[tempArray addObject:[NSNumber numberWithInt:numberEvents]];
	[tempArray addObject:imageLocationArray];
	[tempArray addObject:[NSNumber numberWithBool:autoUploadImagesWIFI]];
	[tempArray addObject:[NSNumber numberWithBool:useQuickFollow]];
	
	if([NSKeyedArchiver archiveRootObject:tempArray toFile:[self dataFilePath]])
		NSLog(@"Data Saved");
	else
		NSLog(@"Data Save Fail");

	[tempArray release];
	
	
}

-(void)setDefaults {

	// set the defaults
	self.GUID = [NSString stringWithString:@""];
	self.locationArray = [[NSMutableArray alloc] init];
	self.username = [NSString stringWithString:@""];
	self.refreshInterval = 10;
	self.useSignificant = NO;
	self.numberEvents = 0;
	self.imageLocationArray = [[NSMutableArray alloc] init];
	self.autoUploadImagesWIFI = YES;
	self.useQuickFollow  = YES;
	
}

@end
