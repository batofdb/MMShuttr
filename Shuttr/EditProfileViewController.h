//
//  EditProfileViewController.h
//  Shuttr
//
//  Created by Philip Henson on 10/24/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditProfileDelegate <NSObject>

- (void)profileWasChanged:(id)view;
- (void)editCancelled:(id)view;

@end

@interface EditProfileViewController : UIViewController

@property (nonatomic, weak) id<EditProfileDelegate>delegate;


@end
