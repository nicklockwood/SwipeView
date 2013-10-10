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

@synthesize swipeView = _swipeView;
@synthesize colors = _colors;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        //set up colors
        self.colors = [NSMutableArray array];
        for (int i = 0; i < 10; i++)
        {
            [self.colors addObject:[UIColor colorWithRed:rand()/(float)RAND_MAX
                                                   green:rand()/(float)RAND_MAX
                                                    blue:rand()/(float)RAND_MAX
                                                   alpha:1.0f]];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //configure swipe view
    _swipeView.alignment = SwipeViewAlignmentCenter;
    _swipeView.pagingEnabled = NO;
    _swipeView.wrapEnabled = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(__unused UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSInteger)numberOfItemsInSwipeView:(__unused SwipeView *)swipeView
{
    return [self.colors count];
}

- (UIView *)swipeView:(__unused SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = (UILabel *)view;
    
    //create or reuse view
    if (view == nil)
    {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 100.0f)];
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        view = label;
    }
    
    //configure view
    label.backgroundColor = [self.colors objectAtIndex:index];
    label.text = [NSString stringWithFormat:@"%i", index];
    
    //return view
    return view;
}

- (IBAction)scrollToZero
{
    [_swipeView scrollToItemAtIndex:0 duration:0.5];
}

@end
