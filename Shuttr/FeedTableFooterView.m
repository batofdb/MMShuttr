//
//  FeedTableFooterView.m
//  Shuttr
//
//  Created by Francis Bato on 10/24/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "FeedTableFooterView.h"

@implementation FeedTableFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self)
    {
        NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"FeedTableFooterView"
                                                         owner:self
                                                       options:nil];
        UIView *nibView = [objects firstObject];
        UIView *contentView = self.contentView;
        CGSize contentViewSize = contentView.frame.size;
        nibView.frame = CGRectMake(0, 0, contentViewSize.width, contentViewSize.height);
        [contentView addSubview:nibView];
    }
    return self;
}

-(void)awakeFromNib {
    [self prefix_addUpperBorder];
}
- (void)prefix_addUpperBorder
{
    CALayer *bottomBorder = [CALayer layer];

    bottomBorder.frame = CGRectMake(15.0f, self.frame.size.height, self.frame.size.width-60.0f, 1.0f);

    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8f
                                                     alpha:1.0f].CGColor;

    [self.layer addSublayer:bottomBorder];
}

- (BOOL) allowsFooterViewsToFloat {
    return NO;
}

@end
