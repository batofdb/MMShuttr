//
//  PostDetailViewController.h
//  Shuttr
//
//  Created by Philip Henson on 10/24/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@protocol PostDetailDelegate <NSObject>

- (void)postWasDeleted:(id)sender;
- (void)postWasChangedOnDetail:(id)sender;

@end

@interface PostDetailViewController : UIViewController

@property (nonatomic) Post *post;

@property (weak, nonatomic) id<PostDetailDelegate>delegate;

@end
