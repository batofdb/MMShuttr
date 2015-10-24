//
//  UIImage+ImageResizing.m
//  Shuttr
//
//  Created by Philip Henson on 10/24/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "UIImage+ImageResizing.h"

@implementation UIImage (ImageResizing)

+ (UIImage*)imageWithImage:(UIImage *)image
              scaledToSize:(CGSize)newSize
{

    float heightToWidthRatio = image.size.height / image.size.width;
    float scaleFactor = 1;
    if(heightToWidthRatio > 0) {
        scaleFactor = newSize.height / image.size.height;
    } else {
        scaleFactor = newSize.width / image.size.width;
    }

    CGSize newSize2 = newSize;
    newSize2.width = image.size.width * scaleFactor;
    newSize2.height = image.size.height * scaleFactor;

    UIGraphicsBeginImageContext(newSize2);
    [image drawInRect:CGRectMake(0,0,newSize2.width,newSize2.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

@end
