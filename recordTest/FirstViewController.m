//
//  FirstViewController.m
//  recordTest
//
//  Created by YAO DONG LI on 24/1/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import "FirstViewController.h"
#import "WanwanStyleCell.h"

@interface FirstViewController () {
    NSArray *cellModels;
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
    cellModels = @[@"我想起那天夕阳下的奔跑。。。",
                   @"那是我逝去的青春。。。",
                   @"我要放声歌唱。。"];

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
        bMie.alpha = 1;
    } else {
        bMie.alpha = 0;
    }


}


#pragma cv delegate methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return cellModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WanwanStyleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"wanwanStyleCell" forIndexPath:indexPath];
    cell.lbTxt.text = cellModels[indexPath.row];
    

    return cell;
}


@end
