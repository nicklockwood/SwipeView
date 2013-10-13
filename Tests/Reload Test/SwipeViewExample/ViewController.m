//
//  ViewController.m
//  SwipeViewExample
//
//  Created by Nick Lockwood on 28/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *colors;

@end


@implementation ViewController

- (IBAction)reload
{
    //set up colors
    self.colors = [NSMutableArray array];
    for (int i = 0; i < arc4random_uniform(1000) + 2; i++)
    {
        [self.colors addObject:[UIColor colorWithRed:drand48()
                                               green:drand48()
                                                blue:drand48()
                                               alpha:1.0f]];
    }
    
    //reload content
    [_swipeView reloadData];
}

- (IBAction)forwards
{
    [_swipeView scrollByNumberOfItems:3 duration:1.4];
}

- (IBAction)backwards
{
    [_swipeView scrollByNumberOfItems:-3 duration:1.4];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        //set up data
        [self reload];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //configure swipe view
    _swipeView.alignment = SwipeViewAlignmentCenter;
    _swipeView.pagingEnabled = YES;
    _swipeView.wrapEnabled = NO;
    _swipeView.truncateFinalPage = YES;
    
    //try scrolling immediately after load
    [_swipeView scrollToItemAtIndex:2 duration:0.0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return [self.colors count];
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = (UILabel *)view;
    
    //create or reuse view
    if (view == nil)
    {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        view = label;
    }
    
    //configure view
    label.backgroundColor = (self.colors)[index];
    label.text = [NSString stringWithFormat:@"%i", index];
    
    //return view
    return view;
}

@end
