//
//  Comment.h
//  Shuttr
//
//  Created by Philip Henson on 10/22/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import <Parse/Parse.h>
@class Post;
@class User;

@interface Comment : PFObject <PFSubclassing>

@property Post *post;
@property User *author;
@property NSString *commentText;

+ (NSString *)parseClassName;

@end
