//
//  Acitivty.m
//  Shuttr
//
//  Created by Francis Bato on 10/23/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "Activity.h"
#import <Parse/PFObject+Subclass.h>

@implementation Activity

@dynamic toUser;
@dynamic fromUser;
@dynamic content;
@dynamic activityType;
@dynamic post;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Activity";
}


@end
