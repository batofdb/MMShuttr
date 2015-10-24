//
//  ImageProcessing.h
//  Shuttr
//
//  Created by Philip Henson on 10/23/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageProcessing : NSObject

+(NSArray *)getDataArrayFromImageArray:(NSArray *)imageArray;

+(NSArray *)getImageArrayFromDataArray:(NSArray *)dataArray;

+(NSData *)getDataFromImage:(UIImage *)image;

+(UIImage *)getImageFromData:(NSData *)data;

@end
