
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
@property NSString *currentProfileName;

@end

@implementation ActivityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentProfileName = [NSString stringWithFormat:@"%@ %@", self.currentProfile.firstName, self.currentProfile.lastName];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    for (PFGeoPoint *geoPoint in self.currentProfile.locations)
    {
        [self reverseGeocodeWithLatitude:geoPoint.latitude andLongitude:geoPoint.longitude withProfileName:[NSString stringWithFormat:@"%@'s wish list", self.currentProfileName]];
    }
    [self reverseGeocodeWithLatitude:self.currentProfile.currentLocation.latitude andLongitude:self.currentProfile.currentLocation.longitude withProfileName:[NSString stringWithFormat:@"%@'s location", self.currentProfileName]];
    for (Profile *profile in self.userProfiles)
    {
        for (PFGeoPoint *geoPoint in profile.locations)
        {
            [self reverseGeocodeWithLatitude:geoPoint.latitude andLongitude:geoPoint.longitude withProfileName:[NSString stringWithFormat:@"%@'s wish list", profile.firstName]];
        }
        if (profile.currentLocation)
        {
            [self reverseGeocodeWithLatitude:profile.currentLocation.latitude andLongitude:profile.currentLocation.longitude withProfileName:[NSString stringWithFormat:@"%@'s location", profile.firstName]];
        }
    }
}

- (void)reverseGeocodeWithLatitude:(double)latitude andLongitude:(double)longitude withProfileName:(NSString *)name
{
    CLGeocoder *geocoder = [CLGeocoder new];
    CLLocation *location = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, id error)
     {
         CLPlacemark *placemark = placemarks.firstObject;
         NSString *address = [NSString string];
         if (placemark.subAdministrativeArea)
         {
             address = [NSString stringWithFormat:@"%@,%@", placemark.subAdministrativeArea, placemark.ISOcountryCode];
         }
         else
         {
             address = [NSString stringWithFormat:@"%@,%@", placemark.administrativeArea, placemark.ISOcountryCode];
         }
         MKPointAnnotation *annotation = [MKPointAnnotation new];
         annotation.coordinate =  location.coordinate;
         annotation.title = address;
         annotation.subtitle = name;
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
                 NSString *address = [NSString string];
                 if (placemark.subAdministrativeArea)
                 {
                     address = [NSString stringWithFormat:@"%@,%@", placemark.subAdministrativeArea, placemark.ISOcountryCode];
                 }
                 else
                 {
                     address = [NSString stringWithFormat:@"%@,%@", placemark.administrativeArea, placemark.ISOcountryCode];
                 }
                 PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:tapPoint.latitude longitude:tapPoint.longitude];
                 self.currentProfile.locations = [self addObjectId:geoPoint inArray:self.currentProfile.locations];
                 [self.currentProfile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                     if (!error)
                     {
                         MKPointAnnotation *annotation = [MKPointAnnotation new];
                         annotation.coordinate = tapPoint;
                         annotation.title = address;
                         annotation.subtitle = [NSString stringWithFormat:@"%@'s wish list", self.currentProfileName];
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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Spot"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        [alert addAction:cancelAction];
        UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Delete"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action)
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
                                    }];
        [alert addAction:addAction];
        [self presentViewController:alert animated:YES completion:nil];
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation
                                                              reuseIdentifier:nil];
    pin.canShowCallout = YES;
    pin.image = nil;
    UIImageView *imageView = [UIImageView new];
    UIImageView *subImageView = [UIImageView new];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *buttonImage = [UIImage imageNamed:@"delete"];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    button.contentMode = UIViewContentModeScaleAspectFill;
    button.backgroundColor = [UIColor clearColor];
    button.frame = CGRectMake(0.0f, 0.0f, 25.0f, 25.0f);
    if ([annotation.subtitle containsString:self.currentProfileName])
    {
        if ([annotation.subtitle containsString:@"location"])
        {
            if (self.currentProfile.avatarData)
            {
                [self addPin:pin withProfileAvatar:imageView data:self.currentProfile.avatarData andMark:subImageView name:@"location" withColor:[UIColor redColor].CGColor];
            }
            else
            {
                [self addPin:pin withProfileAvatar:imageView data:nil andMark:subImageView name:@"location" withColor:[UIColor redColor].CGColor];
            }
        }
        else if ([annotation.subtitle containsString:@"wish"])
        {
            if (self.currentProfile.avatarData)
            {
                [self addPin:pin withProfileAvatar:imageView data:self.currentProfile.avatarData andMark:subImageView name:@"heart" withColor:[UIColor redColor].CGColor];
                pin.rightCalloutAccessoryView = button;
            }
            else
            {
                [self addPin:pin withProfileAvatar:imageView data:nil andMark:subImageView name:@"heart" withColor:[UIColor redColor].CGColor];
                pin.rightCalloutAccessoryView = button;
            }
        }
    }
    else
    {
        for (Profile *profile in self.userProfiles)
        {
            if ([annotation.subtitle containsString:@"location"])
            {
                if ([annotation.subtitle containsString:profile.firstName] && profile.avatarData)
                {
                    [self addPin:pin withProfileAvatar:imageView data:profile.avatarData andMark:subImageView name:@"location" withColor:[UIColor blackColor].CGColor];
                }
                else
                {
                    [self addPin:pin withProfileAvatar:imageView data:nil andMark:subImageView name:@"location" withColor:[UIColor blackColor].CGColor];
                }
            }
            else if ([annotation.subtitle containsString:@"wish"])
            {
                if ([annotation.subtitle containsString:profile.firstName] && profile.avatarData)
                {
                    [self addPin:pin withProfileAvatar:imageView data:profile.avatarData andMark:subImageView name:@"heart" withColor:[UIColor redColor].CGColor];
                }
                else
                {
                    [self addPin:pin withProfileAvatar:imageView data:nil andMark:subImageView name:@"heart" withColor:[UIColor redColor].CGColor];
                }
            }
        }
    }
    return pin;
}

- (void) addPin:(MKPinAnnotationView *)pin withProfileAvatar:(UIImageView *)imageView data:(NSData *)data andMark:(UIImageView *)subImageView name:(NSString *)name withColor:(CGColorRef)color
{
    [self setImageView:imageView withData:data withBorderWidth:1.0f withBorderColor:color];
    [pin addSubview:imageView];
    [self setImageView:subImageView withName:name];
    [pin addSubview:subImageView];
}


- (void)setImageView:(UIImageView *)imageView withData:(NSData *)data withBorderWidth:(CGFloat)width withBorderColor:(CGColorRef)color
{
    if (data)
    {
        UIImage *image = [UIImage imageWithData:data];
        imageView.image = image;
    }
    imageView.backgroundColor = [UIColor whiteColor];
    imageView.frame = CGRectMake(-12.0f, 0.0f, 40.0f, 40.0f);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [imageView.layer setCornerRadius:20.0f];
    [imageView setClipsToBounds:YES];
    [imageView.layer setBorderWidth:width];
    [imageView.layer setBorderColor:color];
}

- (void)setImageView:(UIImageView *)imageView withName:(NSString *)name
{
    imageView.image = [UIImage imageNamed:name];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.frame = CGRectMake(17.5f, 27.5f, 12.5f, 12.5f);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
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
