//
//  Audio.h
//  mie
//
//  Created by YAO DONG LI on 2/2/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import "MBase.h"

typedef enum
{
    NOTDOWNLOADED,
    DOWNLOADING,
    READY,
    PLAYING
} AudioState;

@interface Audio : MBase

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *songUrl;
//@property (nonatomic, strong) NSURL *localFileUrl;
@property (nonatomic) AudioState audioState;

- (instancetype) initWithAudioAVObject: (AVObject *)avObj;

@end
