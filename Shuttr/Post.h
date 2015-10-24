//
//  Post.h
//  Shuttr
//
//  Created by Philip Henson on 10/22/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import <Parse/Parse.h>
#import "User.h"

@interface Post : PFObject <PFSubclassing>

@property (nonatomic) User *author;
@property (nonatomic) NSArray *roll;
@property (nonatomic) NSString *textDescription;
@property (nonatomic) NSNumber *likeCount;
@property (nonatomic) NSNumber *commentCount;
@property (nonatomic) PFRelation *activityList;

+ (NSString *)parseClassName;

@end
