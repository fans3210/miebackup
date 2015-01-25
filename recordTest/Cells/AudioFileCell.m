//
//  AudioFileCell.m
//  recordTest
//
//  Created by YAO DONG LI on 24/1/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import "AudioFileCell.h"

@implementation AudioFileCell

- (void)awakeFromNib {
    // Initialization code
    _indicator.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
