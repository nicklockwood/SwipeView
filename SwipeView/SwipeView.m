//
//  SwipeView.m
//
//  Version 1.1.3
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
@property (nonatomic, assign) CGPoint previousContentOffset;
@property (nonatomic, assign) CGFloat scrollOffset;
@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) BOOL suppressScrollEvent;

@end


@implementation SwipeView

@synthesize itemWidth = _itemWidth;
@synthesize itemsPerPage = _itemsPerPage;
@synthesize truncateFinalPage = _truncateFinalPage;
@synthesize alignment = _alignment;
@synthesize previousItemIndex = _previousItemIndex;
@synthesize previousContentOffset = _previousContentOffset;
@synthesize scrollOffset = _scrollOffset;
@synthesize itemViews = _itemViews;
@synthesize itemViewPool = _itemViewPool;
@synthesize scrollView = _scrollView;
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize numberOfItems = _numberOfItems;
@synthesize pagingEnabled = _pagingEnabled;
@synthesize scrollEnabled = _scrollEnabled;
@synthesize bounces = _bounces;
@synthesize wrapEnabled = _wrapEnabled;
@synthesize decelerationRate = _decelerationRate;
@synthesize suppressScrollEvent = _suppressScrollEvent;


#pragma mark -
#pragma mark Initialisation

- (void)setUp
{
    _scrollEnabled = YES;
    _pagingEnabled = YES;
    _bounces = YES;
    _wrapEnabled = NO;
    _itemsPerPage = 1;
    _truncateFinalPage = NO;
    
    _scrollView = [[UIScrollView alloc] init];
	_scrollView.delegate = self;
	_scrollView.delaysContentTouches = NO;
    _scrollView.bounces = _bounces && !_wrapEnabled;
	_scrollView.alwaysBounceHorizontal = _bounces;
	_scrollView.pagingEnabled = _pagingEnabled;
	_scrollView.scrollEnabled = _scrollEnabled;
    _scrollView.decelerationRate = _decelerationRate;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.scrollsToTop = NO;
	_scrollView.clipsToBounds = NO;
    
    _decelerationRate = _scrollView.decelerationRate;
    _itemViews = [[NSMutableDictionary alloc] init];
    _previousItemIndex = 0;
    _previousContentOffset = _scrollView.contentOffset;
    _scrollOffset = 0.0f;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    tapGesture.delegate = self;
    [_scrollView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    self.clipsToBounds = YES;
    
    //place scrollview at bottom of hierarchy
    [self insertSubview:_scrollView atIndex:0];
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
		[self setNeedsLayout];
    }
}

- (void)setAlignment:(SwipeViewAlignment)alignment
{
    if (_alignment != alignment)
    {
        _alignment = alignment;
        [self setNeedsLayout];
    }
}

- (void)setItemsPerPage:(NSInteger)itemsPerPage
{
    if (_itemsPerPage != itemsPerPage)
    {
        _itemsPerPage = itemsPerPage;
        [self setNeedsLayout];
    }
}

- (void)setTruncateFinalPage:(BOOL)truncateFinalPage
{
    if (_truncateFinalPage != truncateFinalPage)
    {
        _truncateFinalPage = truncateFinalPage;
        [self setNeedsLayout];
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
        [self setNeedsLayout];
    }
}

- (void)setWrapEnabled:(BOOL)wrapEnabled
{
    if (_wrapEnabled != wrapEnabled)
    {
        _wrapEnabled = wrapEnabled;
        _scrollView.bounces = _bounces && !_wrapEnabled;
        [self setNeedsLayout];
    }
}

- (void)setBounces:(BOOL)bounces
{
    if (_bounces != bounces)
    {
        _bounces = bounces;
        _scrollView.alwaysBounceHorizontal = _bounces;
        _scrollView.bounces = _bounces && !_wrapEnabled;
    }
}

- (void)setDecelerationRate:(float)decelerationRate
{
    if (_decelerationRate != decelerationRate)
    {
        _decelerationRate = decelerationRate;
        _scrollView.decelerationRate = _decelerationRate;
    }
}

- (BOOL)isDragging
{
    return _scrollView.dragging;
}

- (BOOL)isDecelerating
{
    return _scrollView.decelerating;
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


#pragma mark -
#pragma mark View layout

- (void)updateItemWidth
{
    //item width
    if ([_delegate respondsToSelector:@selector(swipeViewItemWidth:)])
    {
        _itemWidth = [_delegate swipeViewItemWidth:self];
    }
    else if (_numberOfItems > 0)
    {
        if ([_itemViews count] == 0)
        {
            [self loadViewAtIndex:0];
        }
        UIView *itemView = [[_itemViews allValues] lastObject];
        _itemWidth = itemView.bounds.size.width;
    }
}
- (void)updateScrollOffset
{
    if (_wrapEnabled)
    {
        CGFloat scrollWidth = _scrollView.contentSize.width / 3.0f;
        if (_scrollView.contentOffset.x < scrollWidth)
        {
            _previousContentOffset.x += scrollWidth;
            [self setContentOffsetWithoutEvent:CGPointMake(_scrollView.contentOffset.x + scrollWidth, 0.0f)];
        }
        else if (_scrollView.contentOffset.x >= scrollWidth * 2.0f)
        {
            _previousContentOffset.x -= scrollWidth;
            [self setContentOffsetWithoutEvent:CGPointMake(_scrollView.contentOffset.x - scrollWidth, 0.0f)];
        }
        _scrollOffset = [self clampedOffset:_scrollOffset];
    }
}

- (void)updateScrollViewDimensions
{
    [self updateItemWidth];
    
    CGRect frame = self.bounds;
    CGSize contentSize = frame.size;
    switch (_alignment)
    {
        case SwipeViewAlignmentCenter:
        {
            frame = CGRectMake((self.frame.size.width - _itemWidth * _itemsPerPage)/2.0f,
                               0.0f, _itemWidth * _itemsPerPage, self.frame.size.height);
            contentSize.width = _itemWidth * _numberOfItems;
            break;
        }
        case SwipeViewAlignmentEdge:
        {
            frame = CGRectMake(0.0f, 0.0f, _itemWidth * _itemsPerPage, self.frame.size.height);
            contentSize.width = _itemWidth * _numberOfItems - (self.frame.size.width - frame.size.width);
            break;
        }
        default:
        {
            break;
        }
    }
    
    if (_wrapEnabled)
    {
        contentSize.width = _itemWidth * _numberOfItems * 3.0f;
    }
    else if (_pagingEnabled && !_truncateFinalPage)
    {
        contentSize.width = ceilf(contentSize.width / frame.size.width) * frame.size.width;
    }
    
    if (!CGRectEqualToRect(_scrollView.frame, frame))
    {
        _scrollView.frame = frame;
    }
    
    if (!CGSizeEqualToSize(_scrollView.contentSize, contentSize))
    {
        _scrollView.contentSize = contentSize;
    }
    
    [self updateScrollOffset];
}

- (CGFloat)offsetForItemAtIndex:(NSInteger)index
{
    //calculate relative position
    CGFloat offset = index - _scrollOffset;
    if (_wrapEnabled)
    {
        if (offset > _numberOfItems/2)
        {
            offset -= _numberOfItems;
        }
        else if (offset < -_numberOfItems/2)
        {
            offset += _numberOfItems;
        }
        if (_numberOfItems == 0)
        {
            offset = 0.0f;
        }
    }
    return offset;
}

- (void)setFrameForView:(UIView *)view atIndex:(NSInteger)index
{
    view.center = CGPointMake(([self offsetForItemAtIndex:index] + 0.5f) * _itemWidth + _scrollView.contentOffset.x,
                              _scrollView.frame.size.height/2.0f);
}

- (void)layOutItemViews
{
    for (UIView *view in self.visibleItemViews)
    {
        [self setFrameForView:view atIndex:[self indexOfItemView:view]];
    }
}

- (void)updateLayout
{
    [self updateScrollViewDimensions];
    [UIView setAnimationsEnabled:NO];
    [self loadUnloadViews];
    [UIView setAnimationsEnabled:YES];
    [self layOutItemViews];
}

- (void)layoutSubviews
{
    [self updateLayout];
    [self performSelectorOnMainThread:@selector(updateLayout) withObject:nil waitUntilDone:NO];
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
    if (_wrapEnabled)
    {
        if (_numberOfItems == 0)
        {
            return 0;
        }
        return index - floorf((CGFloat)index / (CGFloat)_numberOfItems) * _numberOfItems;
    }
    else
    {
        return MIN(MAX(index, 0), _numberOfItems - 1);
    }
}

- (CGFloat)clampedOffset:(CGFloat)offset
{
    if (_wrapEnabled)
    {
        return _numberOfItems? (offset - floorf(offset / (CGFloat)_numberOfItems) * _numberOfItems): 0.0f;
    }
    else
    {
        return fminf(fmaxf(0.0f, offset), (CGFloat)_numberOfItems - 1.0f);
    }
}

- (void)setContentOffsetWithoutEvent:(CGPoint)contentOffset
{
    _suppressScrollEvent = YES;
    _scrollView.contentOffset = contentOffset;
    _suppressScrollEvent = NO;
}

- (CGFloat)scrollOffset
{
    return [self clampedOffset:_scrollView.contentOffset.x / _itemWidth];
}

- (NSInteger)currentItemIndex
{   
    return [self clampedIndex:roundf(self.scrollOffset)];
}

- (NSInteger)currentPage
{
    if (_itemsPerPage > 1 && _truncateFinalPage && !_wrapEnabled &&
        _scrollView.contentOffset.x >= _scrollView.contentSize.width - _scrollView.frame.size.width - _itemWidth * 0.5f)
    {
        return self.numberOfPages - 1;
    }
    return roundf((float)self.currentItemIndex / (float)_itemsPerPage);
}

- (NSInteger)numberOfPages
{
    return ceilf((float)_numberOfItems / (float)_itemsPerPage);
}

- (NSInteger)minScrollDistanceFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    NSInteger directDistance = toIndex - fromIndex;
    if (_wrapEnabled)
    {
        NSInteger wrappedDistance = MIN(toIndex, fromIndex) + _numberOfItems - MAX(toIndex, fromIndex);
        if (fromIndex < toIndex)
        {
            wrappedDistance = -wrappedDistance;
        }
        return (ABS(directDistance) <= ABS(wrappedDistance))? directDistance: wrappedDistance;
    }
    return directDistance;
}

- (CGFloat)minScrollDistanceFromOffset:(CGFloat)fromOffset toOffset:(CGFloat)toOffset
{
    CGFloat directDistance = toOffset - fromOffset;
    if (_wrapEnabled)
    {
        CGFloat wrappedDistance = fminf(toOffset, fromOffset) + _numberOfItems - fmaxf(toOffset, fromOffset);
        if (fromOffset < toOffset)
        {
            wrappedDistance = -wrappedDistance;
        }
        return (fabsf(directDistance) <= fabsf(wrappedDistance))? directDistance: wrappedDistance;
    }
    return directDistance;
}

- (void)setCurrentItemIndex:(NSInteger)currentItemIndex
{
    if (currentItemIndex != self.currentItemIndex)
    {
        [self scrollToItemAtIndex:currentItemIndex animated:NO];
    }
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    if (currentPage * _itemsPerPage != self.currentItemIndex)
    {
        [self scrollToPage:currentPage animated:NO];
    }
}

- (void)scrollByNumberOfItems:(NSInteger)itemCount animated:(BOOL)animated
{
    [self updateScrollViewDimensions];
    CGFloat scrollOffset = _itemWidth? _scrollView.contentOffset.x / _itemWidth: 0.0f;
    [_scrollView setContentOffset:CGPointMake(_itemWidth * (scrollOffset + itemCount), 0.0f) animated:animated];
}

- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated
{
	NSInteger itemCount = [self minScrollDistanceFromIndex:self.currentItemIndex toIndex:index];
    [self scrollByNumberOfItems:itemCount animated:animated];
}

- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated
{
    NSInteger index = page * _itemsPerPage;
    if (_truncateFinalPage)
    {
        index = MIN(index, _numberOfItems - _itemsPerPage);
    }
    [self scrollToItemAtIndex:index animated:animated];
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
    NSInteger numberOfVisibleItems = ceilf(self.bounds.size.width / _itemWidth) + 2;
    NSMutableSet *visibleIndices = [NSMutableSet setWithCapacity:numberOfVisibleItems];
    NSInteger offset = self.currentItemIndex - ceilf(_scrollView.frame.origin.x / _itemWidth) - 1;
    if (!_wrapEnabled)
    {
        offset = MAX(0, MIN(_numberOfItems - numberOfVisibleItems, offset));
    }
    
    for (NSInteger i = 0; i < numberOfVisibleItems; i++)
    {
        NSInteger index = [self clampedIndex:i + offset];
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
    //reset properties
    [self setContentOffsetWithoutEvent:CGPointZero];
    _scrollView.contentSize = CGSizeZero;
    _scrollOffset = 0.0f;
    _itemWidth = 0.0f;
    
    //remove old views
    for (UIView *view in self.visibleItemViews)
    {
        [view removeFromSuperview];
    }
    
    //get number of items
    _numberOfItems = [_dataSource numberOfItemsInSwipeView:self];
    
    //reset view pools
    self.itemViews = [NSMutableDictionary dictionary];
    self.itemViewPool = [NSMutableSet set];
    
    //layout views
    [self setNeedsLayout];
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
		[self setNeedsLayout];
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
    if (!_suppressScrollEvent)
    {
        //update scrollOffset
        CGFloat delta = _scrollView.contentOffset.x - _previousContentOffset.x;
        _previousContentOffset = _scrollView.contentOffset;
        _scrollOffset += delta / _itemWidth;
        
        //handle wrap
        [self updateScrollOffset];
        
        //update view
        [self layOutItemViews];
        [self loadUnloadViews];
        
        //send delegate events
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
    else
    {
        _previousContentOffset = _scrollView.contentOffset;
    }
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