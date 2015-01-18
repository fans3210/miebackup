//
//  RecordAndPlayViewController.m
//  recordTest
//
//  Created by YAO DONG LI on 17/1/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import "RecordAndPlayViewController.h"
#import "PlayViewController.h"

@interface RecordAndPlayViewController ()
{
    BOOL recording;
    AVCaptureDevice *frontCamera;
    
    NSURL *movieOutputURL;
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
        
        
        NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mp4"];
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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PlayViewController *playerVC = [segue destinationViewController];
    playerVC.movieURL = movieOutputURL;
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
