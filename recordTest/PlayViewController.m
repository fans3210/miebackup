//
//  PlayViewController.m
//  recordTest
//
//  Created by YAO DONG LI on 17/1/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import "PlayViewController.h"


@interface PlayViewController (){
//    MPMoviePlayerController *moviePlayer;
//    MPMoviePlayerViewController *player;
}

@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Playing Screen";
    NSLog(@"in play VC already, url is %@",_movieURL.path);
    
    //play video
    if (_movieURL) {
        _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:_movieURL];
        

        
        _moviePlayer.controlStyle = MPMovieControlStyleDefault;
//        moviePlayer.shouldAutoplay = YES;
//        [moviePlayer setFullscreen:YES animated:YES];

        [_moviePlayer.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2)];
        [self.view addSubview:_moviePlayer.view];
        [self.view bringSubviewToFront:_moviePlayer.view];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish) name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer];
        [_moviePlayer play];
//        _moviePlayer.shouldAutoplay = YES;


        
    }
    
}
- (IBAction)playVideo:(id)sender {
    
    [_moviePlayer play];
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
