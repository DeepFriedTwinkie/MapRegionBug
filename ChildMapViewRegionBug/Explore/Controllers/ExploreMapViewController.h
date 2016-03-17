//
//  ExploreMapViewController.h
//  ExploreContainer
//
//  Created by Scott Atkinson on 2/4/16.
//

@import UIKit;
@import MapKit;

#import "ExploreProtocol.h"

@class ExploreManager;
@class ExploreActionController;

@interface ExploreMapViewController : UIViewController <ExploreDataViewControllerProtocol, ExploreMapController>

@property (weak, nonatomic) IBOutlet id<ExploreMapDelegate> exploreMapDelegate;

@end
