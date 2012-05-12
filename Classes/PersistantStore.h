//
//  PersistantStore.h
//  GPSTracker
//
//  Created by Nic Jackson on 23/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LocationDataObject;

@interface PersistantStore : NSObject {

	NSString * GUID;
	NSMutableArray * locationArray;
	NSMutableArray * imageLocationArray;
	
	NSString * username;
	int refreshInterval;
	NSArray * storeArray;
	BOOL useSignificant;
	BOOL autoUploadImagesWIFI;
	BOOL useQuickFollow;
	
	int numberEvents;
	
}

@property (nonatomic,retain) NSMutableArray * locationArray;
@property (nonatomic,retain) NSMutableArray * imageLocationArray;
@property (nonatomic,retain) NSString * GUID;
@property (nonatomic,retain) NSString * username;
@property (nonatomic) int refreshInterval;
@property (nonatomic) int numberEvents;
@property (nonatomic) BOOL useSignificant;
@property (nonatomic) BOOL autoUploadImagesWIFI; // only upload images when connected to a WIFI connection
@property (nonatomic) BOOL useQuickFollow; // allows most recent track to be retrieved with email address

-(id)init;

-(NSString*)dataFilePath;

-(void)addDataToLocationArray: (LocationDataObject *) location; // append any new data to the temporary location array
-(void)addDataToPicturesArray: (NSMutableArray *) pictures; // append any new data to the temporary location array
-(void)sortLocationArray; // sorts the location array to order it by GUID

-(void)loadData;
-(void)saveData;

-(void)setDefaults;

@end
