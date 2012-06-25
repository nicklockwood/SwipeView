//
//  ViewController.m
//  SwipeViewExample
//
//  Created by Nick Lockwood on 28/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize swipeView = _swipeView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _swipeView.spacing = 1.1f;
    _swipeView.alignment = SwipeViewAlignmentEdge;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return 10;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 100.0f)];
    view.backgroundColor = [UIColor colorWithRed:rand()/(float)RAND_MAX
                                           green:rand()/(float)RAND_MAX
                                            blue:rand()/(float)RAND_MAX
                                           alpha:1.0f];
    return [view autorelease];
}

- (void)dealloc
{
    [_swipeView release];
    [super dealloc];
}

@end
