//
//  MapViewController.m
//  GetIt
//
//  Created by Laurent Gaches on 7/22/12.
//  Copyright (c) 2012 GetIt. All rights reserved.
//

#import "MapViewController.h"
#import "DealPlaceMark.h"

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize item;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	// Do any additional setup after loading the view.
    NSDictionary *merchant = [item objectForKey:@"merchant"];
    double latitude = [[merchant objectForKey:@"latitude"] doubleValue];
    double longitude = [[merchant objectForKey:@"longitude"] doubleValue];
    
    CLLocationCoordinate2D coordinate = {latitude,longitude};
    DealPlaceMark *placeMark = [[DealPlaceMark alloc] initWithCoordinate:coordinate];
    placeMark.title = [[item objectForKey:@"deal"] objectForKey:@"title"];
    placeMark.subtitle = [merchant objectForKey:@"name"];
    [mapView addAnnotation:placeMark];
    
    MKCoordinateRegion region;
    region.center = placeMark.coordinate;
    
    MKCoordinateSpan span;
    span.latitudeDelta = 0.030;
    span.longitudeDelta = 0.030;
    
    region.span = span;
    
    [mapView setRegion:region animated:YES];
    
    
}

- (void)viewDidUnload
{
    mapView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)openInMaps:(id)sender {
    Class itemClass = [MKMapItem class];
    if (itemClass && [itemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
        NSDictionary *merchant = [item objectForKey:@"merchant"];
        double latitude = [[merchant objectForKey:@"latitude"] doubleValue];
        double longitude = [[merchant objectForKey:@"longitude"] doubleValue];
        
        CLLocationCoordinate2D coordinate = {latitude,longitude};
        
        MKPlacemark *merchantPlacemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
        MKMapItem *merchantItem = [[MKMapItem alloc] initWithPlacemark:merchantPlacemark];
        
        NSDictionary *launchOptions = @{MKLaunchOptionsMapTypeKey : [NSNumber numberWithInt:MKMapTypeStandard], MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving};
        
        [MKMapItem openMapsWithItems:@[merchantItem] launchOptions:launchOptions];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Non supporté" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    
}

#pragma mark - MKMapViewDelegate

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[DealPlaceMark class]]) {
        MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"deal"];
        
        [annotationView setCanShowCallout:YES];
        
        UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        [annotationView setRightCalloutAccessoryView:disclosureButton];
      
        return annotationView;
    }
    
    return  nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    NSLog(@"test");
}


@end
