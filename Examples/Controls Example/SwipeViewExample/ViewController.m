//
//  ViewController.m
//  SwipeViewExample
//
//  Created by Nick Lockwood on 28/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //configure swipe view
    _swipeView.alignment = SwipeViewAlignmentCenter;
    _swipeView.pagingEnabled = YES;
    _swipeView.itemsPerPage = 1;
    _swipeView.truncateFinalPage = YES;
}

- (void)dealloc
{
    _swipeView.delegate = nil;
    _swipeView.dataSource = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    //generate 100 item views
    //normally we'd use a backing array
    //as shown in the basic iOS example
    //but for this example we haven't bothered
    return 100;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if (!view)
    {
    	//load new item view instance from nib
        //control events are bound to view controller in nib file
        //note that it is only safe to use the reusingView if we return the same nib for each
        //item view, if different items have different contents, ignore the reusingView value
    	view = [[NSBundle mainBundle] loadNibNamed:@"ItemView" owner:self options:nil][0];
    }
    return view;
}

#pragma mark -
#pragma mark Control events

- (IBAction)pressedButton:(id)sender
{
    _label.text = [NSString stringWithFormat:@"Button %i pressed", [_swipeView indexOfItemViewOrSubview:sender]];
}

- (IBAction)toggledSwitch:(id)sender
{
    _label.text = [NSString stringWithFormat:@"Switch %i toggled", [_swipeView indexOfItemViewOrSubview:sender]];
}

- (IBAction)changedSlider:(id)sender
{
    _label.text = [NSString stringWithFormat:@"Slider %i changed", [_swipeView indexOfItemViewOrSubview:sender]];
}

@end
