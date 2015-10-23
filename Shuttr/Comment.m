//
//  Comment.m
//  Shuttr
//
//  Created by Philip Henson on 10/22/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "Comment.h"
#import <Parse/PFObject+Subclass.h>


@implementation Comment
@dynamic post;
@dynamic author;
@dynamic commentText;


+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Comment";
}

@end
