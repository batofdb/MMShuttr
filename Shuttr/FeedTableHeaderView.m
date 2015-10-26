//
//  FeedTableHeaderView.m
//  Shuttr
//
//  Created by Philip Henson on 10/24/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "FeedTableHeaderView.h"

@implementation FeedTableHeaderView

- (void)awakeFromNib {
    self.authorProfilePicture.layer.cornerRadius = self.authorProfilePicture.frame.size.width/2;
    self.authorProfilePicture.clipsToBounds = YES;
}


- (IBAction)onAuthorButtonTapped:(UIButton *)sender {

    [self.delegate headerAuthorButtonTapped:sender];
}
@end
