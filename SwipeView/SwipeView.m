//
//  SwipeView.m
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

#import "SwipeView.h"


@interface SwipeView () <UIScrollViewDelegate>

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) NSMutableArray *pageViews;
@property (nonatomic, assign) NSInteger previousPageIndex;
@property (nonatomic, assign) float pageWidth;

@end


@implementation SwipeView

@synthesize pageWidth;
@synthesize alignment;
@synthesize previousPageIndex;
@synthesize pageViews;
@synthesize scrollView;
@synthesize dataSource;
@synthesize delegate;
@synthesize numberOfPages;
@synthesize pagingEnabled;
@synthesize scrollEnabled;
@synthesize bounces;


- (void)setup
{
    scrollEnabled = YES;
    pagingEnabled = YES;
    bounces = YES;
    
    pageViews = [[NSMutableArray alloc] init];
    previousPageIndex = 0;
    
    scrollView = [[UIScrollView alloc] init];
	scrollView.delegate = self;
	scrollView.delaysContentTouches = NO;
    scrollView.bounces = bounces;
	scrollView.alwaysBounceHorizontal = bounces;
	scrollView.pagingEnabled = pagingEnabled;
	scrollView.scrollEnabled = scrollEnabled;
	scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.showsVerticalScrollIndicator = NO;
	scrollView.scrollsToTop = NO;
	scrollView.clipsToBounds = NO;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    tapGesture.delegate = (id <UIGestureRecognizerDelegate>)self;
    [scrollView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    [self addSubview:scrollView];
    
    [self reloadData];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    [scrollView release];
    [pageViews release];
    [super dealloc];
}

- (void)setDataSource:(id<SwipeViewDataSource>)_dataSource
{
    if (dataSource != _dataSource)
    {
        dataSource = _dataSource;
		if (dataSource)
		{
			[self reloadData];
		}
    }
}

- (void)setDelegate:(id<SwipeViewDelegate>)_delegate
{
    if (delegate != _delegate)
    {
        delegate = _delegate;
		if (delegate && dataSource)
		{
			[self reloadData];
		}
    }
}

- (void)setAlignment:(SwipeViewAlignment)_alignment
{
    if (alignment != _alignment)
    {
        alignment = _alignment;
        if (dataSource)
		{
			[self reloadData];
		}
    }
}

- (void)setScrollEnabled:(BOOL)_scrollEnabled
{
    scrollEnabled = _scrollEnabled;
    scrollView.scrollEnabled = scrollEnabled;
}

- (void)setPagingEnabled:(BOOL)_pagingEnabled
{
    pagingEnabled = _pagingEnabled;
    scrollView.pagingEnabled = pagingEnabled;
}

- (void)setBounces:(BOOL)_bounces
{
    bounces = _bounces;
    scrollView.alwaysBounceHorizontal = bounces;
    scrollView.bounces = bounces;
}

- (void)reloadData
{    
	//remove old views
	for (UIView *view in scrollView.subviews)
    {
		[view removeFromSuperview];
	}
    [pageViews removeAllObjects];
	
    //get number of pages
    previousPageIndex = self.currentPageIndex;
	numberOfPages = [dataSource numberOfPagesInSwipeView:self];
	self.pageViews = [NSMutableArray arrayWithCapacity:numberOfPages];
    
    //set size
	if ([dataSource respondsToSelector:@selector(swipeViewPageWidth:)])
    {
		pageWidth = [dataSource swipeViewPageWidth:self];
	}
    else if (numberOfPages > 0)
    {
        pageWidth = [[dataSource swipeView:self viewForPageAtIndex:0] frame].size.width;
    }
    else
    {
        pageWidth = self.bounds.size.width;
	}
    switch (alignment)
    {
        case SwipeViewAlignmentCenter:
        {
            scrollView.frame = CGRectMake((self.frame.size.width - pageWidth)/2.0f, 0.0f, pageWidth, self.frame.size.height);
            scrollView.contentSize = CGSizeMake(pageWidth * numberOfPages, scrollView.frame.size.height);
            break;
        }
        case SwipeViewAlignmentEdge:
        {
            scrollView.frame = CGRectMake(0.0f, 0.0f, pageWidth, self.frame.size.height);
            scrollView.contentSize = CGSizeMake(pageWidth * numberOfPages - (self.frame.size.width - pageWidth), scrollView.frame.size.height);
            break;
        }
        default:
        {
            break;
        }
    }
	
    //load views
	for (NSUInteger i = 0; i < numberOfPages; i++)
    {
		UIView *view = [dataSource swipeView:self viewForPageAtIndex:i];
        view.center = CGPointMake(pageWidth * (i + 0.5f), scrollView.bounds.size.height/2.0f);
		[scrollView addSubview:view];
	}
}

- (NSInteger)clampedPageIndex:(NSInteger)index
{
    return MAX(0, MIN(index, numberOfPages - 1));
}

- (NSInteger)currentPageIndex
{	
	CGPoint offset = scrollView.contentOffset;
	NSInteger index = round(offset.x / pageWidth); 
	return [self clampedPageIndex:index];
}

- (void)scrollByNumberOfPages:(NSInteger)pageCount animated:(BOOL)animated;
{
    [self scrollToPageAtIndex:[self currentPageIndex] + pageCount animated:animated];
}

- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated;
{
	index = [self clampedPageIndex:index];
    [scrollView setContentOffset:CGPointMake(pageWidth * index, 0) animated:animated];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView *view = [super hitTest:point withEvent:event];
	if ([view isEqual:self])
    {
		return scrollView;
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
    CGPoint point = [tapGesture locationInView:scrollView];
    NSInteger index = (point.x/pageWidth);
    if ([delegate respondsToSelector:@selector(swipeView:didSelectItemAtIndex:)])
    {
        [delegate swipeView:self didSelectItemAtIndex:index];
    }
}


#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{	
	if ([delegate respondsToSelector:@selector(swipeViewDidScroll:)])
    {
		[delegate swipeViewDidScroll:self];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([delegate respondsToSelector:@selector(swipeViewDidEndDragging:willDecelerate:)])
    {
        [delegate swipeViewDidEndDragging:self willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([delegate respondsToSelector:@selector(swipeViewDidEndDecelerating:)])
    {
        [delegate swipeViewDidEndDecelerating:self];
    }
}

@end
