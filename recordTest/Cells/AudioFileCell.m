//
//  AudioFileCell.m
//  mie
//
//  Created by YAO DONG LI on 24/1/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import "AudioFileCell.h"

@implementation AudioFileCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setStateForAudioState: (AudioState)state
{
    _bPlay.hidden = NO;
    
    if (state == PLAYING) {
        [_bPlay setBackgroundImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    } else if (state == DOWNLOADING) {
        _bPlay.hidden = YES;
        [_downloadingIndicator startAnimating];
    } else {
        [_bPlay setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self setStateForAudioState:READY];
}


@end
