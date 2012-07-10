//
//  SwipeView.m
//
//  Version 1.1
//
//  Created by Nick Lockwood on 03/09/2010.
//  Copyright 2010 Charcoal Design
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


#import "SwipeView.h"


@interface SwipeView () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableDictionary *itemViews;
@property (nonatomic, strong) NSMutableSet *itemViewPool;
@property (nonatomic, assign) NSInteger previousItemIndex;
@property (nonatomic, assign) CGFloat itemWidth;

- (UIView *)loadViewAtIndex:(NSInteger)index;

@end


@implementation SwipeView

@synthesize itemWidth = _itemWidth;
@synthesize alignment = _alignment;
@synthesize previousItemIndex = _previousItemIndex;
@synthesize itemViews = _itemViews;
@synthesize itemViewPool = _itemViewPool;
@synthesize scrollView = _scrollView;
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize numberOfItems = _numberOfItems;
@synthesize pagingEnabled = _pagingEnabled;
@synthesize scrollEnabled = _scrollEnabled;
@synthesize bounces = _bounces;


#pragma mark -
#pragma mark Initialisation

- (void)setUp
{
    _scrollEnabled = YES;
    _pagingEnabled = YES;
    _bounces = YES;
    
    _itemViews = [[NSMutableDictionary alloc] init];
    _previousItemIndex = 0;
    
    _scrollView = [[UIScrollView alloc] init];
	_scrollView.delegate = self;
	_scrollView.delaysContentTouches = NO;
    _scrollView.bounces = _bounces;
	_scrollView.alwaysBounceHorizontal = _bounces;
	_scrollView.pagingEnabled = _pagingEnabled;
	_scrollView.scrollEnabled = _scrollEnabled;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.scrollsToTop = NO;
	_scrollView.clipsToBounds = NO;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    tapGesture.delegate = self;
    [_scrollView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    [self addSubview:_scrollView];
    
    [self reloadData];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setUp];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setUp];
    }
    return self;
}

- (void)dealloc
{
    [_scrollView release];
    [_itemViews release];
    [_itemViewPool release];
    [super ah_dealloc];
}

- (void)setDataSource:(id<SwipeViewDataSource>)dataSource
{
    if (_dataSource != dataSource)
    {
        _dataSource = dataSource;
		if (_dataSource)
		{
			[self reloadData];
		}
    }
}

- (void)setDelegate:(id<SwipeViewDelegate>)delegate
{
    if (_delegate != delegate)
    {
        _delegate = delegate;
		if (_delegate && _dataSource)
		{
			[self reloadData];
		}
    }
}

- (void)setAlignment:(SwipeViewAlignment)alignment
{
    if (_alignment != alignment)
    {
        _alignment = alignment;
        if (_dataSource)
		{
			[self reloadData];
		}
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    if (_scrollEnabled != scrollEnabled)
    {
        _scrollEnabled = scrollEnabled;
        _scrollView.scrollEnabled = _scrollEnabled;
    }
}

- (void)setPagingEnabled:(BOOL)pagingEnabled
{
    if (_pagingEnabled != pagingEnabled)
    {
        _pagingEnabled = pagingEnabled;
        _scrollView.pagingEnabled = pagingEnabled;
    }
}

- (void)setBounces:(BOOL)bounces
{
    if (_bounces != bounces)
    {
        _bounces = bounces;
        _scrollView.alwaysBounceHorizontal = _bounces;
        _scrollView.bounces = _bounces;
    }
}


#pragma mark -
#pragma mark View management

- (NSArray *)indexesForVisibleItems
{
    return [[_itemViews allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (NSArray *)visibleItemViews
{
    NSArray *indexes = [self indexesForVisibleItems];
    return [_itemViews objectsForKeys:indexes notFoundMarker:[NSNull null]];
}

- (UIView *)itemViewAtIndex:(NSInteger)index
{
    return [_itemViews objectForKey:[NSNumber numberWithInteger:index]];
}

- (UIView *)currentItemView
{
    return [self itemViewAtIndex:self.currentItemIndex];
}

- (NSInteger)indexOfItemView:(UIView *)view
{
    NSInteger index = [[_itemViews allValues] indexOfObject:view];
    if (index != NSNotFound)
    {
        return [[[_itemViews allKeys] objectAtIndex:index] integerValue];
    }
    return NSNotFound;
}

- (NSInteger)indexOfItemViewOrSubview:(UIView *)view
{
    NSInteger index = [self indexOfItemView:view];
    if (index == NSNotFound && view != nil && view != _scrollView)
    {
        return [self indexOfItemViewOrSubview:view.superview];
    }
    return index;
}

- (void)setItemView:(UIView *)view forIndex:(NSInteger)index
{
    [(NSMutableDictionary *)_itemViews setObject:view forKey:[NSNumber numberWithInteger:index]];
}

- (void)removeViewAtIndex:(NSInteger)index
{
    NSMutableDictionary *newItemViews = [NSMutableDictionary dictionaryWithCapacity:[_itemViews count] - 1];
    for (NSNumber *number in [self indexesForVisibleItems])
    {
        NSInteger i = [number integerValue];
        if (i < index)
        {
            [newItemViews setObject:[_itemViews objectForKey:number] forKey:number];
        }
        else if (i > index)
        {
            [newItemViews setObject:[_itemViews objectForKey:number] forKey:[NSNumber numberWithInteger:i - 1]];
        }
    }
    self.itemViews = newItemViews;
}

- (void)insertView:(UIView *)view atIndex:(NSInteger)index
{
    NSMutableDictionary *newItemViews = [NSMutableDictionary dictionaryWithCapacity:[_itemViews count] + 1];
    for (NSNumber *number in [self indexesForVisibleItems])
    {
        NSInteger i = [number integerValue];
        if (i < index)
        {
            [newItemViews setObject:[_itemViews objectForKey:number] forKey:number];
        }
        else
        {
            [newItemViews setObject:[_itemViews objectForKey:number] forKey:[NSNumber numberWithInteger:i + 1]];
        }
    }
    if (view)
    {
        [self setItemView:view forIndex:index];
    }
    self.itemViews = newItemViews;
}


#pragma mark -
#pragma mark View layout

- (void)updateItemWidth
{
    if ([_delegate respondsToSelector:@selector(swipeViewItemWidth:)])
    {
        _itemWidth = [_delegate swipeViewItemWidth:self];
    }
    else if (_numberOfItems > 0)
    {
        if ([_itemViews count] == 0)
        {
            [[self loadViewAtIndex:0] removeFromSuperview];
        }
        UIView *itemView = [[_itemViews allValues] lastObject];
        _itemWidth = itemView.bounds.size.width;
    }
}

- (void)updateScrollViewDimensions
{
    CGRect frame = _scrollView.frame;
    CGSize contentSize = _scrollView.contentSize;
    switch (_alignment)
    {
        case SwipeViewAlignmentCenter:
        {
            frame = CGRectMake((self.frame.size.width - _itemWidth)/2.0f, 0.0f, _itemWidth, self.frame.size.height);
            contentSize = CGSizeMake(_itemWidth * _numberOfItems, _scrollView.frame.size.height);
            break;
        }
        case SwipeViewAlignmentEdge:
        {
            frame = CGRectMake(0.0f, 0.0f, _itemWidth, self.frame.size.height);
            contentSize = CGSizeMake(_itemWidth * _numberOfItems - (self.frame.size.width - _itemWidth), _scrollView.frame.size.height);
            break;
        }
        default:
        {
            break;
        }
    }
    
    if (!CGRectEqualToRect(_scrollView.frame, frame))
    {
        _scrollView.frame = frame;
    }
    if (!CGSizeEqualToSize(_scrollView.contentSize, contentSize))
    {
        _scrollView.contentSize = contentSize;
    }
}

- (void)setFrameForView:(UIView *)view atIndex:(NSInteger)index
{
    view.center = CGPointMake((index + 0.5f) * _itemWidth, _scrollView.frame.size.height/2.0f);
}

- (void)layOutItemViews
{
    [self updateItemWidth];
    for (UIView *view in self.visibleItemViews)
    {
        [self setFrameForView:view atIndex:[self indexOfItemView:view]];
    }
}

- (void)layoutSubviews
{
    [self updateScrollViewDimensions];
    [self layOutItemViews];
    [UIView setAnimationsEnabled:NO];
    [self loadUnloadViews];
    [UIView setAnimationsEnabled:YES];
}

#pragma mark -
#pragma mark View queing

- (void)queueItemView:(UIView *)view
{
    if (view)
    {
        [_itemViewPool addObject:view];
    }
}

- (UIView *)dequeueItemView
{
    UIView *view = [[_itemViewPool anyObject] ah_retain];
    if (view)
    {
        [_itemViewPool removeObject:view];
    }
    return [view autorelease];
}


#pragma mark -
#pragma mark Scrolling

- (NSInteger)clampedIndex:(NSInteger)index
{
    return MIN(MAX(index, 0), _numberOfItems - 1);
}

- (CGFloat)clampedOffset:(CGFloat)offset
{
    return fminf(fmaxf(0.0f, offset), (CGFloat)_numberOfItems - 1.0f);
}

- (CGFloat)scrollOffset
{
    return [self clampedOffset:_scrollView.contentOffset.x / _itemWidth];
}

- (NSInteger)currentItemIndex
{   
    return [self clampedIndex:roundf(self.scrollOffset)];
}

- (NSInteger)minScrollDistanceFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    return toIndex - fromIndex;
}

- (CGFloat)minScrollDistanceFromOffset:(CGFloat)fromOffset toOffset:(CGFloat)toOffset
{
    return toOffset - fromOffset;
}

- (void)setCurrentItemIndex:(NSInteger)currentItemIndex
{
    if (currentItemIndex != self.currentItemIndex)
    {
        [self scrollToItemAtIndex:currentItemIndex animated:NO];
    }
}

- (void)scrollByNumberOfItems:(NSInteger)itemCount animated:(BOOL)animated
{
    CGFloat scrollOffset = [self clampedOffset:_scrollView.contentOffset.x / _itemWidth];
    [_scrollView setContentOffset:CGPointMake(_itemWidth * (scrollOffset + itemCount), 0.0f) animated:animated];
}

- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated
{
	NSInteger itemCount = [self minScrollDistanceFromIndex:self.currentItemIndex toIndex:index];
    [self scrollByNumberOfItems:itemCount animated:animated];
}

- (void)didScroll
{
    [self layOutItemViews];
    [self loadUnloadViews];
    
	if ([_delegate respondsToSelector:@selector(swipeViewDidScroll:)])
    {
		[_delegate swipeViewDidScroll:self];
	}
    
    if (_previousItemIndex != self.currentItemIndex)
    {
        _previousItemIndex = self.currentItemIndex;
        if ([_delegate respondsToSelector:@selector(swipeViewCurrentItemIndexDidChange:)])
        {
            [_delegate swipeViewCurrentItemIndexDidChange:self];
        }
    }
}


#pragma mark -
#pragma mark View loading

- (UIView *)loadViewAtIndex:(NSInteger)index
{
    UIView *view = [_dataSource swipeView:self viewForItemAtIndex:index reusingView:[self dequeueItemView]];    
    if (view == nil)
    {
        view = [[[UIView alloc] init] autorelease];
    }
    
    UIView *oldView = [self itemViewAtIndex:index];
    if (oldView)
    {
        [self queueItemView:oldView];
        [oldView removeFromSuperview];
    }
    
    [self setItemView:view forIndex:index];
    [self setFrameForView:view atIndex:index];
    [_scrollView addSubview:view];

    return view;
}

- (void)loadUnloadViews
{
    //calculate visible view indices
    NSInteger count = MIN(_numberOfItems, _itemWidth? floorf(self.bounds.size.width / _itemWidth) + 3: 0);
    NSInteger offset = self.currentItemIndex - 1;
    if (_alignment == SwipeViewAlignmentCenter)
    {
        count --;
        offset -= count/2 - 1;
    }
    offset = MAX(0, MIN(_numberOfItems - count, offset));
    NSMutableSet *visibleIndices = [NSMutableSet setWithCapacity:count];
    for (NSInteger i = 0; i < count; i++)
    {
        NSInteger index = i + offset;
        [visibleIndices addObject:[NSNumber numberWithInteger:index]];
    }
    
    //remove offscreen views
    for (NSNumber *number in [_itemViews allKeys])
    {
        if (![visibleIndices containsObject:number])
        {
            UIView *view = [_itemViews objectForKey:number];
            [self queueItemView:view];
            [view removeFromSuperview];
            [_itemViews removeObjectForKey:number];
        }
    }
    
    //add onscreen views
    for (NSNumber *number in visibleIndices)
    {
        UIView *view = [_itemViews objectForKey:number];
        if (view == nil)
        {
            [self loadViewAtIndex:[number integerValue]];
        }
    }
}

- (void)reloadItemAtIndex:(NSInteger)index
{
    //if view is visible
    if ([self itemViewAtIndex:index])
    {
        //reload view
        [self loadViewAtIndex:index];
    }
}

- (void)reloadData
{    
    //remove old views
    for (UIView *view in [_itemViews allValues])
    {
        [view removeFromSuperview];
    }
    
    //bail out if not set up yet
    if (!_dataSource || !_scrollView)
    {
        return;
    }
    
    //get number of items
    _numberOfItems = [_dataSource numberOfItemsInSwipeView:self];
    
    //set item width
    [self updateItemWidth];
    
    //update alignment
    [self updateScrollViewDimensions];
    
    //prevent false index changed event
    _previousItemIndex = self.currentItemIndex;
    
    //reset view pools
    self.itemViews = [NSMutableDictionary dictionary];
    self.itemViewPool = [NSMutableSet set];
    
    //layout views
    [self loadUnloadViews];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView *view = [super hitTest:point withEvent:event];
	if ([view isEqual:self])
    {
		return _scrollView;
	}
	return view;
}

- (void)didMoveToSuperview
{
    if (self.superview)
	{
		[self reloadData];
	}
}

#pragma mark -
#pragma mark Gestures and taps

- (NSInteger)viewOrSuperviewIndex:(UIView *)view
{
    if (view == nil || view == _scrollView)
    {
        return NSNotFound;
    }
    NSInteger index = [self indexOfItemView:view];
    if (index == NSNotFound)
    {
        return [self viewOrSuperviewIndex:view.superview];
    }
    return index;
}

- (BOOL)viewOrSuperview:(UIView *)view isKindOfClass:(Class)class
{
    if (view == nil || view == _scrollView)
    {
        return NO;
    }
    else if ([view isKindOfClass:class])
    {
        return YES;
    }
    return [self viewOrSuperview:view.superview isKindOfClass:class];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gesture shouldReceiveTouch:(UITouch *)touch
{
    if ([gesture isKindOfClass:[UITapGestureRecognizer class]])
    {
        //handle tap
        NSInteger index = [self viewOrSuperviewIndex:touch.view];
        if (index != NSNotFound)
        {
            if ([_delegate respondsToSelector:@selector(swipeView:shouldSelectItemAtIndex:)])
            {
                if (![_delegate swipeView:self shouldSelectItemAtIndex:index])
                {
                    return NO;
                }
            }
            if ([self viewOrSuperview:touch.view isKindOfClass:[UIControl class]] ||
                [self viewOrSuperview:touch.view isKindOfClass:[UITableViewCell class]])
            {
                return NO;
            }
        }
    }
    return YES;
}

- (void)didTap:(UITapGestureRecognizer *)tapGesture
{
    CGPoint point = [tapGesture locationInView:_scrollView];
    NSInteger index = point.x / (_itemWidth);
    if ([_delegate respondsToSelector:@selector(swipeView:didSelectItemAtIndex:)])
    {
        [_delegate swipeView:self didSelectItemAtIndex:index];
    }
}


#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //update view
    [self didScroll];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_delegate respondsToSelector:@selector(swipeViewWillBeginDragging:)])
    {
        [_delegate swipeViewWillBeginDragging:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([_delegate respondsToSelector:@selector(swipeViewDidEndDragging:willDecelerate:)])
    {
        [_delegate swipeViewDidEndDragging:self willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([_delegate respondsToSelector:@selector(swipeViewWillBeginDecelerating:)])
    {
        [_delegate swipeViewWillBeginDecelerating:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([_delegate respondsToSelector:@selector(swipeViewDidEndDecelerating:)])
    {
        [_delegate swipeViewDidEndDecelerating:self];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([_delegate respondsToSelector:@selector(swipeViewDidEndScrollingAnimation:)])
    {
        [_delegate swipeViewDidEndScrollingAnimation:self];
    }
}

@end
