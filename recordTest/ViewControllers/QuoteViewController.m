//
//  QuoteViewController.m
//  recordTest
//
//  Created by YAO DONG LI on 2/2/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import "QuoteViewController.h"
#import <AVOSCloud/AVOSCloud.h>
#import <SWRevealViewController.h>

@interface QuoteViewController () {
    
    __weak IBOutlet UITextView *tvQuote;
    NSString *todaysQuote;
}

@end

@implementation QuoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"quote vc, view did load");
    tvQuote.layer.borderWidth = 1.0;
    tvQuote.layer.borderColor = [UIColor whiteColor].CGColor;
    tvQuote.layer.cornerRadius = 20;
    AVQuery *queryQuote = [AVQuery queryWithClassName:kTodaysQuote];
    queryQuote.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [queryQuote findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"error in find quote, error is %@",error);
            tvQuote.text = @"速度成就男人 ——雍正";
        } else {
            NSMutableArray *quotes = [NSMutableArray arrayWithArray:objects];
            if (quotes && quotes.count > 0) {
                AVObject *avQuote = [quotes firstObject];
                todaysQuote = [avQuote objectForKey:kQuote];
                tvQuote.text = todaysQuote;
            } else {
                tvQuote.text = @"速度成就男人 ——雍正";
            }
        }
    }];
}

- (IBAction)backToMainPressed:(id)sender {
        [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
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
