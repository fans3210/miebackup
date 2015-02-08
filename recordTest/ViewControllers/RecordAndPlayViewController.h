//
//  RecordAndPlayViewController.h
//  recordTest
//
//  Created by YAO DONG LI on 17/1/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import "BaseViewController.h"
#import "Audio.h"
#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
@interface RecordAndPlayViewController : BaseViewController<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) NSURL *songLocalURL;
@property (nonatomic, strong) Audio *mAudio;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;

@end
