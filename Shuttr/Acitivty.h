//
//  Acitivty.h
//  Shuttr
//
//  Created by Francis Bato on 10/23/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import <Parse/Parse.h>
#import "Post.h"
#import "User.h"

@interface Acitivty : PFObject <PFSubclassing>

@property (nonatomic) NSNumber *activityType;
@property (nonatomic) NSString *content;
@property (nonatomic) User *toUser;
@property (nonatomic) User *fromUser;
@property (nonatomic) Post *post;

+ (void)load;
+ (NSString *)parseClassName;

@end
