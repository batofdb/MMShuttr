//
//  MainFeedViewController.h
//  Shuttr
//
//  Created by Lin Wei on 10/22/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol MainFeedDelegate <NSObject>

- (void)postWasChanged:(id)sender;

@end


@interface MainFeedViewController : UIViewController

@property (weak, nonatomic) id <MainFeedDelegate> delegate;

@property BOOL somethingChanged;

@end
