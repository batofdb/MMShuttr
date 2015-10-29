//
//  CameraViewController.h
//  Shuttr
//
//  Created by Lin Wei on 10/22/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol CameraViewDelegate <NSObject>

- (void)updateFeedForNewPost:(id)sender;

@end

@interface CameraViewController : UIViewController

@property PhotoManager *photoManager;

@property (weak, nonatomic) id<CameraViewDelegate>delegate;

@end
