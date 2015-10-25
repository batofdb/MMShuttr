//
//  FeedTableHeaderView.m
//  Shuttr
//
//  Created by Philip Henson on 10/24/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "FeedTableHeaderView.h"

@implementation FeedTableHeaderView

- (IBAction)onAuthorButtonTapped:(UIButton *)sender {

    [self.delegate headerAuthorButtonTapped:self];
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self)
    {
        NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"FeedTableHeaderView"
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

@end
