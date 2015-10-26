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

    [self.delegate headerAuthorButtonTapped:sender];
}
@end
