//
//  SearchDetailViewController.h
//  Shuttr
//
//  Created by Philip Henson on 10/24/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "MainFeedViewController.h"

@interface SearchDetailViewController : UIViewController

@property User *user;
@property MainFeedViewController *sourceVC;

@end
