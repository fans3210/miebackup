//
//  CategoriesViewController.m
//  recordTest
//
//  Created by YAO DONG LI on 29/1/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import "CategoriesViewController.h"
#import "AudiosViewController.h"
#import <AVOSCloud/AVOSCloud.h>
#import <SWRevealViewController.h>

@interface CategoriesViewController () {
    NSMutableArray *cellModelsCat;
    NSMutableArray *cellModelsAud;
    AudioCat *chosenCat;
    
    __weak IBOutlet UITableView *tvCat;
    __weak IBOutlet UIActivityIndicatorView *indicator;
    __weak IBOutlet UIBarButtonItem *revealButtonItem;
    
}

@end

@implementation CategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self loadAllCategories];

//    //sample find audio from a category
//    BmobObject *testBmobCategory = [BmobObject objectWithoutDatatWithClassName:@"Category" objectId:@"KSyA555n"];
//    BmobQuery *bQuery = [BmobQuery queryWithClassName:@"Audio"];
//    [bQuery whereObjectKey:@"audioFiles" relatedTo:testBmobCategory];
//    
//    [bQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
//        NSLog(@"error is %@",error);
//        NSLog(@"array is %@",array);
//        for (BmobObject *obj in array) {
//            NSLog(@"get obj is %@",[obj objectForKey:kAudioTitle]);
//        }
////        [self.tableView reloadData];
//    }];
}

- (void) setUpUI
{
    //config revealvc
    self.revealViewController.rearViewRevealOverdraw = 60 + ([UIScreen mainScreen].bounds.size.width-320); //default is 60, we set it larger to make it can fulfil the iphone 6 plus screen
    
    //set refresh indicator
    tvCat.hidden = YES;
    [indicator startAnimating];

}

- (IBAction)testReveal:(id)sender
{
    
    [self.revealViewController setFrontViewPosition:FrontViewPositionRightMost animated:YES];
}

- (IBAction)test:(id)sender {
    NSLog(@"tst button");
    [self loadAllCategories];
}

- (void) loadAllCategories
{
//    BmobQuery *queryCategories = [BmobQuery queryWithClassName:kCategory];
//    [queryCategories findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
//        cellModelsCat = [NSMutableArray arrayWithArray:array];
//        [tvCat reloadData];
//        tvCat.hidden = NO;
//    }];
    
    AVQuery *queryCategories = [AVQuery queryWithClassName:kCategory];
    queryCategories.cachePolicy = kPFCachePolicyCacheElseNetwork;
    
    //设置缓存有效期
    queryCategories.maxCacheAge = 24*60*60;
    
    [queryCategories findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"error in find cateogries, error is %@",error);
        } else {
            cellModelsCat = [NSMutableArray arrayWithArray:objects];
            [tvCat reloadData];
            tvCat.hidden = NO;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return cellModelsCat.count;
}

//- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    AVObject *avoCat = cellModelsCat[indexPath.row];
    UILabel *lbTitle = (UILabel *)[cell viewWithTag:2];
    lbTitle.text = (NSString *)[avoCat objectForKey:kCategoryName];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    chosenCat = cellModelsCat[indexPath.row];
    [self performSegueWithIdentifier:@"goToAudios" sender:tableView];

    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AudiosViewController *audiosVC = [segue destinationViewController];
    audiosVC.audioCat = chosenCat;
}


@end
