//
//  User.m
//  Shuttr
//
//  Created by Philip Henson on 10/22/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "User.h"
#import <Parse/PFObject+Subclass.h>


@implementation User

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"User";
}

@end
