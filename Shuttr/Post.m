//
//  Post.m
//  Shuttr
//
//  Created by Philip Henson on 10/22/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "Post.h"
#import <Parse/PFObject+Subclass.h>


@implementation Post

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Post";
}

@end
