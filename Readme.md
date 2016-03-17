Problem
====

In the current implementation of my app, the map view reports an incorrect region and visibleMapRect when contained as a child view controller in the header of a collection view. In essence, it is removing the top 64 screen points. When the map view controller is not contained in the collection view, the region and visible map rect is reported correctly. 

Examples
====

I have created a sample app that demonstrates this by adding an MKPolygon to the map view representing the map's region. The app has two tabs:
- A map view in a collection view that behaves incorrectly
- The same map view not in a collection view that behaves correctly.

I've also created a video that demostrates the issue: [RegionIssues.mov](https://github.com/DeepFriedTwinkie/MapRegionBug/blob/master/RegionIssues.mov?raw=true)

Steps to Reproduce
====

1. Run the sample app.
2. In the "In Collection" tab, tap the map to expand it.
3. Move the map around and notice that the gray overlay (representing the current map region) does not fill the view.
4. Tap the "Alone" tab.
5. Move the map around and notice that the gray overlay properly fills the screen.

General Architecture
====

In the current implementation, the map view is contained and managed by it's own view controller. That view controller is added as a child view controller inside of a container view. At runtime, the container view is added to a header view of the collection view controller contained in the parent view controller. 

**View Controller Hierarchy**

- `UITabBarController`
    - `UINavigationController`
        - `ExploreCollectionViewController : UIViewController` (Contains the UICollectionView)
	      - `ExploreMapViewController : UIViewController` (Contains the MKMapView)
	  
**Pertinent View Hierarchy**

- `UIView` - ExploreCollectionViewController.view
    - `UICollectionView` - ExploreCollectionViewController.collectionView
        - `UICollectionReusableView` - UICollectionElementKindSectionHeader - Created in code
	        - `UIView` - Container view created in Storyboard, added to header in `collectionView:viewForSupplementaryElementOfKind:atIndexPath:`
	            - `UIView` - ExploreMapViewController.view - Created in storyboard
		            - `MKMapView` - ExploreMapViewController.mapView - Created in storyboard

**Auto Layout**

Additionally, there are two requirements that forced me to add some unique autolayout constraints:

- The map header can be expanded to fill the whole screen. When that happens, the region should not change (I don't want to trigger a network call)
- As the map header expands, I want the map view's center to remain in the center of the header so that the animation is smooth.

To accomplish this, I add a couple constraints in `collectionView:viewForSupplementaryElementOfKind:atIndexPath:`

- leading and trailing contraints between the header and the container. (The container always fills the width of the header)
- centerY constraint between the header and the container (For the smooth animation)
- equal height constraint between the container and the collection view; minus the top and bottom layout guides (This forces the container view and subsequently the ExploreMapViewController's view hierarchy to always be a constant height, thereby preventing region changes)

