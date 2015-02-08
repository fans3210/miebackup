//
//  BaseViewController.m
//  recordTest
//
//  Created by YAO DONG LI on 30/1/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //stop playing audio
    if ([self.player isPlaying]) {
        [self.player stop];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) playAudioWithURL: (NSURL *)filePath
{
    NSLog(@"basevc player playing");
    if (_player.isPlaying) {
        [_player stop];
        return;
    }
    
    AVAudioPlayer *tmpPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:nil];
    tmpPlayer.delegate = self;
    _player = tmpPlayer;

    
    //play audio
    tmpPlayer = nil;
    [_player prepareToPlay];
    [_player play];
    
}




#pragma audio player delegate
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"basevc delegate audio player did finish playing, successfully %d",flag);

}

@end
