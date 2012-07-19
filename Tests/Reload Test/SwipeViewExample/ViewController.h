//
//  ViewController.h
//  SwipeViewExample
//
//  Created by Nick Lockwood on 28/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwipeView.h"


@interface ViewController : UIViewController <SwipeViewDelegate, SwipeViewDataSource>

@property (nonatomic, strong) IBOutlet SwipeView *swipeView;

- (IBAction)reload;
- (IBAction)forwards;
- (IBAction)backwards;

@end
