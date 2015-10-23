//
//  Like.h
//  Shuttr
//
//  Created by Francis Bato on 10/23/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import <Parse/Parse.h>
@class Post;
@class User;


@interface Like : PFObject <PFSubclassing>

@property User *author;
@property Post *post;

+ (NSString *)parseClassName;


@end
