//
//  Like.m
//  Shuttr
//
//  Created by Francis Bato on 10/23/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "Like.h"

@implementation Like
@dynamic post;
@dynamic author;


+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Like";
}


@end
