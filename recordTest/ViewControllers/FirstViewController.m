//
//  FirstViewController.m
//  recordTest
//
//  Created by YAO DONG LI on 24/1/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import "FirstViewController.h"
#import "WanwanStyleCell.h"
#import <SWRevealViewController/SWRevealViewController.h>

@interface FirstViewController () {
    NSArray *cellModels;
    NSTimeInterval duration;//animation duration
    __weak IBOutlet UIButton *bMie;
    __weak IBOutlet UICollectionView *cvWanwan;


}

@end

@implementation FirstViewController

//- (instancetype)init {
//    if (self == [super init]) {
//        NSLog(@"first VC init method");
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"in first launch vc");
    duration = 1.5;
    
    cellModels = @[@"我想起那天夕阳下的奔跑。。。",
                   @"那是我逝去的青春。。。",
                   @"我要放声歌唱。。"];
    
    //set mie button boarder and style
    bMie.layer.borderWidth = 1.0;
    bMie.layer.borderColor = [UIColor whiteColor].CGColor;
    
    if (IS_IPHONE_6 || IS_IPHONE_6_PLUS) {
        bMie.layer.cornerRadius = bMie.frame.size.height/3.5;
    } else {
        bMie.layer.cornerRadius = bMie.frame.size.height/4.5;
    }

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

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    
    int page = (scrollView.contentOffset.x - pageWidth/2)/pageWidth + 1;
    NSLog(@"fpage = %d", page);
    if (page == 2) {
//        bMie.alpha = 1;
            //pop up the button
            bMie.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
            bMie.alpha = 1;
            scrollView.userInteractionEnabled = NO;
            [UIView animateWithDuration:0.3/1.5 delay:1.5 options:UIViewAnimationOptionTransitionNone animations:^{
                bMie.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
                bMie.userInteractionEnabled = NO;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/2 animations:^{
                    bMie.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9 , 0.9);

                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3/2 animations:^{
                        bMie.transform = CGAffineTransformIdentity;
                        bMie.userInteractionEnabled = YES;
                    }];
                }];
            }];
    } else {
        bMie.alpha = 0;
    }


}

- (IBAction)miePressed:(UIButton *)sender {
    NSLog(@"miemie");
    UIStoryboard *storyboard = [self storyboard];
    SWRevealViewController *mainRVC = [storyboard instantiateViewControllerWithIdentifier:@"mainReveal"];
    mainRVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:mainRVC animated:YES completion:^{
        NSLog(@"go to main vc already");
    }];
}

#pragma cv delegate methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return cellModels.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(cvWanwan.frame.size.width, cvWanwan.frame.size.height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WanwanStyleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"wanwanStyleCell" forIndexPath:indexPath];
    cell.lbTxt.text = cellModels[indexPath.row];
    cell.lbTxt.alpha = 0;
    [UIView animateWithDuration:duration animations:^{
        cell.lbTxt.alpha = 1;
        collectionView.userInteractionEnabled = NO;
    } completion:^(BOOL finished) {
        NSLog(@"animation complete");
        if (indexPath.row != 2) {
            //if not last page
            collectionView.userInteractionEnabled = YES;
//            cell.lbSlideRight.hidden = NO;
            //move lbslide position to left most first, out side screen
            CGRect frame = cell.lbSlideRight.frame;
            frame.origin.x -= [UIScreen mainScreen].bounds.size.width;
            cell.lbSlideRight.frame = frame;
            [UIView animateWithDuration:0.3 animations:^{
                cell.lbSlideRight.hidden = NO;
                CGRect frame = cell.lbSlideRight.frame;
                frame.origin.x += [UIScreen mainScreen].bounds.size.width;
                cell.lbSlideRight.frame = frame;
            }];
        }

    }];
    

    return cell;
}


@end
