//
//  MieAPI.m
//  mie
//
//  Created by YAO DONG LI on 7/4/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import "MieAPI.h"
#import "AudioManager.h"

@implementation MieAPI {
    AudioManager *audioManager;
}

+ (MieAPI *)sharedAPI
{
    static MieAPI *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[MieAPI alloc] init];
    });
    
    
    return sharedInstance;
}

- (instancetype) init
{
    if (self == [super init]) {
        audioManager = [[AudioManager alloc] init];
    }
    return self;
}

@end
