//
//  SignUpViewController.h
//  Shuttr
//
//  Created by Philip Henson on 10/25/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SignUpDelegate <NSObject>

- (void)cancelButtonPressedFromSignUp:(id)sender;

@end

@interface SignUpViewController : UIViewController

@property (weak, nonatomic) id<SignUpDelegate> delegate;

@end
