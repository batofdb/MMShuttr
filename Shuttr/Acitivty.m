//
//  Acitivty.m
//  Shuttr
//
//  Created by Francis Bato on 10/23/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "Acitivty.h"

@implementation Acitivty

@dynamic toUser;
@dynamic fromUser;
@dynamic content;
@dynamic activityType;
@dynamic post;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Post";
}


@end
