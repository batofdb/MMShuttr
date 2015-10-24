//
//  Post.m
//  Shuttr
//
//  Created by Philip Henson on 10/22/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "Post.h"
#import <Parse/PFObject+Subclass.h>
#import "User.h"

@implementation Post
@dynamic author;
@dynamic roll;
@dynamic description;
@dynamic timeStamp;
@dynamic likeCount;
@dynamic activityList;
@dynamic commentCount;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Post";
}

@end
