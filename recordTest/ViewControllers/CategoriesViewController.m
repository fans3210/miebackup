//
//  CategoriesViewController.m
//  recordTest
//
//  Created by YAO DONG LI on 29/1/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import "CategoriesViewController.h"
#import <BmobSDK/Bmob.h>
#import "AudiosViewController.h"

@interface CategoriesViewController () {
    NSMutableArray *cellModelsCat;
    NSMutableArray *cellModelsAud;
    __weak IBOutlet UITableView *tvCat;
    __weak IBOutlet UIActivityIndicatorView *indicator;
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
    //set refresh indicator
    tvCat.hidden = YES;
    [indicator startAnimating];

}
- (IBAction)test:(id)sender {
    NSLog(@"tst button");
    [self loadAllCategories];
}

- (void) loadAllCategories
{
    BmobQuery *queryCategories = [BmobQuery queryWithClassName:kCategory];
    [queryCategories findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        cellModelsCat = [NSMutableArray arrayWithArray:array];
        [tvCat reloadData];
        tvCat.hidden = NO;
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    BmobObject *bmobCat = cellModelsCat[indexPath.row];
    UILabel *lbTitle = (UILabel *)[cell viewWithTag:2];
    lbTitle.text = (NSString *)[bmobCat objectForKey:kCategoryName];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BmobObject *bmobCat = cellModelsCat[indexPath.row];
    BmobQuery *audioQuery = [BmobQuery queryWithClassName:kAudio];
    [audioQuery whereObjectKey:kAudioFIles relatedTo:bmobCat];

    [audioQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        NSLog(@"error is %@",error);
//        for (BmobObject *obj in array) {
//            NSLog(@"get obj is %@",[obj objectForKey:kAudioTitle]);
//        }
        if (array.count > 0) {
            cellModelsAud = [NSMutableArray arrayWithArray:array];
            [self performSegueWithIdentifier:@"goToAudios" sender:tableView];
        }

    }];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AudiosViewController *audiosVC = [segue destinationViewController];
    audiosVC.Audios = cellModelsAud;
}


@end
