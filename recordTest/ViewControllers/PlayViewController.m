//
//  PlayViewController.m
//  recordTest
//
//  Created by YAO DONG LI on 17/1/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import "PlayViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <AssetsLibrary/AssetsLibrary.h>


@interface PlayViewController (){
//    MPMoviePlayerController *moviePlayer;
//    MPMoviePlayerViewController *player;
}

@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.title = @"Playing Screen";
    NSLog(@"in play VC already, url is %@",_movieURL.path);
    //play video
    if (_movieURL) {
        _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:_movieURL];
        

        
        _moviePlayer.controlStyle = MPMovieControlStyleDefault;
//        moviePlayer.shouldAutoplay = YES;
//        [moviePlayer setFullscreen:YES animated:YES];

        NSLog(@"navigation bar y is %f, height is %f",self.navigationController.navigationBar.frame.origin.y,self.navigationController.navigationBar.frame.size.height);
        
        [_moviePlayer.view setFrame:CGRectMake(0, self.navigationController.navigationBar.frame.origin.y+self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.width)];
        [self.view addSubview:_moviePlayer.view];
        [self.view bringSubviewToFront:_moviePlayer.view];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish) name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer];
        [_moviePlayer play];
//        _moviePlayer.shouldAutoplay = YES;


        
    }
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_moviePlayer stop];
}
- (IBAction)savePressed:(id)sender {
    NSURL *sessionURL = _movieURL;
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
                    NSLog(@"finsihed video saved");
                }
            });
        }];
    }
}

- (IBAction)playVideo:(id)sender {
    
//    [_moviePlayer play];
    
    //tst share
//    id<ISSCAttachment> video = [ShareSDK imageWithUrl:[_movieURL absoluteString]];
    NSLog(@"video url absolute string is %@",[_movieURL absoluteString]);
    id<ISSContent> publishContent = [ShareSDK content:@"咩拍"
                                       defaultContent:@"咩拍"
                                                image:nil
                                                title:@"欢迎使用咩拍"
                                                  url:[_movieURL absoluteString]
                                          description:@"这是一条测试信息"
                                            mediaType:SSPublishContentMediaTypeImage];
    
    
//    [publishContent addWeixinSessionUnitWithType:[NSNumber numberWithInt:4] content:nil title:nil url:[_movieURL absoluteString] image:nil musicFileUrl:[_movieURL absoluteString] extInfo:nil fileData:[NSData dataWithContentsOfFile:[_movieURL absoluteString]] emoticonData:nil];
    
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    
    
    [ShareSDK showShareActionSheet:container
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess) {
                                    NSLog(@"share succeed");
                                } else if (state == SSResponseStateFail) {
                                    NSLog(@"share failed error is %@",error.description);
                                }
                            }];
}

- (void) moviePlayBackDidFinish
{
    NSLog(@"movie play finished");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
