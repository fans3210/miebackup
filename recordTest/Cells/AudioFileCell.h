//
//  AudioFileCell.h
//  recordTest
//
//  Created by YAO DONG LI on 24/1/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Audio.h"

@interface AudioFileCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *bPlay;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *downloadingIndicator;

- (void)setStateForAudioState: (AudioState)state;

@end
