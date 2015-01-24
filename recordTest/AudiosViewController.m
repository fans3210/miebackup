//
//  AudiosViewController.m
//  recordTest
//
//  Created by YAO DONG LI on 24/1/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import "AudiosViewController.h"
#import <BmobSDK/Bmob.h>


@interface AudiosViewController ()

@end

@implementation AudiosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"in audio VC");
    BmobQuery *bQuery = [BmobQuery queryWithClassName:@"Audio"];

    
    [bQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        for (BmobObject *obj in array) {
            NSLog(@"get obj title is %@",[obj objectForKey:kAudioTitle]);
            NSLog(@"get obj url is %@",[[obj objectForKey:kAudioFile] url]);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
