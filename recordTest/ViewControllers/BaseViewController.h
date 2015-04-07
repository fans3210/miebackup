//
//  BaseViewController.h
//  mie
//
//  Created by YAO DONG LI on 30/1/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking.h>
#import <AVFoundation/AVFoundation.h>

@interface BaseViewController : UIViewController<AVAudioPlayerDelegate>
@property (nonatomic, strong) AVAudioPlayer *player;

- (void) playAudioWithURL: (NSURL *)filePath;
@end
