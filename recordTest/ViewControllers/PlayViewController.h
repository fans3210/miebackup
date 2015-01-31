//
//  PlayViewController.h
//  recordTest
//
//  Created by YAO DONG LI on 17/1/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface PlayViewController : UIViewController

@property (nonatomic, strong) NSURL *movieURL;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

@end
