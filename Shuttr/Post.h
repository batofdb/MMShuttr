//
//  Post.h
//  Shuttr
//
//  Created by Philip Henson on 10/22/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import <Parse/Parse.h>
@class User;

@interface Post : PFObject <PFSubclassing>

@property (nonatomic) User *author;
@property (nonatomic) NSArray *roll;
@property (nonatomic) NSString *description;
@property (nonatomic) NSDate *timeStamp;
@property (nonatomic) NSNumber *likeCount;
@property (nonatomic) NSNumber *commentCount;
@property (nonatomic) PFRelation *activityList;

+ (NSString *)parseClassName;

@end
