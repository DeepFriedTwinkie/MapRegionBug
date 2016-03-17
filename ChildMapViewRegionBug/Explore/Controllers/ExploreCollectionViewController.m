//
//  ExploreCollectionViewController.m
//  ExploreContainer
//
//  Created by Scott Atkinson on 2/5/16.
//

#import "ExploreCollectionViewController.h"

// ****** Controllers ******
#import "ExploreMapViewController.h"

// ****** Services ******
#import "ExploreProtocol.h"

// ****** Categories ******
#import "UIViewController+SearchField.h"

@import MapKit;


@interface ExploreCollectionViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate, ExploreMapDelegate> {
    BOOL _isMapChangingSize;
    BOOL _isMapExpanded;
}

@property (strong, nonatomic) IBOutlet UIView *exploreMapContainerView;
@property (strong, nonatomic) ExploreMapViewController * mapViewController;

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

@end

@implementation ExploreCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

// ******************** Lifecycle ********************
#pragma mark - Lifecycle

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
    [self.mapViewController gotoUserLocation:sender];
}

- (IBAction) zoomOut:(id)sender {
    [self.mapViewController zoomOut:sender];
}

- (IBAction) zoomIn:(id)sender {
    [self.mapViewController zoomIn:sender];
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
                
                if (_isMapExpanded) {
                    [self.mapViewController exploreMapControllerShouldEnableMap];
                } else {
                    [self.mapViewController exploreMapControllerShouldDisableMap];
                }
                
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


// ******************** Navigation ********************
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EmbedMapController"]) {
        self.mapViewController = (ExploreMapViewController *) segue.destinationViewController;
        self.mapViewController.exploreMapDelegate = self;
        return;
    }
    
    [super prepareForSegue:segue sender:sender];
}


// ******************** UICollectionViewDataSource ********************
#pragma mark <UICollectionViewDataSource>

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView
            viewForSupplementaryElementOfKind:(NSString *)kind
                                  atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader] && indexPath.section == 0) {
        
        UICollectionReusableView * header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"MapHeader" forIndexPath:indexPath];
        
        if (self.exploreMapContainerView.superview != header) {

            self.exploreMapContainerView.translatesAutoresizingMaskIntoConstraints = NO;
            [header addSubview:self.exploreMapContainerView];
            
            // Pin the map view controller to all sides of the header
            NSMutableArray * constraints = [NSMutableArray array];
            NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(header,
                                                                           _exploreMapContainerView,
                                                                           _expandContractButton,
                                                                           _gotoUserLocationButton
                                                                           );
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_exploreMapContainerView]-0-|"
                                                                                     options:0 metrics:nil views:viewsDictionary]];
            [constraints addObject:[NSLayoutConstraint constraintWithItem:self.exploreMapContainerView
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:header
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.f constant:0.f]];

            // Make sure the map is not placed on top of other buttons
            [header sendSubviewToBack:self.exploreMapContainerView];
            
            // Add the expand/contract button
            [header addSubview:self.expandContractButton];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_expandContractButton]-15-|"
                                                                                     options:0 metrics:nil views:viewsDictionary]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_expandContractButton]-15-|"
                                                                                     options:0 metrics:nil views:viewsDictionary]];

            // Add the Goto User Location Button
            [header addSubview:self.gotoUserLocationButton];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_gotoUserLocationButton]"
                                                                                     options:0 metrics:nil views:viewsDictionary]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_gotoUserLocationButton]-15-|"
                                                                                     options:0 metrics:nil views:viewsDictionary]];

            [header addConstraints:constraints];
            
#warning ****** iOS 7/8 Compatibility
            /* iOS 9 adds the header to the collection view immediately. (Even when a new view is created)
             Since the header is not yet in the collection view in iOS 7/8, a constraint cannot be added between the header and the view controller's view
             This is a hack to allow the constraint to be added
             */
            if (header.superview != collectionView) {
                [collectionView addSubview:header];
            }
            
            // Ensure the size of the map view controller does not change when header is expanded/contracted
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:collectionView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.exploreMapContainerView
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:1.f
                                                                   constant:(self.topLayoutGuide.length + self.bottomLayoutGuide.length)]];
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


@end
