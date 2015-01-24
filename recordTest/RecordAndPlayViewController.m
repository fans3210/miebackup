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
    [previewLayer setFrame:CGRectMake(0, 0, rootLayer.bounds.size.width, rootLayer.bounds.size.height/2)];
    //    [previewLayer setFrame:rootLayer.frame];
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
        
    } else {
        //stop recording
        recording = NO;
        [bStartOrStop setTitle:@"START" forState:UIControlStateNormal];
        bStartOrStop.backgroundColor = [UIColor clearColor];
        
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
    [self performSegueWithIdentifier:@"goToPlay" sender:nil];

//    [self mergeAndSave];
}

- (void) mergeAndSave
{
    NSLog(@"begin merge and save");
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    
    //audio
    NSURL *audioURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"dia" ofType:@"mp3"]];
    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioURL options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [audioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    //video
    NSURL *videoURL = movieOutputURL;
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
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
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
//        NSLog(@"export final composited file complete");
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
