//
//  PhotoManager.m
//  Shuttr
//
//  Created by Lin Wei on 10/23/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "PhotoManager.h"

@implementation PhotoManager

@dynamic photos;

- (instancetype)init {
    if (self = [super init]) {
        self.photos = [NSMutableArray new];
    }
    
    return self;
}

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"PhotoManager";
}



-(BOOL)addPhoto:(UIImage *)image{
    
    [self.photos addObject:image];
    
    if (self.photos.count ==6 ) {
        
        return YES;
        
    }
    
    return NO;
}

@end
