//
//  SwipeView.h
//
//  Version 1.0
//
//  Created by Nick Lockwood on 03/09/2010.
//  Copyright 2011 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version of SwipeView from here:
//
//  https://github.com/nicklockwood/SwipeView
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

//
//  ARC Helper
//
//  Version 2.1
//
//  Created by Nick Lockwood on 05/01/2012.
//  Copyright 2012 Charcoal Design
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://gist.github.com/1563325
//

#ifndef ah_retain
#if __has_feature(objc_arc)
#define ah_retain self
#define ah_dealloc self
#define release self
#define autorelease self
#else
#define ah_retain retain
#define ah_dealloc dealloc
#define __bridge
#endif
#endif

//  Weak delegate support

#ifndef ah_weak
#import <Availability.h>
#if (__has_feature(objc_arc)) && \
((defined __IPHONE_OS_VERSION_MIN_REQUIRED && \
__IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0) || \
(defined __MAC_OS_X_VERSION_MIN_REQUIRED && \
__MAC_OS_X_VERSION_MIN_REQUIRED > __MAC_10_7))
#define ah_weak weak
#define __ah_weak __weak
#else
#define ah_weak unsafe_unretained
#define __ah_weak __unsafe_unretained
#endif
#endif

//  ARC Helper ends


#import <UIKit/UIKit.h>


typedef enum
{
    SwipeViewAlignmentEdge = 0,
    SwipeViewAlignmentCenter
}
SwipeViewAlignment;


@protocol SwipeViewDataSource, SwipeViewDelegate;

@interface SwipeView : UIView

@property (nonatomic, ah_weak) IBOutlet id<SwipeViewDataSource> dataSource;
@property (nonatomic, ah_weak) IBOutlet id<SwipeViewDelegate> delegate;
@property (nonatomic, readonly) NSInteger numberOfItems;
@property (nonatomic, readonly) NSInteger currentItemIndex;
@property (nonatomic, assign) SwipeViewAlignment alignment;
@property (nonatomic, assign, getter = isPagingEnabled) BOOL pagingEnabled;
@property (nonatomic, assign, getter = isScrollEnabled) BOOL scrollEnabled;
@property (nonatomic, assign) BOOL bounces;
@property (nonatomic, assign) CGFloat spacing;

- (void)reloadData;
- (void)scrollByNumberOfItems:(NSInteger)itemCount animated:(BOOL)animated;
- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated;

@end


@protocol SwipeViewDataSource <NSObject>

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView;
- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index;

@end


@protocol SwipeViewDelegate <NSObject>
@optional

- (void)swipeViewDidScroll:(SwipeView *)swipeView;
- (void)swipeViewDidEndDragging:(SwipeView *)swipeView willDecelerate:(BOOL)decelerate;
- (void)swipeViewDidEndDecelerating:(SwipeView *)swipeView;
- (void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index;

@end
