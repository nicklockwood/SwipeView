Version 1.1.6

- defersItemViewLoading property is now observed when swiping as well as when scrolling programatically

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