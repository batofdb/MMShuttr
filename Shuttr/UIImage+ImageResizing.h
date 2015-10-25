//
//  UIImage+ImageResizing.h
//  Shuttr
//
//  Created by Philip Henson on 10/24/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageResizing)

+ (UIImage*)imageWithImage:(UIImage *)image
              scaledToSize:(CGSize)newSize;

@end
