//
//  ExploreCollectionViewController_NoChild.m
//  ChildMapViewRegionBug
//
//  Created by Scott Atkinson on 4/11/16.
//  Copyright © 2016 Homesnap LLC. All rights reserved.
//

#import "ExploreCollectionViewController_NoChild.h"

@import MapKit;

// ****** Services ******
#import "ExploreProtocol.h"

// ****** Categories ******
#import "UIViewController+SearchField.h"

#define UIColorFromRGB(rgbValue) ([UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0])

@interface ExploreCollectionViewController_NoChild () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate, ExploreMapDelegate, MKMapViewDelegate> {
    BOOL _isMapChangingSize;
    BOOL _isMapExpanded;
    BOOL _mapIsBeingMoved;
}

@property (strong, nonatomic) IBOutlet UIView *exploreMapContainerView;

@property (nonatomic, weak) IBOutlet UICollectionView * collectionView;

// ****** Buttons & Gestures ******
@property (strong, nonatomic) IBOutlet UIButton *expandContractButton;
@property (weak, nonatomic) IBOutlet UIButton *gotoUserLocationButton;

@property (strong, nonatomic) IBOutlet UIGestureRecognizer * mapTapGesture;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer * mapSwipeGesture;
@property (strong, nonatomic) IBOutlet UIPinchGestureRecognizer * mapPinchGesture;

// ****** Search ******
@property (strong, nonatomic) UITextField * searchField;
@property (strong, nonatomic) UIBarButtonItem * searchCancelButton;
@property (strong, nonatomic) UIBarButtonItem * initialRightBarButton;


@property (weak, nonatomic) IBOutlet MKMapView * mapview;
@property (nonatomic, strong) MKPolygon * lastRegionPolygon;

@end

@implementation ExploreCollectionViewController_NoChild

- (void) viewDidLoad {
    [super viewDidLoad];
    
    _isMapChangingSize = NO;
    _isMapExpanded = NO;
    
    // *** Collection View
    self.collectionView.scrollsToTop = YES;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    
    // *** Buttons
    [self.gotoUserLocationButton setImage:[[self.gotoUserLocationButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.gotoUserLocationButton setTintColor:[UIColor blueColor]];
    
    [self.expandContractButton setImage:[[self.expandContractButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.expandContractButton setTintColor:[UIColor blueColor]];
    self.expandContractButton.hidden = !_isMapExpanded;
    
    // *** Gestures
    self.mapSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft + UISwipeGestureRecognizerDirectionRight;
    
    // *** Navigation Bar
    self.searchField = [self createSearchFieldWithPlaceholderText:@"enter a search here"];
    self.navigationItem.titleView = self.searchField;
    [self.navigationController.navigationBar layoutIfNeeded];
    
    CGRect searchFieldFrame = self.searchField.frame;
    searchFieldFrame.size.height = 24.0;
    searchFieldFrame.size.width = self.view.frame.size.width;
    self.searchField.frame = searchFieldFrame;
    
    self.searchCancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(hideSearch:)];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionView.collectionViewLayout invalidateLayout];
}


- (IBAction) gotoUserLocation:(id)sender {
    NSLog(@"gotoUserLocation Tapped");
}

- (IBAction) zoomOut:(id)sender {
    NSLog(@"zoomOut Tapped");
}

- (IBAction) zoomIn:(id)sender {
    NSLog(@"zoomIn Tapped");
}

- (IBAction) goToCustomSearch:(id)sender {
    NSLog(@"Custom Search Tapped");
}

- (IBAction) showSearch:(id)sender {
    NSLog(@"showSearch Search Tapped");
}

- (IBAction) hideSearch:(id)sender {
    [self hideSearch:YES completion:nil];
}

- (void) hideSearch:(BOOL)animated completion:(void (^)(void)) completion {
    NSLog(@"hideSearch Search Tapped");
}

// ******************** Actions ********************
#pragma mark - Actions

- (IBAction)expandContractMapTapped:(id)sender {
    if (_isMapChangingSize) {
        return;
    }
    
    _isMapChangingSize = YES;
    _isMapExpanded = !_isMapExpanded;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.collectionView performBatchUpdates:^{
            
            [self.collectionView.collectionViewLayout invalidateLayout];
            [self scrollToTop:NO];
            
        } completion:^(BOOL finished) {
            
            if (finished) {
                _isMapChangingSize = NO;
                
                self.collectionView.scrollEnabled = !_isMapExpanded;
                self.expandContractButton.hidden = !_isMapExpanded;
                
//                if (_isMapExpanded) {
//                    [self.mapViewController exploreMapControllerShouldEnableMap];
//                } else {
//                    [self.mapViewController exploreMapControllerShouldDisableMap];
//                }
                
                self.mapTapGesture.enabled = !_isMapExpanded;
                self.mapSwipeGesture.enabled = !_isMapExpanded;
                self.mapPinchGesture.enabled = !_isMapExpanded;
            }
        }];
    }];
}

- (void) scrollToTop:(BOOL) animated {
    [self.collectionView setContentOffset:CGPointMake(0, -self.collectionView.contentInset.top)];
}


// ******************** UICollectionViewDataSource ********************
#pragma mark <UICollectionViewDataSource>

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView
            viewForSupplementaryElementOfKind:(NSString *)kind
                                  atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader] && indexPath.section == 0) {
        
        UICollectionReusableView * header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"MapHeader" forIndexPath:indexPath];
        
        if (self.exploreMapContainerView.superview != header) {
            
            self.exploreMapContainerView = header.subviews.firstObject;
            self.mapview = self.exploreMapContainerView.subviews.firstObject;
            
            self.exploreMapContainerView.translatesAutoresizingMaskIntoConstraints = NO;
            [header addSubview:self.exploreMapContainerView];
            
            // Pin the map view controller to all sides of the header
            NSMutableArray * constraints = [NSMutableArray array];
            NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(header,
                                                                           _exploreMapContainerView,
                                                                           _expandContractButton,
                                                                           _gotoUserLocationButton
                                                                           );
            
            // ****** Map Placement
            if (SYSTEM_VERSION_LESS_THAN(@"8")) {
                // In iOS 7, constraints between cell subviews and the collection view are ignored.
                // Instead, simply constrain the map container to the bounds of the header cell
                // This will result in the map changing size when it's expaneded - oh well
                [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_exploreMapContainerView]-0-|"
                                                                                         options:0 metrics:nil views:viewsDictionary]];
            } else {
#warning ****** iOS 8 Compatibility
                /* iOS 9 adds the header to the collection view immediately. (Even when a new view is created)
                 Since the header is not yet in the collection view in iOS 7/8, a constraint cannot be added between the header and the view controller's view
                 This is a hack to allow the constraint to be added
                 */
                if (header.superview != collectionView) {
                    [collectionView addSubview:header];
                }
                
                // Ensure the size of the map view controller does not change when header is expanded/contracted
                // So set the container size to the size of the collection view (and adjust for the layout guides)
                [collectionView addConstraint:[NSLayoutConstraint constraintWithItem:collectionView
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.exploreMapContainerView
                                                                           attribute:NSLayoutAttributeHeight
                                                                          multiplier:1.f
//                                                                            constant:0]];
                                                                            constant:(self.topLayoutGuide.length + self.bottomLayoutGuide.length)]];
            }
            
            // Make sure the map is not placed on top of other buttons
            [header sendSubviewToBack:self.exploreMapContainerView];
            
            
            // ****** Add the expand/contract button
            [header addSubview:self.expandContractButton];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_expandContractButton]-15-|"
                                                                                     options:0 metrics:nil views:viewsDictionary]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_expandContractButton]-15-|"
                                                                                     options:0 metrics:nil views:viewsDictionary]];
            
            
            
            // ****** Add the Goto User Location Button
            [header addSubview:self.gotoUserLocationButton];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_gotoUserLocationButton]"
                                                                                     options:0 metrics:nil views:viewsDictionary]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_gotoUserLocationButton]-15-|"
                                                                                     options:0 metrics:nil views:viewsDictionary]];
            
            // ****** Add all the constraints
            [header addConstraints:constraints];
        }
        return header;
    }
    return nil;
}


- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 25;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    return cell;
}


// ******************** UICollectionViewDelegateFlowLayout ********************
#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        CGSize size = self.collectionView.bounds.size;
        size.height = _isMapExpanded ? size.height-(self.topLayoutGuide.length + self.bottomLayoutGuide.length) : 200.0;
        return size;
    }
    return CGSizeZero;
}


// ******************** ExploreMapDelegate ********************
#pragma mark - ExploreMapDelegate

- (BOOL) shouldExploreMapControllerDisableMapInteraction:(UIViewController *)mapController {
    return !_isMapExpanded;
}

- (void) exploreMapControllerWantsToExpand:(UIViewController *)mapController {
    if (!_isMapExpanded) {
        [self expandContractMapTapped:mapController];
    }
}

// ******************** MKMapViewDelegate ********************
#pragma mark - MKMapViewDelegate

// ****** Movement ******
- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    if (_mapIsBeingMoved) return;
    
    [self.mapview removeOverlay:self.lastRegionPolygon];
    [self addRegion:mapView.region];
    
    [self logMapInfo];
}

// ****** Views & Overlays ******
- (MKOverlayRenderer *) mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    // Area Polygon, fill it with gray
    if ([overlay isKindOfClass:[MKPolygon class]]) {
        MKPolygonRenderer * renderer = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon *) overlay];
        renderer.fillColor = [UIColorFromRGB(0x222222) colorWithAlphaComponent:0.1];
        renderer.strokeColor = [UIColor greenColor];
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

- (void) logMapInfo {
    CGSize viewSize = self.mapview.frame.size;
    MKMapSize mapRectSize = self.mapview.visibleMapRect.size;
    
    CGFloat viewRatio = viewSize.width / viewSize.height;
    CGFloat rectRatio = mapRectSize.width / mapRectSize.height;
    
    NSLog(@"\n----------------------------------\n%@ Region Changed\nView Aspect: %f\nVisible Map Rect Aspect: %f\n\n\n",
          @"Subview",
          viewRatio,
          rectRatio);
}

@end
