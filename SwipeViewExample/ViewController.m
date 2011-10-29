//
//  ViewController.m
//  SwipeViewExample
//
//  Created by Nick Lockwood on 28/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (NSInteger)numberOfPagesInSwipeView:(SwipeView *)swipeView
{
    return 5;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForPageAtIndex:(NSInteger)index
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 100.0f)];
    view.backgroundColor = [UIColor colorWithRed:rand()/(float)RAND_MAX
                                           green:rand()/(float)RAND_MAX
                                            blue:rand()/(float)RAND_MAX
                                           alpha:1.0f];
    return [view autorelease];
}

@end
