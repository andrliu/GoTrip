
//
//  ActivityViewController.m
//  GoTrip
//
//  Created by Andrew Liu on 11/23/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "ActivityViewController.h"
@import MapKit;
@import CoreLocation;

@interface ActivityViewController () <MKMapViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation ActivityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    for (PFGeoPoint *geoPoint in self.currentProfile.locations)
    {
        [self reverseGeocodeWithLatitude:geoPoint.latitude andLongitude:geoPoint.longitude];
    }
}

- (void)reverseGeocodeWithLatitude:(double)latitude andLongitude:(double)longitude
{
    CLGeocoder *geocoder = [CLGeocoder new];
    CLLocation *location = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, id error)
     {
         CLPlacemark *placemark = placemarks.firstObject;
         NSString *address = [NSString stringWithFormat:@"%@:%@", placemark.subAdministrativeArea, placemark.administrativeArea];
         MKPointAnnotation *annotation = [MKPointAnnotation new];
         annotation.coordinate =  location.coordinate;
         annotation.title = address;
         annotation.subtitle = [NSString stringWithFormat:@"%@ %@", self.currentProfile.firstName, self.currentProfile.lastName];
         [self.mapView addAnnotation:annotation];
     }];
}

- (IBAction)longPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [sender locationInView:self.mapView];
        CLLocationCoordinate2D tapPoint = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
        CLGeocoder *geocoder = [CLGeocoder new];
        CLLocation *location = [[CLLocation alloc]initWithLatitude:tapPoint.latitude longitude:tapPoint.longitude];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, id error)
         {
             if (!error)
             {
                 CLPlacemark *placemark = placemarks.firstObject;
                 NSString *address = [NSString stringWithFormat:@"%@:%@", placemark.subAdministrativeArea, placemark.administrativeArea];
                 PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:tapPoint.latitude longitude:tapPoint.longitude];
                 self.currentProfile.locations = [self addObjectId:geoPoint inArray:self.currentProfile.locations];
                 [self.currentProfile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                     if (!error)
                     {
                         MKPointAnnotation *annotation = [MKPointAnnotation new];
                         annotation.coordinate = tapPoint;
                         annotation.title = address;
                         annotation.subtitle = [NSString stringWithFormat:@"%@ %@", self.currentProfile.firstName, self.currentProfile.lastName];
                         [self.mapView addAnnotation:annotation];
                     }
                     else
                     {
                         [self error:error];
                     }
                 }];
             }
            else
            {
                [self error:error];
            }
        }];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    CLLocationCoordinate2D coord = [view.annotation coordinate];
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:coord.latitude longitude:coord.longitude];
    self.currentProfile.locations = [self removeObjectId:geoPoint inArray:self.currentProfile.locations];
    [self.currentProfile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (!error)
         {
             [self.mapView removeAnnotation:view.annotation];
         }
         else
         {
             [self error:error];
         }
     }];
}

- (NSArray *)addObjectId:(PFGeoPoint *)Object inArray:(NSArray *)array
{
    if (array.count == 0)
    {
        return @[Object];
    }
    else
    {
        NSMutableArray *arrayOfLocations = [array mutableCopy];
        [arrayOfLocations addObject:Object];
        return arrayOfLocations;
    }
}

- (NSArray *)removeObjectId:(PFGeoPoint *)Object inArray:(NSArray *)array
{
    NSMutableArray *arrayOfLocations = [array mutableCopy];
    NSMutableArray *arrayOfLocationsToRemove = [NSMutableArray array];
    for (PFGeoPoint *geoPoint in arrayOfLocations)
    {
        if (geoPoint.latitude == Object.latitude && geoPoint.longitude == Object.longitude)
        {
            [arrayOfLocationsToRemove addObject:geoPoint];
        }
    }
    [arrayOfLocations removeObjectsInArray:arrayOfLocationsToRemove];
    return arrayOfLocations;
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation
                                                              reuseIdentifier:nil];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    NSString *name = [NSString stringWithFormat:@"%@ %@", self.currentProfile.firstName, self.currentProfile.lastName];
    if ([annotation.subtitle isEqual:name])
    {
        pin.pinColor = MKPinAnnotationColorRed;
    }
    else
    {
        pin.pinColor = MKPinAnnotationColorGreen;
    }
    return pin;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *address = searchBar.text;
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!error)
         {
             for (CLPlacemark *placemark in placemarks)
             {
                 CLLocationCoordinate2D center = placemark.location.coordinate;
                 MKCoordinateSpan coordinateSpan;
                 coordinateSpan.latitudeDelta = 1;
                 coordinateSpan.longitudeDelta = 1;
                 MKCoordinateRegion region = MKCoordinateRegionMake(center, coordinateSpan);
                 [self.mapView setRegion:region animated:YES];
                 [self.view endEditing:YES];
                 searchBar.text = @"";
             }
         }
         else
         {
             [self error:error];
         }
     }
     ];
}

//MARK: UIAlert
- (void)error:(NSError *)error
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
