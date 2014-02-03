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