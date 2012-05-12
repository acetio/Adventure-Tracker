//
//  SettingsViewController.m
//  GPSTracker
//
//  Created by Nic Jackson on 25/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "GPSTrackerAppDelegate.h"
#import "PersistantStore.h"

@implementation SettingsViewController

@synthesize table;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    app = (GPSTrackerAppDelegate*)[UIApplication sharedApplication].delegate;
		
	[super viewDidLoad];
}


#pragma mark -
#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // 1 section
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return 3;
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";

	UITableViewCellStyle cellType = UITableViewCellStyleValue1;

	if(indexPath.row == 1)
		cellType = UITableViewCellStyleSubtitle;
	

		
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		
		cell = [[[UITableViewCell alloc] initWithStyle:cellType reuseIdentifier:CellIdentifier] autorelease];
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
	}
	
	switch (indexPath.row) {
			
			
		case 0: 
			
			cell.textLabel.text = @"Auto upload photos with WIFI only:";
			cell.detailTextLabel.text = (app.dataStore.autoUploadImagesWIFI) ? @"Yes" : @"No";
			break;
			
		case 1:
			cell.textLabel.text = @"Google / Yahoo username:";
			cell.detailTextLabel.text = app.dataStore.username;
			break;
			
		case 2:
			cell.textLabel.text = @"Quick Follow:";
			cell.detailTextLabel.text = (app.dataStore.useQuickFollow) ? @"Yes" : @"No";;
			break;
			
			
			
	}
	
	return cell;
	
}

/**
 Manage row selection: If a row is selected, create a new editing view controller to edit the property associated with the selected row.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	SettingsDetailController * detailController = [[SettingsDetailController alloc] initWithNibName:@"SettingsDetailController" bundle:nil];
	
	switch (indexPath.row) {
			
        
		case 0:
			detailController.editingMode = kDetailViewEditingMode_UPLOADWIFI;
			break;
			
		case 1:
			detailController.editingMode = kDetailViewEditingMode_USERNAME;
			break;
			
		case 2:
			detailController.editingMode = kDetailViewEditingMode_QUICKFOLLOW;
			break;
			
	}
	
	detailController.delegate = self;
	
	[self presentModalViewController:detailController animated:YES];
	[detailController release];
	
}

# pragma mark -
#pragma mark SettingsDetailController Delegate Methods
- (void)settingsDetailController:(SettingsDetailController *)controller didFinishWithSave:(BOOL)save {
	
	[self dismissModalViewControllerAnimated:YES];
	[table reloadData];
	
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
