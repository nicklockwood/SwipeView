//
//  SwipeView.m
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


#import "SwipeView.h"


@interface SwipeView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *itemViews;
@property (nonatomic, assign) NSInteger previousItemIndex;
@property (nonatomic, assign) float itemWidth;

@end


@implementation SwipeView

@synthesize itemWidth = _itemWidth;
@synthesize alignment = _alignment;
@synthesize previousItemIndex = _previousItemIndex;
@synthesize itemViews = _itemViews;
@synthesize scrollView = _scrollView;
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize numberOfItems = _numberOfItems;
@synthesize pagingEnabled = _pagingEnabled;
@synthesize scrollEnabled = _scrollEnabled;
@synthesize bounces = _bounces;
@synthesize spacing = _spacing;


- (void)setUp
{
    _scrollEnabled = YES;
    _pagingEnabled = YES;
    _bounces = YES;
    _spacing = 1.0f;
    
    _itemViews = [[NSMutableArray alloc] init];
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
    tapGesture.delegate = (id <UIGestureRecognizerDelegate>)self;
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
        _delegate = _delegate;
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
    _scrollEnabled = scrollEnabled;
    _scrollView.scrollEnabled = _scrollEnabled;
}

- (void)setPagingEnabled:(BOOL)pagingEnabled
{
    _pagingEnabled = pagingEnabled;
    _scrollView.pagingEnabled = pagingEnabled;
}

- (void)setBounces:(BOOL)bounces
{
    _bounces = bounces;
    _scrollView.alwaysBounceHorizontal = _bounces;
    _scrollView.bounces = _bounces;
}

- (void)setSpacing:(CGFloat)spacing
{
    _spacing = spacing;
    [self reloadData];
}

- (void)reloadData
{    
	//remove old views
	for (UIView *view in _scrollView.subviews)
    {
		[view removeFromSuperview];
	}
    [_itemViews removeAllObjects];
	
    //get number of pages
    _previousItemIndex = self.currentItemIndex;
	_numberOfItems = [_dataSource numberOfItemsInSwipeView:self];
	self.itemViews = [NSMutableArray arrayWithCapacity:_numberOfItems];
    
    //set size
	if (_numberOfItems > 0)
    {
        _itemWidth = [[_dataSource swipeView:self viewForItemAtIndex:0] frame].size.width;
    }
    else
    {
        _itemWidth = self.bounds.size.width;
	}
    switch (_alignment)
    {
        case SwipeViewAlignmentCenter:
        {
            _scrollView.frame = CGRectMake((self.frame.size.width - _itemWidth * _spacing)/2.0f, 0.0f, _itemWidth * _spacing, self.frame.size.height);
            _scrollView.contentSize = CGSizeMake(_itemWidth * _spacing * _numberOfItems, _scrollView.frame.size.height);
            break;
        }
        case SwipeViewAlignmentEdge:
        {
            _scrollView.frame = CGRectMake(0.0f, 0.0f, _itemWidth * _spacing, self.frame.size.height);
            _scrollView.contentSize = CGSizeMake(_itemWidth * _spacing * _numberOfItems - (self.frame.size.width - _itemWidth * _spacing), _scrollView.frame.size.height);
            break;
        }
        default:
        {
            break;
        }
    }
	
    //load views
	for (NSUInteger i = 0; i < _numberOfItems; i++)
    {
		UIView *view = [_dataSource swipeView:self viewForItemAtIndex:i];
        view.center = CGPointMake(_itemWidth * _spacing * (i + 0.5f), _scrollView.bounds.size.height/2.0f);
		[_scrollView addSubview:view];
	}
}

- (NSInteger)clampedPageIndex:(NSInteger)index
{
    return MAX(0, MIN(index, _numberOfItems - 1));
}

- (NSInteger)currentItemIndex
{	
	CGPoint offset = _scrollView.contentOffset;
	NSInteger index = round(offset.x / (_itemWidth * _spacing));
	return [self clampedPageIndex:index];
}

- (void)scrollByNumberOfItems:(NSInteger)itemCount animated:(BOOL)animated;
{
    [self scrollToItemAtIndex:self.currentItemIndex + itemCount animated:animated];
}

- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated;
{
	index = [self clampedPageIndex:index];
    [_scrollView setContentOffset:CGPointMake(_itemWidth * index, 0) animated:animated];
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


- (void)didTap:(UITapGestureRecognizer *)tapGesture
{
    CGPoint point = [tapGesture locationInView:_scrollView];
    NSInteger index = point.x / (_itemWidth * _spacing);
    if ([_delegate respondsToSelector:@selector(swipeView:didSelectItemAtIndex:)])
    {
        [_delegate swipeView:self didSelectItemAtIndex:index];
    }
}


#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{	
	if ([_delegate respondsToSelector:@selector(swipeViewDidScroll:)])
    {
		[_delegate swipeViewDidScroll:self];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([_delegate respondsToSelector:@selector(swipeViewDidEndDragging:willDecelerate:)])
    {
        [_delegate swipeViewDidEndDragging:self willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([_delegate respondsToSelector:@selector(swipeViewDidEndDecelerating:)])
    {
        [_delegate swipeViewDidEndDecelerating:self];
    }
}

@end
