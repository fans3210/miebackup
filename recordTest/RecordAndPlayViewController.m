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
    __weak IBOutlet UIView *vPlayAudio;
    __weak IBOutlet UIProgressView *audioProgress;
    NSTimer *timer;
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
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];

    
    CALayer *rootLayer = self.view.layer;
    //    [rootLayer setMasksToBounds:YES];
    [previewLayer setFrame:CGRectMake(0, vPlayAudio.frame.origin.y/2 + vPlayAudio.frame.size.height + 1, rootLayer.bounds.size.width, rootLayer.bounds.size.width)];
    //    [previewLayer setFrame:rootLayer.frame];

    [rootLayer addSublayer:previewLayer];
    
    

    _movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    if ([session canAddOutput:_movieFileOutput]) {
        NSLog(@"add movie file output");
        [session addOutput:_movieFileOutput];

    }
    
    AVCaptureConnection *videoConnection = nil;
    
//    for ( AVCaptureConnection *connection in [_movieFileOutput connections] )
//    {
//        NSLog(@"%@", connection);
//        for ( AVCaptureInputPort *port in [connection inputPorts] )
//        {
//            NSLog(@"%@", port);
//            if ( [[port mediaType] isEqual:AVMediaTypeVideo] )
//            {
//                videoConnection = connection;
//            }
//        }
//    }
    videoConnection = [_movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if([videoConnection isVideoOrientationSupported]) // **Here it is, its always false**
    {
        [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
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
        [self playAudioWithURL:_songURL];
        recording = YES;
        [bStartOrStop setTitle:@"Cancel" forState:UIControlStateNormal];
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
        
        
    } else {
        //stop recording
        [self stopRecording];
        
        
    }
}

- (void) stopRecording
{
    //ui change
    recording = NO;
    [bStartOrStop setTitle:@"START" forState:UIControlStateNormal];
    bStartOrStop.backgroundColor = [UIColor blueColor];
    bStartOrStop.tintColor = [UIColor whiteColor];
    [timer invalidate];
    timer = nil;
    [audioProgress setProgress:0.0 animated:NO];
    
    //stop movie recording session
    [self.movieFileOutput stopRecording];
    
    //stop playing audio
    if (_player.isPlaying) {
        [_player stop];
    }
}

#pragma audio player delegate
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"audio player did finish playing");
    [timer invalidate];
    timer = nil;
    [self stopRecording];
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

//    [self mergeAndSave];
}

- (void) playAudioWithURL: (NSURL *)filePath
{
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
    [audioProgress setProgress:0.0];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0/10 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    [_player play];
    
}

- (void) updateProgress
{
    float progress = _player.currentTime/_player.duration;
    NSLog(@"progress is %f",progress);
    [audioProgress setProgress:progress animated:NO];
}

- (void) mergeAndSave
{
    NSLog(@"begin merge and save");
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
//    mixComposition.naturalSize = CGSizeMake(300, 300);

    //calculate time range, should be same as audio one
    NSURL *audioURL = _songURL;
    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioURL options:nil];
    CMTimeRange common_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    
    
    //video
    NSURL *videoURL = movieOutputURL;
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
//    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];

    [videoTrack insertTimeRange:common_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    
//    //rotate the composite video, to be portrait
//    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(M_PI_2);
//    videoTrack.preferredTransform = rotationTransform;
    
    
    /*
     *corp!!!!!
     */
    //create video video compositioninstruction
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);//should be audio duration
    //create video video composition layer instruction
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoAssetTrack];
    
//    //new rotate methods
//    UIImageOrientation videoAssetOrientation = UIImageOrientationUp;
//    BOOL isVideoAssetPortrait = NO;
//    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
//    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
//        videoAssetOrientation = UIImageOrientationRight;
//        isVideoAssetPortrait = YES;
//    }
//    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
//        videoAssetOrientation = UIImageOrientationLeft;
//        isVideoAssetPortrait = YES;
//    }
//    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
//        videoAssetOrientation = UIImageOrientationUp;
//    }
//    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
//        videoAssetOrientation = UIImageOrientationDown;
//    }
    
//    CGAffineTransform Scale = CGAffineTransformMakeScale(0.8f,0.8f);
    CGAffineTransform Scale = CGAffineTransformMakeScale(1.0f,1.0f);
    
    CGAffineTransform rotationTransform1 = CGAffineTransformMakeRotation(M_PI_2);
    NSLog(@"self view frame %f, %f",self.view.frame.size.width, self.view.frame.size.height);
    
    CGAffineTransform translateToCenter = CGAffineTransformMakeTranslation( -(self.view.frame.size.height - videoAssetTrack.naturalSize.width),-self.view.frame.size.width + 0);// this config is for 5s, for 6, need another config after testing
    
    CGAffineTransform finalTransform = CGAffineTransformConcat(Scale, CGAffineTransformConcat(translateToCenter,rotationTransform1));
    
    [layerInstruction setTransform: finalTransform atTime:kCMTimeZero];
    
    //watermark
    CATextLayer *titleLayer = [CATextLayer layer];
    titleLayer.string = @"@咩拍";
    //?? titleLayer.shadowOpacity = 0.5;
    titleLayer.alignmentMode = kCAAlignmentRight;
    titleLayer.foregroundColor = (__bridge CGColorRef)([UIColor blackColor]);
    titleLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width/5);
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width);
    videoLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:titleLayer]; //ONLY IF WE ADDED TEXT
    
    //.......
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    AVMutableVideoComposition *videoCompositionInst = [AVMutableVideoComposition videoComposition];
    videoCompositionInst.instructions = [NSArray arrayWithObject:instruction];
    videoCompositionInst.frameDuration = CMTimeMake(1, 24);//looks like setting framerate to be 30
    
    CGSize naturalSize;
//    if (isVideoAssetPortrait) {
//
//        naturalSize = videoAssetTrack.naturalSize;
//    } else {
//            naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
//    }
    
    CGSize tmpNaturalSize = videoAssetTrack.naturalSize;
    NSLog(@"tmp natural size is %f, %f",tmpNaturalSize.width, tmpNaturalSize.height);
    
    naturalSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.width);//square
    
    float renderWidth = naturalSize.width;
    float renderHeight = naturalSize.height;
    videoCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
    
    //add watermark
    videoCompositionInst.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    
    //audio
//    NSURL *audioURL = _songURL;
//    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioURL options:nil];
//    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    [audioTrack insertTimeRange:common_timeRange ofTrack: audioAssetTrack atTime:kCMTimeZero error:nil];
    
    
    
    //path of compisited video
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [dirPaths objectAtIndex:0];
    NSString *finalOutputPath = [docDir stringByAppendingPathComponent:@"Final.mov"];
    finalOutputFileURL = [NSURL fileURLWithPath:finalOutputPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:finalOutputPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:finalOutputPath error:nil];
    }
    
    //avasset export session
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];

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
