//
//  RecordAndPlayViewController.m
//  recordTest
//
//  Created by YAO DONG LI on 17/1/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import "RecordAndPlayViewController.h"
#import "PlayViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface RecordAndPlayViewController ()
{
    BOOL recording;
    AVCaptureDevice *frontCamera;
    
    NSURL *movieOutputURL;//after record
    NSURL *finalOutputFileURL;// after composition
    AVCaptureSession *session;
    __weak IBOutlet UIButton *bStartOrStop;
}
@property (nonatomic, strong) AVAudioPlayer *player;
@end

@implementation RecordAndPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //get front camera capture device
    NSArray *devices = [AVCaptureDevice devices];
    for(AVCaptureDevice *device in devices) {
        if (device.position == AVCaptureDevicePositionFront) {
            frontCamera = device;
        }
    }
    
    
    session = [[AVCaptureSession alloc] init];
    [session beginConfiguration];

    [session setSessionPreset:AVCaptureSessionPresetMedium];
    
    //    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    
    NSError *error = nil;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
    
    if ([session canAddInput:deviceInput]) {
        NSLog(@"add device input");
        [session addInput:deviceInput];
    }
    
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];

    
    CALayer *rootLayer = self.view.layer;
    //    [rootLayer setMasksToBounds:YES];
    [previewLayer setFrame:CGRectMake(0, 0, rootLayer.bounds.size.width, 0+bStartOrStop.frame.origin.y - 50)];
    //    [previewLayer setFrame:rootLayer.frame];
//    previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [rootLayer addSublayer:previewLayer];
    
    
    //set path for file
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentPath = [paths objectAtIndex:0];
    _movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
//    NSString *archivePath = [documentPath stringByAppendingPathComponent:@"archives"];
//    
//    NSString *movieOutputPath = [[archivePath stringByAppendingPathComponent:@"Test"] stringByAppendingString:@".mov"];
//    movieOutputURL = [[NSURL alloc] initFileURLWithPath:movieOutputPath];
    if ([session canAddOutput:_movieFileOutput]) {
        NSLog(@"add movie file output");
        [session addOutput:_movieFileOutput];

    }
    [session commitConfiguration];
    [session startRunning];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)recordOrStop:(id)sender {
    if(!recording) {
        //start recording
        recording = YES;
        [bStartOrStop setTitle:@"STOP" forState:UIControlStateNormal];
        bStartOrStop.backgroundColor = [UIColor redColor];
        
        
        NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
        NSURL *testoutputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:outputPath])
        {
            NSError *error;
            if ([fileManager removeItemAtPath:outputPath error:&error] == NO)
            {
                //Error - handle if requried
            }
        }
        
        movieOutputURL = testoutputURL;
        
        [self.movieFileOutput startRecordingToOutputFileURL:movieOutputURL recordingDelegate:self];
        [self playAudioWithURL:_songURL];
        
    } else {
        //stop recording
        recording = NO;
        [bStartOrStop setTitle:@"START" forState:UIControlStateNormal];
        bStartOrStop.backgroundColor = [UIColor blueColor];
        bStartOrStop.tintColor = [UIColor whiteColor];
    
        [self.movieFileOutput stopRecording];
        //        [self performSegueWithIdentifier:@"goToPlayVC" sender:sender];
        
        
    }
}



#pragma mark cameara delegate
- (void) captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    NSLog(@"did start recording at url %@ from connectsions count %lu",[fileURL path],(unsigned long)connections.count);
}

- (void) captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    NSLog(@"did finish recording, error is %@",[error description]);
//    [self performSegueWithIdentifier:@"goToPlay" sender:nil];

    [self mergeAndSave];
}

- (void) playAudioWithURL: (NSURL *)filePath
{
    if (_player.isPlaying) {
        [_player stop];
        return;
    }
    
    AVAudioPlayer *tmpPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:nil];
    _player = tmpPlayer;
    
    
    //play audio
    tmpPlayer = nil;
    [_player prepareToPlay];
    [_player play];
    
}

- (void) mergeAndSave
{
    NSLog(@"begin merge and save");
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
//    mixComposition.naturalSize = CGSizeMake(300, 300);

    //video
    NSURL *videoURL = movieOutputURL;
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];

    [videoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    
//    //rotate the composite video, to be portrait
//    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(M_PI_2);
//    videoTrack.preferredTransform = rotationTransform;
    
    
    /*
     *corp!!!!!
     */
    //create video video compositioninstruction
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    //create video video composition layer instruction
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoAssetTrack];
    
    //new rotate methods
    UIImageOrientation videoAssetOrientation = UIImageOrientationUp;
    BOOL isVideoAssetPortrait = NO;
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        videoAssetOrientation = UIImageOrientationRight;
        isVideoAssetPortrait = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        videoAssetOrientation = UIImageOrientationLeft;
        isVideoAssetPortrait = YES;
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation = UIImageOrientationUp;
    }
    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        videoAssetOrientation = UIImageOrientationDown;
    }
    
    CGAffineTransform Scale = CGAffineTransformMakeScale(0.8f,0.8f);
    CGAffineTransform translateToCenter = CGAffineTransformMakeTranslation( 0,-320);
    CGAffineTransform rotationTransform1 = CGAffineTransformMakeRotation(M_PI_2);
    [layerInstruction setTransform:CGAffineTransformConcat(Scale, CGAffineTransformConcat(translateToCenter,rotationTransform1))  atTime:kCMTimeZero];
    
    //.......
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    AVMutableVideoComposition *videoCompositionInst = [AVMutableVideoComposition videoComposition];
    videoCompositionInst.instructions = [NSArray arrayWithObject:instruction];
    videoCompositionInst.frameDuration = CMTimeMake(1, 30);//looks like setting framerate to be 30
    
    CGSize naturalSize;
//    if (isVideoAssetPortrait) {
//
//        naturalSize = videoAssetTrack.naturalSize;
//    } else {
//            naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
//    }
    naturalSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height/2);
    
    float renderWidth = naturalSize.width;
    float renderHeight = naturalSize.height;
    videoCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
    
    NSURL *audioURL = _songURL;
    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioURL options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    [audioTrack insertTimeRange:audio_timeRange ofTrack: audioAssetTrack atTime:kCMTimeZero error:nil];
    
    
    
    //path of compisited video
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [dirPaths objectAtIndex:0];
    NSString *finalOutputPath = [docDir stringByAppendingPathComponent:@"Final.mov"];
    finalOutputFileURL = [NSURL fileURLWithPath:finalOutputPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:finalOutputPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:finalOutputPath error:nil];
    }
    
    //avasset export session
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];

    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.outputURL = finalOutputFileURL;
    exportSession.shouldOptimizeForNetworkUse = YES;

    exportSession.videoComposition = videoCompositionInst; //add video composition to exporter
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"export final composited file complete no matter succeed or failed");
        NSLog(@"Export Status %ld %@", exportSession.status, exportSession.error);
//        [self performSegueWithIdentifier:@"goToPlay" sender:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self exportDidFinish:exportSession];
        });
    }];
}

- (void) exportDidFinish: (AVAssetExportSession *)exportSession
{
    if (exportSession.status == AVAssetExportSessionStatusCompleted) {
        NSURL *sessionURL = exportSession.outputURL;
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        if ([lib videoAtPathIsCompatibleWithSavedPhotosAlbum:sessionURL]) {
            [lib writeVideoAtPathToSavedPhotosAlbum:sessionURL completionBlock:^(NSURL *assetURL, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"video saving failed" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                        [alert show];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"finished" message:@"video saved" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                });
            }];
        }
        
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PlayViewController *playerVC = [segue destinationViewController];
//    playerVC.movieURL = finalOutputFileURL;//final url
    playerVC.movieURL = movieOutputURL;//tmp url
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
