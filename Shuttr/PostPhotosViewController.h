//
//  PostPhotosViewController.h
//  Shuttr
//
//  Created by Lin Wei on 10/22/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PostPhotosDelegate <NSObject>

- (void)postButtonWasPressed:(id)sender;

@end


@interface PostPhotosViewController : UIViewController

@property (nonatomic) NSArray *images;
@property (weak, nonatomic) id<PostPhotosDelegate> delegate;


@end
