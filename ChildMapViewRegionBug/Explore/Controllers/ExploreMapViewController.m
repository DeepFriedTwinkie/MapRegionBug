//
//  ExploreMapViewController.m
//  ExploreContainer
//
//  Created by Scott Atkinson on 2/4/16.
//  Copyright © 2016 Homesnap LLC. All rights reserved.
//

#import "ExploreMapViewController.h"

#define UIColorFromRGB(rgbValue) ([UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0])

@interface ExploreMapViewController () <MKMapViewDelegate> {
    BOOL _mapIsBeingMoved;
}

// ****** UI ******
@property (weak, nonatomic) IBOutlet MKMapView * mapview;
@property (weak, nonatomic) IBOutlet UIButton *expandContractButton;
@property (weak, nonatomic) IBOutlet UIButton *gotoUserLocationButton;

@property (nonatomic, strong) MKPolygon * lastRegionPolygon;

@end

@implementation ExploreMapViewController


// ******************** Lifecycle ********************
#pragma mark - Lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];

    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(38.959926, -77.082465),
                                                       MKCoordinateSpanMake(0.2, 0.2));
    [self.mapview setRegion:region animated:NO];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    BOOL disableMap = [self.exploreMapDelegate shouldExploreMapControllerDisableMapInteraction:self];
    if (disableMap) {
        [self exploreMapControllerShouldDisableMap];
    } else {
        [self exploreMapControllerShouldEnableMap];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}


// ******************** Properties ********************
#pragma mark - Properties

- (IBAction) gotoUserLocation:(id)sender {
    NSLog(@"Map goToUserLocation Tapped");
}

- (IBAction) zoomOut:(id)sender {
    NSLog(@"Map zoomOut Tapped");
}

- (IBAction) zoomIn:(id)sender {
    NSLog(@"Map zoomIn Tapped");
}

- (IBAction) goToCustomSearch:(id) sender {
    NSLog(@"Map goToCustomSearch Tapped");
}


// ******************** Overlays ********************
#pragma mark - Overlays

- (void) removeOverlays {
    [self.mapview removeOverlays:self.mapview.overlays];
}


// ******************** ExploreMapController ********************
#pragma mark - ExploreMapController

- (void) exploreMapControllerShouldDisableMap {
    self.mapview.scrollEnabled = NO;
    self.mapview.zoomEnabled = NO;
}

- (void) exploreMapControllerShouldEnableMap {
    self.mapview.scrollEnabled = YES;
    self.mapview.zoomEnabled = YES;
}


// ******************** MKMapViewDelegate ********************
#pragma mark - MKMapViewDelegate

// ****** Movement ******
- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {

    if (_mapIsBeingMoved) return;

    [self.mapview removeOverlay:self.lastRegionPolygon];
    [self addRegion:mapView.region];
}

// ****** Views & Overlays ******
- (MKOverlayRenderer *) mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    // Area Polygon, fill it with gray
    if ([overlay isKindOfClass:[MKPolygon class]]) {
        MKPolygonRenderer * renderer = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon *) overlay];
        renderer.fillColor = [UIColorFromRGB(0x222222) colorWithAlphaComponent:0.1];
        renderer.strokeColor = [UIColorFromRGB(0x111111) colorWithAlphaComponent:0.35];
        renderer.lineWidth = 2;
        return renderer;
    }
    return nil;
}

- (void) addRegion:(MKCoordinateRegion) region {
    // Create a C array of size 4
    CLLocationCoordinate2D  points[4];
    CLLocationDegrees north, south, east, west;
    
    north = MIN(region.center.latitude + (region.span.latitudeDelta/2.0), 90.0);
    south = MAX(region.center.latitude - (region.span.latitudeDelta/2.0), -90.0);
    
    west = region.center.longitude - (region.span.longitudeDelta/2.0);
    if (west < -180.0) {
        west += 360.0;
    }
    
    east = region.center.longitude + (region.span.longitudeDelta/2.0);
    if (east > 180.0) {
        west -= 360.0;
    }

    //Fill the array with the four corners (center - radius in each of four directions)
    points[0] = CLLocationCoordinate2DMake(north, west);
    points[1] = CLLocationCoordinate2DMake(north, east);
    points[2] = CLLocationCoordinate2DMake(south, east);
    points[3] = CLLocationCoordinate2DMake(south, west);
    
    //Create the polygon
    self.lastRegionPolygon = [MKPolygon polygonWithCoordinates:points count:4];
    self.lastRegionPolygon.title = @"Previous Region";
    
    // Add it to the map
    [self.mapview addOverlay:self.lastRegionPolygon];
}

@end
