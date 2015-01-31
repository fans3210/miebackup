//
//  RecordAndPlayViewController.h
//  recordTest
//
//  Created by YAO DONG LI on 17/1/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
@interface RecordAndPlayViewController : UIViewController<AVCaptureFileOutputRecordingDelegate, AVAudioPlayerDelegate>

@property (nonatomic, strong) NSURL *songURL;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;

@end
