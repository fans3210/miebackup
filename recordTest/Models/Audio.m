//
//  Audio.m
//  recordTest
//
//  Created by YAO DONG LI on 2/2/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import "Audio.h"

@implementation Audio

- (instancetype) initWithAudioAVObject: (AVObject *)avObj
{
    if (self == [super init]) {
        self.title = [avObj objectForKey:kAudioTitle];
        AVFile *songFile = [avObj objectForKey:kAudioFileMp3];
        NSString *songURL = songFile.url;
        self.songUrl = [NSURL URLWithString:songURL];

    }
    
    return self;
}

@end
