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
    BOOL isCancelledByUser;
    AVCaptureDevice *frontCamera;
    
    NSURL *movieOutputURL;//after record
    NSURL *finalOutputFileURL;// after composition
    AVCaptureSession *session;
    __weak IBOutlet UIButton *bStartOrStop;
    __weak IBOutlet UIView *vPlayAudio;
    __weak IBOutlet UIProgressView *audioProgress;
    __weak IBOutlet UIActivityIndicatorView *indicator;
    __weak IBOutlet UILabel *lbRecordStatus;
    __weak IBOutlet UIView *vInfo;

    NSTimer *timer;
}

@end

@implementation RecordAndPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self prepareForAudioFiles];
    
    
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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    vInfo.hidden = YES;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //stop recording
    if (recording) {
        isCancelledByUser = YES;
        [self stopRecording];
    }
}



- (void) prepareForAudioFiles
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectoryPath = [paths objectAtIndex:0];
    
    NSString *songLocalPath = [_songLocalURL absoluteString];
    NSString *fileNameToBeChecked = [songLocalPath lastPathComponent];
    NSString *filePathToBeChecked = [documentDirectoryPath stringByAppendingPathComponent:fileNameToBeChecked];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePathToBeChecked]) {
        bStartOrStop.hidden = YES;
        [self showRecordStatusWithText:@"Downloading."];
        
        //download song
        NSLog(@"download from audio file %@",[_mAudio.songUrl absoluteString]);
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        NSURLRequest *request = [NSURLRequest requestWithURL:_mAudio.songUrl];
        
        
        
        NSURLSessionDownloadTask *downloadTask = [sessionManager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            
            NSURL *destinationURL = [NSURL fileURLWithPath:[documentDirectoryPath stringByAppendingPathComponent:[response suggestedFilename]]];
            return destinationURL;
            
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            NSLog(@"file downloaded to %@",filePath);
            //        [player url] = filePath;
            NSLog(@"error is %@",error.description);
            bStartOrStop.hidden = NO;
            vInfo.hidden = YES;
        }];
        [downloadTask resume];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)recordOrStop:(id)sender {
    if(!recording) {
        //start recording
        isCancelledByUser = NO;
        [self playAudioWithURL:_songLocalURL];
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
        isCancelledByUser = YES;
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
    if ([self.player isPlaying]) {
        [self.player stop];
    }
}

- (void) playAudioWithURL: (NSURL *)filePath
{
    NSLog(@"basevc player playing");
    if (self.player.isPlaying) {
        [self.player stop];
        return;
    }
    
    AVAudioPlayer *tmpPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:nil];
    tmpPlayer.delegate = self;
    self.player = tmpPlayer;
    
    
    //play audio
    tmpPlayer = nil;
    [self.player prepareToPlay];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0/10 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    [self.player play];
    
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
    if (!isCancelledByUser) {
        [self mergeAndSave];
    }
    
}



- (void) updateProgress
{
    float progress = self.player.currentTime/self.player.duration;
//    NSLog(@"progress is %f",progress);
    [audioProgress setProgress:progress animated:NO];
}

- (void) mergeAndSave
{
    NSLog(@"begin merge and save");
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
//    mixComposition.naturalSize = CGSizeMake(300, 300);

    //calculate time range, should be same as audio one
    NSURL *audioURL = _songLocalURL;
    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioURL options:nil];
    CMTimeRange common_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    
    
    //video
    NSURL *videoURL = movieOutputURL;
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
//    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];

    [videoTrack insertTimeRange:common_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    
    
    /*
     *corp!!!!!
     */
    //create video video compositioninstruction
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);//should be audio duration
    //create video video composition layer instruction
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoAssetTrack];
    
//    videoTrack.preferredTransform = videoAssetTrack.preferredTransform;
    

    
//    CGAffineTransform Scale = CGAffineTransformMakeScale(0.8f,0.8f);
        CGRect screen = [[UIScreen mainScreen] bounds];
/* transforms */
    
    CGAffineTransform Scale;
//    if (IS_IPHONE_5) {
//        //config for 5s
//        NSLog(@"device is iphone 5 or 5s");
//        Scale = CGAffineTransformMakeScale(1.0f,1.0f);
//    } else if (IS_IPHONE_6) {
//        //config for 6
//        NSLog(@"device is iphone 6");
//        Scale = CGAffineTransformMakeScale((375.0/320.0),(375.0/320.0));
//    } else if (IS_IPHONE_6_PLUS) {
//        //config for 6 plus
//        NSLog(@"device is a iphone 6 plus");
//        Scale = CGAffineTransformMakeScale((414.0/320.0),(414.0/320.0));
//    } else
    
//    if (IS_IPHONE_6PLUS_ZOOM) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"功能不可用.请关闭iphone6 plus的放大模式然后重启app" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
//        [alert show];
//    } else {
        Scale = CGAffineTransformMakeScale((screen.size.width/320.0),(screen.size.width/320.0));

//    }
    

    

    
    CGAffineTransform rotationTransform1 = CGAffineTransformMakeRotation(M_PI_2);
    NSLog(@"screen frame %f, %f",screen.size.width, screen.size.height);
    
    CGAffineTransform translateToCenter;
    
//    if (IS_IPHONE_5) {
//        translateToCenter = CGAffineTransformMakeTranslation( -(self.view.frame.size.height - videoAssetTrack.naturalSize.width),-screen.size.width);// this config is for 5s, for 6, need another config after testing
//    } else if(IS_IPHONE_6) {
//        translateToCenter = CGAffineTransformMakeTranslation( -(screen.size.height - videoAssetTrack.naturalSize.width)+(667-568),
//                                                                               -screen.size.width);// this config is for 6, , need another config after testing
//    } else if (IS_IPHONE_6_PLUS) {
//        NSLog(@"config for iphone 6 plus!!");
//        translateToCenter = CGAffineTransformMakeTranslation( -(screen.size.height - videoAssetTrack.naturalSize.width)+(736-568),
//                                                             -screen.size.width);
//    }
    translateToCenter = CGAffineTransformMakeTranslation( -(screen.size.height - videoAssetTrack.naturalSize.width)+(screen.size.height-568),
                                                         -screen.size.width);


    CGAffineTransform finalTransform = CGAffineTransformConcat(Scale, CGAffineTransformConcat(translateToCenter,rotationTransform1));
    [layerInstruction setTransform:finalTransform atTime:kCMTimeZero];
//    [layerInstruction setTransform: videoAssetTrack.preferredTransform atTime:kCMTimeZero];
//    [layerInstruction setTransform:Scale atTime:kCMTimeZero];
    

    
    //watermark
    CATextLayer *titleLayer = [CATextLayer layer];
    titleLayer.string = kWatermark;
    //?? titleLayer.shadowOpacity = 0.5;
    titleLayer.alignmentMode = kCAAlignmentRight;
    titleLayer.foregroundColor = (__bridge CGColorRef)([UIColor whiteColor]);
    titleLayer.frame = CGRectMake(0, 0, screen.size.width/5*4.8, screen.size.width/5);
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, screen.size.width, screen.size.width);
    videoLayer.frame = CGRectMake(0, 0, screen.size.width, screen.size.width);
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
    
    naturalSize = CGSizeMake(screen.size.width, screen.size.width);//square
    
    //make width and height even number to remove green line
    float renderWidth = ((int)naturalSize.width%2==0)?naturalSize.width:naturalSize.width-1;
    float renderHeight = ((int)naturalSize.height%2==0)?naturalSize.width:naturalSize.width-1;
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
    
    exportSession.outputURL = finalOutputFileURL;//composite file url
    
    NSLog(@"movie out put url is %@, final output file url is %@",movieOutputURL, finalOutputFileURL);
    
    exportSession.shouldOptimizeForNetworkUse = YES;

    exportSession.videoComposition = videoCompositionInst; //add video composition to exporter
    
    bStartOrStop.alpha = 0.5;
    bStartOrStop.userInteractionEnabled = NO;
    [self showRecordStatusWithText:@"Processing..."];
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"export final composited file complete no matter succeed or failed");
        NSLog(@"Export Status %ld %@", (long)exportSession.status, exportSession.error);
//        [self performSegueWithIdentifier:@"goToPlay" sender:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            bStartOrStop.alpha = 1;
            bStartOrStop.userInteractionEnabled = YES;
            [self exportDidFinish:exportSession];
        });
    }];
}

- (void) exportDidFinish: (AVAssetExportSession *)exportSession
{
    if (exportSession.status == AVAssetExportSessionStatusCompleted) {
        [self performSegueWithIdentifier:@"goToPlay" sender:nil];
//        NSURL *sessionURL = exportSession.outputURL;
//        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
//        if ([lib videoAtPathIsCompatibleWithSavedPhotosAlbum:sessionURL]) {
//            [lib writeVideoAtPathToSavedPhotosAlbum:sessionURL completionBlock:^(NSURL *assetURL, NSError *error) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (error) {
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"video saving failed" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
//                        [alert show];
//                    } else {
////                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"finished" message:@"video saved" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
////                        [alert show];
//                        NSLog(@"finsihed video saved");
//                        [self performSegueWithIdentifier:@"goToPlay" sender:nil];
//                    }
//                });
//            }];
//        }
        
    }
}

- (void) showRecordStatusWithText: (NSString *)text
{
    lbRecordStatus.text = text;
    vInfo.hidden = NO;
    [indicator startAnimating];
    [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseInOut)animations:^{
        lbRecordStatus.alpha = 0;
    } completion:^(BOOL finished) {
        NSLog(@"haha");
    }];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PlayViewController *playerVC = [segue destinationViewController];
//    playerVC.movieURL = finalOutputFileURL;//final url
    playerVC.movieURL = finalOutputFileURL;//tmp url
    vInfo.hidden = YES;
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
