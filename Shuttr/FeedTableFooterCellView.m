//
//  FeedTableFooterView.m
//  Shuttr
//
//  Created by Francis Bato on 10/24/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "FeedTableFooterCellView.h"

@implementation FeedTableFooterCellView


- (IBAction)onMoreButtonPressed:(UIButton *)sender {
    [self.delegate moreButtonWasPressed:self];
}

- (IBAction)onCommentsButtonPressed:(UIButton *)sender {
    [self.delegate commentsButtonWasPressed:self];
}

- (IBAction)onLikeButtonPressed:(UIButton *)sender {
    [self.delegate likeButtonWasPressed:sender];
}

@end
