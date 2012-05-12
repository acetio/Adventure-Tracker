//
//  GPSTrackerViewController.h
//  GPSTracker
//
//  Created by Nic Jackson on 09/06/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "LocationHelper.h"
#import "DataUploader.h"

@class GPSTrackerAppDelegate,PersistantStore,DataUploader;

@interface GPSTrackerViewController : UIViewController <MFMailComposeViewControllerDelegate,LocationHelperDelegate,DataUploaderDelegate> {

	UILabel *uidLabel;
	
	UILabel *latLabel;
	UILabel *lonLabel;
	UILabel *accLabel;
	UILabel *distLabel;
	
	UILabel *dataSendLabel;
	UILabel *dataPointLabel;
	UILabel *dataSentLabel;
	
	UILabel *positionRetrievedLabel;
	
	UILabel *uploadLabel;
	UILabel *emailLabel;

	UIButton *startButton;
	UIButton *emailButton;
	UIButton *uploadButton;
	
	NSString *currentGUID;
	
	LocationHelper * locationHelper; // instance of the Location Helper class
		
	BOOL backgroundSupported;
	BOOL runnningInBackground;
	BOOL isTracking;
	
	int numberEvents; // number of events received from the GPS Device
	int totalDataSent; // ammount of data sent to the server in KB;
    
    NSDateFormatter * dateFormat;
	NSDate * lastPostionTime; // last time a new position was received
	NSDate * lastSendTime; // last time data was successfully sent to the server
	
    NSNumberFormatter *numberFormatter;
    
	GPSTrackerAppDelegate *app;
	
	PersistantStore * dataStore;
	
	BOOL dontBugUsername;
	BOOL dontBugSession;
    BOOL startNewSession;
		
	BOOL awaitingImageLocation; // when we receive notification of picture being taken we need to get the location
	
	NSMutableArray * locationPictures; // temporary array of locationPictures
	
	BOOL manualUpload;
	
}

- (IBAction)startClick:(id)sender;
- (IBAction)emailClick:(id)sender;
- (IBAction)uploadClick:(id)sender;

- (BOOL) startTracking;
- (void) stopTracking;

- (void) DoUpload:(BOOL) uploadImages;

- (NSString *)GetUUID;

- (void) setViewData; // sets the View screen
- (void) applicationRunningInBackground:(BOOL) background; // called by the main view to notify that the application is now running in the background
- (void) checkUpload; // checks to see if there is data which has not been uploaded
- (void) checkEmail; // checks to see if the email button is valid

- (void) newPictureTaken: (NSString*) filePath; // called by the app delegate when the user takes a picture that requires a location

@property (nonatomic,retain) LocationHelper * locationHelper;

@property (nonatomic, retain) IBOutlet UILabel * uidLabel;
@property (nonatomic, retain) IBOutlet UILabel * latLabel;
@property (nonatomic, retain) IBOutlet UILabel * lonLabel;
@property (nonatomic, retain) IBOutlet UILabel * accLabel;
@property (nonatomic, retain) IBOutlet UILabel * distLabel;
@property (nonatomic, retain) IBOutlet UILabel * dataSendLabel;
@property (nonatomic, retain) IBOutlet UILabel * dataPointLabel;
@property (nonatomic, retain) IBOutlet UILabel * dataSentLabel;
@property (nonatomic, retain) IBOutlet UILabel * positionRetrievedLabel;
@property (nonatomic, retain) IBOutlet UILabel * uploadLabel;
@property (nonatomic, retain) IBOutlet UILabel * emailLabel;

@property (nonatomic, retain) IBOutlet UIButton * startButton;
@property (nonatomic, retain) IBOutlet UIButton * emailButton;
@property (nonatomic, retain) IBOutlet UIButton * uploadButton;

@property (nonatomic) BOOL isTracking;


@end

