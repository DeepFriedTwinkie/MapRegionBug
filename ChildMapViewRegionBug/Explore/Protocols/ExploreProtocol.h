//
//  ExploreProtocol.h
//  ExploreContainer
//
//  Created by Scott Atkinson on 2/5/16.
//  Copyright © 2016 Homesnap LLC. All rights reserved.
//

#ifndef ExploreProtocol_h
#define ExploreProtocol_h

@protocol ExploreDataViewControllerProtocol <NSObject>

@required

// ****** Actions ******
- (IBAction) gotoUserLocation:(id)sender;
- (IBAction) zoomOut:(id) sender;
- (IBAction) zoomIn:(id) sender;

- (IBAction) goToCustomSearch:(id) sender;

@end


@protocol ExploreMapController <NSObject>

@required

- (void) exploreMapControllerShouldDisableMap;
- (void) exploreMapControllerShouldEnableMap;

@end


@protocol ExploreMapDelegate <NSObject>

@required

- (BOOL) shouldExploreMapControllerDisableMapInteraction:(UIViewController *) mapController;
- (void) exploreMapControllerWantsToExpand:(UIViewController *) mapController;

@end


#endif /* ExploreProtocol_h */
