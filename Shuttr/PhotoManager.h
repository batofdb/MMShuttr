//
//  PhotoManager.h
//  Shuttr
//
//  Created by Lin Wei on 10/23/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import <Parse/Parse.h>

@interface PhotoManager : PFObject<PFSubclassing>

@property(nonatomic)NSMutableArray* photos;


-(BOOL)addPhoto:(UIImage*)image;
+ (NSString *)parseClassName;
@end
