Purpose
--------------

SwipeView is a class designed to simplify the implementation of horizontal, paged scrolling views on iOS. It is based on a UIScrollView, but adds convenient functionality such as a UITableView-style dataSource/delegate interface for loading views dynamically, and efficient view loading, unloading and recycling.

SwipeView's interface and implementation is based on the iCarousel library, and should be familiar to anyone who has used iCarousel.


Supported OS & SDK Versions
-----------------------------

* Supported build target - iOS 7.0 (Xcode 5.0, Apple LLVM compiler 5.0)
* Earliest supported deployment target - iOS 5.0
* Earliest compatible deployment target - iOS 4.3

NOTE: 'Supported' means that the library has been tested with this version. 'Compatible' means that the library should work on this OS version (i.e. it doesn't rely on any unavailable SDK features) but is no longer being tested for compatibility and may require tweaking or bug fixes to run correctly.


ARC Compatibility
------------------

As of version 1.3, SwipeView requires ARC. If you wish to use SwipeView in a non-ARC project, just add the -fobjc-arc compiler flag to the SwipeView.m class. To do this, go to the Build Phases tab in your target settings, open the Compile Sources group, double-click SwipeView.m in the list and type -fobjc-arc into the popover.

If you wish to convert your whole project to ARC, comment out the #error line in SwipeView.m, then run the Edit > Refactor > Convert to Objective-C ARC... tool in Xcode and make sure all files that you wish to use ARC for (including SwipeView.m) are checked.


Thread Safety
--------------

SwipeView is derived from UIView and - as with all UIKit components - it should only be accessed from the main thread. You may wish to use threads for loading or updating SwipeView contents or items, but always ensure that once your content has loaded, you switch back to the main thread before updating the SwipeView.


Installation
--------------

To use the SwipeView class in an app, just drag the SwipeView class files (demo files and assets are not needed) into your project.


Properties
--------------

The SwipeView has the following properties:

	@property (nonatomic, weak) IBOutlet id<SwipeViewDataSource> dataSource;

An object that supports the SwipeViewDataSource protocol and can provide views to populate the SwipeView.

	@property (nonatomic, weak) IBOutlet id<SwipeViewDelegate> delegate;

An object that supports the SwipeViewDelegate protocol and can respond to SwipeView events and layout requests.

    @property (nonatomic, readonly) NSInteger numberOfItems;
    
The number of items in the SwipeView (read only). To set this, implement the `numberOfItemsInSwipeView:` dataSource method. Note that not all of these item views will be loaded or visible at a given point in time - the SwipeView loads item views on demand as it scrolls.

    @property (nonatomic, readonly) NSInteger numberOfPages;

The number of pages in the SwipeView (read only). To set this, implement the `numberOfItemsInSwipeView:` dataSource method and set the `itemsPerPage` value. If `itemsPerPage` = 1, numberOfPages will match the `numberOfItems`.

    @property (nonatomic, readonly) CGSize itemSize;
    
The size of each item in the SwipeView. This property is read-only, but can be set using the `swipeViewItemSize:` delegate method.

    @property (nonatomic, assign) NSInteger itemsPerPage;
    
The number of items per page when paging is enabled. Defaults to one;

    @property (nonatomic, assign) BOOL truncateFinalPage;

If the number of items is not exactly divisible by the itemsPerPage value then it can result in blank space on the last page. By setting truncateFinalPage to YES, you can eliminate that space.

    @property (nonatomic, strong, readonly) NSArray *indexesForVisibleItems;
	
An array containing the indexes of all item views currently loaded and visible in the SwipeView. The array contains NSNumber objects whose integer values match the indexes of the views. The indexes for item views start at zero and match the indexes passed to the dataSource to load the view.

	@property (nonatomic, strong, readonly) NSArray *visibleItemViews;

An array of all the item views currently displayed in the SwipeView (read only). The indexes of views in this array do not match the item indexes, however the order of these views matches the order of the visibleItemIndexes array property, i.e. you can get the item index of a given view in this array by retrieving the equivalent object from the visibleItemIndexes array (or, you can just use the `indexOfItemView:` method, which is much easier).

    @property (nonatomic, strong, readonly) UIView *currentItemView;
    
The first item view of the currently centered (or left-aligned, depending on the alignment value) page.
    
    @property (nonatomic, readonly) NSInteger currentItemIndex;
    
The index of the first item of the currently centered (or left-aligned, depending on the alignment value) page. Setting this value is equivalent to calling `scrollToItemAtIndex:duration:` with the duration argument set to 0.0.

    @property (nonatomic, assign) NSInteger currentPage;

The index of the currently centered (or left-aligned, depending on the alignment value) page. If `itemsPerPage` is equal to one, this value will match the currentItemIndex value. Setting this value is value is equivalent to calling `scrollToPage:duration:` with the duration argument set to 0.0.

    @property (nonatomic, assign) SwipeViewAlignment alignment;
    
This property controls how the SwipeView items are aligned. The default value of `SwipeViewAlignmentEdge` means that the item views will extend to the edges of the SwipeView. Switching the alignment to `SwipeViewAlignmentCenter` means that the leftmost and rightmost item views will be centered when the SwipeView is fully scrolled to either extreme.
    
    @property (nonatomic, assign, getter = isPagingEnabled) BOOL pagingEnabled;
    
Enables and disables paging. When paging is enabled, the SwipeView will stop at each item view as the user scrolls.
    
    @property (nonatomic, assign, getter = isScrollEnabled) BOOL scrollEnabled;

Enables and disables user scrolling of the SwipeView. The SwipeView can still be scrolled programmatically if this property is set to NO.

    @property (nonatomic, assign, getter = isWrapEnabled) BOOL wrapEnabled;

Enables and disables wrapping. When in wrapped mode, the SwipeView can be scrolled indefinitely and will wrap around to the first item view when it reaches past the last item. When wrap is enabled, the bounces property has no effect.

    @property (nonatomic, assign, getter = isVertical) BOOL vertical;

This property toggles whether the SwipeView is displayed horizontally or vertically on screen.

    @property (nonatomic, assign) BOOL delaysContentTouches;

This property works like the equivalent property of UIScrollView. It defers handling of touch events on subviews within the SwipeView so that embedded controls such as buttons do not interfere with the smooth scrolling of the SwipeView. Defaults to YES.

	@property (nonatomic, assign) BOOL bounces;

Sets whether the SwipeView should bounce past the end and return, or stop dead.

    @property (nonatomic, assign) float decelerationRate;
    
A floating-point value that determines the rate of deceleration after the user lifts their finger.
    
    @property (nonatomic, readonly, getter = isDragging) BOOL dragging;
    
Returns YES if user has started scrolling the SwipeView and has not yet released it.
    
    @property (nonatomic, readonly, getter = isDecelerating) BOOL decelerating;

Returns YES if the user isn't dragging the SwipeView any more, but it is still moving.

    @property (nonatomic, readonly, getter = isScrolling) BOOL scrolling;

Returns YES if the SwipeView is currently being scrolled programatically.

    @property (nonatomic, assign) BOOL defersItemViewLoading;

Sometimes when your SwipeView contains very complex item views, or large images, there can be a noticeable jerk in scrolling performance as it loads the new views. Setting the `defersItemViewLoading` property to `YES` forces the SwipeView to defer updating the currentItemIndex property and loading of new item views until after the scroll has finished. This can result in visible gaps in the SwipeView if you scroll too far in one go, but for scrolling short distances you may find that this improves animation performance.

    @property (nonatomic, assign) CGFloat autoscroll;

This property can be used to set the SwipeView scrolling at a constant speed. A value of 1.0 would scroll the SwipeView forwards at a rate of one item per second. The autoscroll value can be positive or negative and defaults to 0.0 (stationary). Autoscrolling will stop if the user interacts with the SwipeView, and will resume when they stop.
	
	
Methods
--------------

The SwipeView class has the following methods:

	- (void)reloadData;

This reloads all SwipeView item views from the dataSource and refreshes the display. Note that reloadData will reset the currentItemIndex back to zero, so if you want to retain the current scroll position, make a note of currentItemIndex before reloading and restore it afterwards. If you just wish to refresh the visible items without changing the number of items, consider calling `reloadItemAtIndex:` on all visible items instead.

	- (void)reloadItemAtIndex:(NSInteger)index;
	
This method will reload the specified item view. The new item will be requested from the dataSource. Off-screen views will not be reloaded.

	- (void)scrollByNumberOfItems:(NSInteger)itemCount duration:(NSTimeInterval)duration;

This method allows you to scroll the SwipeView by a fixed distance, measured in item widths. Positive or negative values may be specified for itemCount, depending on the direction you wish to scroll. SwipeView gracefully handles bounds issues, so if you specify a distance greater than the number of items in the SwipeView, scrolling will be clamped when it reaches the end of the SwipeView.

	- (void)scrollToItemAtIndex:(NSInteger)index duration:(NSTimeInterval)duration;

This will center the SwipeView on the specified item, either immediately or with a smooth animation.

	- (void)scrollToPage:(NSInteger)page duration:(NSTimeInterval)duration;

This will center the SwipeView on the specified item, either immediately or with a smooth animation.

	- (UIView *)itemViewAtIndex:(NSInteger)index;
	
Returns the visible item view with the specified index. Note that the index relates to the position in the SwipeView, and not the position in the `visibleItemViews` array, which may be different. The method only works for visible item views and will return nil if the view at the specified index has not been loaded, or if the index is out of bounds.

	- (NSInteger)indexOfItemView:(UIView *)view;
	
The index for a given item view in the SwipeView. This method only works for visible item views and will return NSNotFound for views that are not currently loaded. For a list of all currently loaded views, use the `visibleItemViews` property.

	- (NSInteger)indexOfItemViewOrSubview:(UIView *)view

This method gives you the item index of either the view passed or the view containing the view passed as a parameter. It works by walking up the view hierarchy starting with the view passed until it finds an item view and returns its index within the SwipeView. If no currently-loaded item view is found, it returns NSNotFound. This method is extremely useful for handling events on controls embedded within an item view. This allows you to bind all your item controls to a single action method on your view controller, and then work out which item the control that triggered the action was related to.


Protocols
---------------

The SwipeView follows the Apple convention for data-driven views by providing two protocol interfaces, SwipeViewDataSource and SwipeViewDelegate. The SwipeViewDataSource protocol has the following required methods:

	- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView;

Return the number of items (views) in the SwipeView.

	- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view;

Return a view to be displayed at the specified index in the SwipeView. The `reusingView` argument works like a UIPickerView, where views that have previously been displayed in the SwipeView are passed back to the method to be recycled. If this argument is not nil, you can set its properties and return it instead of creating a new view instance, which will slightly improve performance. Unlike UITableView, there is no reuseIdentifier for distinguishing between different SwipeView view types, so if your SwipeView contains multiple different view types then you should just ignore this parameter and return a new view each time the method is called. You should ensure that each time the `swipeView:viewForItemAtIndex:reusingView:` method is called, it either returns the reusingView or a brand new view instance rather than maintaining your own pool of recyclable views, as returning multiple copies of the same view for different SwipeView item indexes may cause display issues with the SwipeView.

The SwipeViewDelegate protocol has the following optional methods:

    - (CGSize)swipeViewItemSize:(SwipeView *)swipeView;

Returns the size in points/pixels of each item view. If this method is not implemented, the item size is automatically calculated from the first item view that is loaded.

    - (void)swipeViewDidScroll:(SwipeView *)swipeView;
    
This method is called whenever the SwipeView is scrolled. It is called regardless of whether the SwipeView was scrolled programatically or through user interaction.
    
    - (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView;
    
This method is called whenever the SwipeView scrolls far enough for the currentItemIndex property to change. It is called regardless of whether the item index was updated programatically or through user interaction.

    - (void)swipeViewWillBeginDragging:(SwipeView *)swipeView;
    
This method is called when the SwipeView is about to start moving as the result of the user dragging it.
    
    - (void)swipeViewDidEndDragging:(SwipeView *)swipeView willDecelerate:(BOOL)decelerate;
    
This method is called when the user stops dragging the SwipeView. The willDecelerate parameter indicates whether the SwipeView is travelling fast enough that it needs to decelerate before it stops (i.e. the current index is not necessarily the one it will stop at) or if it will stop where it is. Note that even if willDecelerate is NO, if pagin is enabled, the SwipeView will still scroll automatically until it aligns exactly on the current index.
    
    - (void)swipeViewWillBeginDecelerating:(SwipeView *)swipeView;
    
This method is called when the SwipeView is about to start decelerating after the user has finished dragging it.
    
    - (void)swipeViewDidEndDecelerating:(SwipeView *)swipeView;
    
This method is called when the SwipeView finishes decelerating and you can assume that the currentItemIndex at this point is the final stopping value.
    
    - (void)swipeViewDidEndScrollingAnimation:(SwipeView *)swipeView;

This method is called when the SwipeView finishes moving after being scrolled programmatically using the `scrollByNumberOfItems:` or `scrollToItemAtIndex:` methods.
    
    - (void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index;

This method will fire if the user taps any SwipeView item view. This method will not fire if the user taps a control within the currently selected view (i.e. any view that is a subclass of UIControl).

	- (BOOL)swipeView:(SwipeView *)swipeView shouldSelectItemAtIndex:(NSInteger)index;
	
This method will fire if the user taps any SwipeView item view. The purpose of a method is to give you the opportunity to ignore a tap on the SwipeView. If you return YES from the method, or don't implement it, the tap will be processed as normal and the `swipeView:didSelectItemAtIndex:` method will be called. If you return NO, the SwipeView will ignore the tap and it will continue to propagate up the view hierarchy. This is a good way to prevent the SwipeView intercepting tap events intended for processing by another view.


Detecting Taps on Item Views
----------------------------

There are two basic approaches to detecting taps on views in SwipeView. The first approach is to simply use the `swipeView:didSelectItemAtIndex:` delegate method, which fires every time an item is tapped.

Alternatively, if you want a little more control you can supply a UIButton or UIControl as the item view and handle the touch interactions yourself.

You can also nest UIControls within your item views and these will receive touches as expected (See the Controls Example project for how this can be done).

If you wish to detect other types of interaction such as swipes, double taps or long presses, the simplest way is to attach a UIGestureRecognizer to your item view or its subviews before passing it to the SwipeView.


Release Notes
----------------

Version 1.3.2

- Scroll offsets are now calculated correctly when SwipeView is scaled or rotated
- Reverted fix from 1.3.1 as it caused other scrollOffset bugs that were worse 

Version 1.3.1

- Fixed bug with scrollOffset changing when screen is rotated

Version 1.3

- SwipeView now requires ARC (see README for details)
- Added autoscroll property to set SwipeView scrolling at a constant speed
- Now supports animated item view resizing and screen rotation
- No longer crashes sometimes on iOS 7
- The scrollOffset property is now public
- Added scrollByOffset:duration: and scrollToOffset:duration: methods
- Calling reloadData no longer resets scroll position
- No longer behaves strangely if there is only one item and wrap is enabled
- Fixed problems with contentOffset when used inside UINavigationController
- You can now toggle wrapEnabled at any time without messing up item views
- Now conforms to -Weverything warning level

Version 1.2.10

- Fixed confict between SwipeView animation and UIScrollView scrolling
- Fixed issue due to missing [super layoutSubviews]

Version 1.2.9

- Fixed tap handling when wrap is enabled

Version 1.2.8

- Fixed bounds error when swipe view size is zero
- Fixed bug in the logic for automatically calculating item size
- Fixed bug where last visible view was sometimes not draw in non-wrapped mode
- Moved ARCHelper macros out of .h file so they do not affect non-ARC code in other classes

Version 1.2.7

- numberOfItems / numberOfPages getters now call numberOfItemsInSwipeView: dataSource method to ensure that value is correct.

Version 1.2.6

- SwipeView now calculates number of visible views more accurately
- Fixed a bug in the wrapping logic that could cause gaps when wrapEnabled = YES and alignment = SwipeViewAlignmentEdge
- SwipeView now won't attempt to call any datasource methods until the views need to be drawn, which avoids certain race conditions

Version 1.2.5

- Fixed issue where SwipeView was not correctly deferring view loading when the defersItemViewLoading option was enabled

Version 1.2.4

- SwipeView now correctly handles touch events on views outside the current page bounds
- Fixed rounding error when using defersItemViewLoading is enabled
- Added Controls Example to demo touch event handling

Version 1.2.3

- Fixed issue where setting currentItemIndex immediately after creating SwipeView would prevent user being able to swipe to the left 

Version 1.2.2

- Fixed rounding error for edge-aligned SwipeViews with paging enabled

Version 1.2.1

- Fixed off-by-one error when using scrollToItemAtIndex:duration: method
- swipeViewDidScroll: event is now sent as normal when defersItemViewLoading is enabled, but swipeViewCurrentItemIndexDidChange: is still deferred

Version 1.2

- Added vertical scrolling option
- Changed itemWidth property and swipeViewItemWidth: delegate method to itemSize and swipeViewItemSize: respectively
- Fixes some bugs when defersItemViewLoading is enabled

Version 1.1.7

- Added delaysContentTouches property, which defaults to YES
- Fixed blank pages issue when using defersItemViewLoading

Version 1.1.6

- defersItemViewLoading property is now observed when swiping as well as when scrolling programatically
- Fixed divide-by-zero error

Version 1.1.5

- Fixed layout bug when scrolling more than a single page at a time
- Added defersItemViewLoading property

Version 1.1.4

- Scrolling methods now let you specify the duration of the scroll

Version 1.1.3

- Fixed reloading bug on wrapped SwipeViews
- Added test projects folder

Version 1.1.2

- Fixed wrapping issue with carousel for certain item counts
- Calling reloadData on carousel now resets currentItemIndex to zero

Version 1.1.1

- Removed some leftover debug code that had broken the view recycling logic
- Fixed bug where scrolling SwipeView programmatically immediately after loading
would cause a crash
- Added ARC Test example

Version 1.1

- Added support for wrapping
- It is now possible to display multiple items per page
- Fixed layout glitches when rotating or resizing view
- Added additional properties and delegate methods
- Added page control to example application

Version 1.0.1

- Fixed bug in delegate setter method
- Fixed crash when total number of items is less than visible number

Version 1.0

- Added dynamic view loading and recycling
- Added ARC support
- Added documentation
- Renamed some methods for consistency with iCarousel

Version 0.9

- Prerelease version.