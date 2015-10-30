//
//  ImageProcessing.m
//  Shuttr
//
//  Created by Philip Henson on 10/23/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "ImageProcessing.h"

@implementation ImageProcessing

+(NSArray *)getDataArrayFromImageArray:(NSArray *)imageArray {
    NSMutableArray *dataArray = [NSMutableArray new];

    for (UIImage *image in imageArray) {
        NSData *data = UIImageJPEGRepresentation(image, 0.6f);
        [dataArray addObject:data];
    }

    return [NSArray arrayWithArray:dataArray];
}

+(NSArray *)getImageArrayFromDataArray:(NSArray *)dataArray {
    NSMutableArray *imageArray = [NSMutableArray new];
    for (NSData *data in dataArray) {
        UIImage *image = [UIImage imageWithData:data];
        [imageArray addObject:image];
    }

    return [NSArray arrayWithArray:imageArray];
}

+(NSData *)getDataFromImage:(UIImage *)image {
    return UIImageJPEGRepresentation(image, 0.6f);
}

+(UIImage *)getImageFromData:(NSData *)data {
    return [UIImage imageWithData:data];
}




@end
