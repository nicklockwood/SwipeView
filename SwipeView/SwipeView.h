//
//  SwipeView.h
//
//  Version 0.9
//
//  Created by Nick Lockwood on 03/09/2010.
//  Copyright 2011 Charcoal Design. All rights reserved.
//
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

#import <UIKit/UIKit.h>


typedef enum
{
    SwipeViewAlignmentEdge = 0,
    SwipeViewAlignmentCenter
}
SwipeViewAlignment;


@protocol SwipeViewDataSource, SwipeViewDelegate;

@interface SwipeView : UIView

@property (nonatomic, assign) IBOutlet NSObject<SwipeViewDataSource> *dataSource;
@property (nonatomic, assign) IBOutlet NSObject<SwipeViewDelegate> *delegate;
@property (nonatomic, readonly) NSInteger numberOfPages;
@property (nonatomic, readonly) NSInteger currentPageIndex;
@property (nonatomic, assign) SwipeViewAlignment alignment;
@property (nonatomic, assign, getter = isPagingEnabled) BOOL pagingEnabled;
@property (nonatomic, assign, getter = isScrollEnabled) BOOL scrollEnabled;
@property (nonatomic, assign) BOOL bounces;

- (void)reloadData;
- (void)scrollByNumberOfPages:(NSInteger)pageCount animated:(BOOL)animated;
- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated;

@end


@protocol SwipeViewDataSource <NSObject>

- (NSInteger)numberOfPagesInSwipeView:(SwipeView *)swipeView;
- (UIView *)swipeView:(SwipeView *)swipeView viewForPageAtIndex:(NSInteger)index;

@optional

- (CGFloat)swipeViewPageWidth:(SwipeView *)swipeView;

@end


@protocol SwipeViewDelegate <NSObject>
@optional

- (void)swipeViewDidScroll:(SwipeView *)swipeView;
- (void)swipeViewDidEndDragging:(SwipeView *)swipeView willDecelerate:(BOOL)decelerate;
- (void)swipeViewDidEndDecelerating:(SwipeView *)swipeView;
- (void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index;

@end
