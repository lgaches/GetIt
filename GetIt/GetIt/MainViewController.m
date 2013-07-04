//
//  ViewController.m
//  GetIt
//
//  Created by Laurent Gaches on 7/21/12.
//  Copyright (c) 2012 GetIt. All rights reserved.
//

#import "MainViewController.h"
#import "DealDetailViewController.h"
#import "FilterViewController.h"
#import "MBProgressHUD.h"

@interface MainViewController ()

@end

@implementation MainViewController {
    NSURLConnection *connection;
    NSMutableData *jsonData;
    CLLocationManager *locationManager;
    CLLocation *userLocation;
    
    
    NSMutableArray *items;
    NSMutableArray *categories;
    NSMutableArray *filteredItems;
    NSString *currentCategory;
    
    UIImageView *splash;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    splash = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
    splash.frame = CGRectMake(0, 0, 320, 480);
    
    [self.view addSubview:splash];
    [MBProgressHUD showHUDAddedTo:splash animated:YES];
    
    if (nil == locationManager) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        
        [locationManager startUpdatingLocation];
    }
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - filter

-(void)filterCategoryWith:(NSString *)category {
    
    
    if([category isEqualToString:@"All"]) {
        filteredItems = nil;
        currentCategory = nil;
    } else {
        filteredItems = [[NSMutableArray alloc] init];
        currentCategory = category;
        
        for (NSDictionary *item in items) {
            if ([[[item objectForKey:@"deal"] objectForKey:@"category"] isEqualToString:category]) {
                [filteredItems addObject:item];
            }
        }
    }
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (filteredItems) {
        return [filteredItems count];
    } else {
        return [items count];
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (filteredItems && currentCategory) {
        return currentCategory;
    } else {
        return @"";
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DealCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    
    NSDictionary *item;
    if (filteredItems) {
        item = [filteredItems objectAtIndex:indexPath.row];
    } else {
        item = [items objectAtIndex:indexPath.row];
    }
    
    
    
    NSDictionary *deal = [item objectForKey:@"deal"];
    
    UILabel *textLabel = (UILabel *)[cell viewWithTag:2];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    UILabel *distanceLbl = (UILabel *)[cell viewWithTag:3];
    UILabel *cityLbl = (UILabel *)[cell viewWithTag:4];
    
    
    textLabel.font = [UIFont fontWithName:@"Futura-Medium" size:14.];
    textLabel.textColor = [UIColor greenColor];
    textLabel.text = [NSString stringWithFormat:@"%@",[deal objectForKey:@"title"]];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setMaximumFractionDigits:2];
    distanceLbl.text = [[numberFormatter stringFromNumber:[item objectForKey:@"distance"] ] stringByAppendingString: @" meters away"];
    
    NSURL *imageURL = [NSURL URLWithString:[deal objectForKey:@"image"]];
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:imageURL];
    imageView.image = nil;
    [NSURLConnection sendAsynchronousRequest:imageRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        UIImage *img = [UIImage imageWithData:data];
        [imageView setImage:img];
    }];
    
    
    cityLbl.text = [[item objectForKey: @"merchant"] objectForKey:@"city"];
    
    return cell;
}

- (void)sortItems:(NSMutableArray *)_items{
    NSLog(@"Lat %f", userLocation.coordinate.latitude);
    NSLog(@"Lon %f", userLocation.coordinate.longitude);
    
    for (NSMutableDictionary *d in _items) {
        NSDictionary *merch = [d objectForKey: @"merchant"];
        CLLocation *merchantLocation = [[CLLocation alloc] initWithLatitude:[[merch objectForKey:@"latitude"] floatValue] longitude:[[merch objectForKey:@"longitude"] floatValue]];
        
        CLLocationDistance distance =[userLocation distanceFromLocation:merchantLocation];
        
        [d setObject: [NSNumber numberWithFloat: distance] forKey:@"distance"];
    }
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"distance"  ascending:YES];
    
    [items sortUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];
}

- (void) getCategories: (NSArray *)_items{
    categories = [[NSMutableArray alloc] init];
    for (NSDictionary *d in _items) {
        id cat = [[d objectForKey:@"deal"] objectForKey:@"category"];
        if(![categories containsObject:cat]){
            [categories addObject:cat];
        }
    }
    NSLog(@"Categories\n%@", categories);
}
#pragma mark - Table view delegate



-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString: @"dealDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        DealDetailViewController *dest = [segue destinationViewController];
        
        if (filteredItems) {
            dest.item = [filteredItems objectAtIndex:indexPath.row];
        } else {
            dest.item = [items objectAtIndex:indexPath.row];
        }
        
    } else if ([[segue identifier] isEqualToString:@"dealFilter"]) {
        FilterViewController *dest = [segue destinationViewController];
        dest.categories = categories;
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    NSLog(@" lat :%f  long: %f",newLocation.coordinate.latitude,newLocation.coordinate.longitude);
    
    [locationManager stopUpdatingLocation];
    
    userLocation = newLocation;
    
    NSString *urlString = [NSString stringWithFormat:@"http://lesserthan.com/api.getDealsLatLon/json/?lat=%f&lon=%f",userLocation.coordinate.latitude,userLocation.coordinate.longitude];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    jsonData = [[NSMutableData alloc] init];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [jsonData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    items = [json objectForKey:@"items"];
    [self sortItems:items];
    [self getCategories:items];
    
    [self.tableView reloadData];
    
    
    [MBProgressHUD hideAllHUDsForView:splash animated:YES];
    [splash removeFromSuperview];
    
    jsonData = nil;
    connection = nil;
}



@end
