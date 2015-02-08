//
//  AudiosViewController.m
//  recordTest
//
//  Created by YAO DONG LI on 24/1/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import "AudiosViewController.h"
#import "RecordAndPlayViewController.h"
#import "AudioFileCell.h"
#import "Audio.h"

@interface AudiosViewController () {
    NSMutableArray *cellModels;
    __weak IBOutlet UITableView *tvAudios;
    __weak IBOutlet UIActivityIndicatorView *indicator;
    NSURL *chosenAudioLocalUrl;
    Audio *chosenAudio;//if next vc not able to play, download using this audio
    
}

@end


@implementation AudiosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"in audio VC");
    tvAudios.hidden = YES;
    [indicator startAnimating];
    [self loadAudios];
}

- (void) loadAudios
{
    cellModels = [NSMutableArray array];
    AVQuery *audiosQuery = [AVQuery queryWithClassName:kAudio];
    audiosQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
    audiosQuery.maxCacheAge = 24*60*60;
    [audiosQuery whereKey:kFromCategory equalTo:_audioCat];
    [audiosQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"error!!");
        } else {
            if (objects.count > 0) {
                cellModels = [NSMutableArray array];

                for (int i=0; i<objects.count; i++) {
                    AVObject *avObj = (AVObject *)[objects objectAtIndex:i];
                    Audio *mAudio = [[Audio alloc] initWithAudioAVObject:avObj];
                    [cellModels addObject:mAudio];
                    NSLog(@"audio state is %d",mAudio.audioState);
                }
                [tvAudios reloadData];
                tvAudios.hidden = NO;
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma tv delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cellModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AudioFileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AudioFileCell" forIndexPath:indexPath];
//    AVObject *avObj = cellModels[indexPath.row];
    Audio *mAudio = cellModels[indexPath.row];
    cell.lbTitle.text = mAudio.title;
    cell.bPlay.tag = indexPath.row;
    [cell.bPlay addTarget:self action:@selector(goPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}
//{
//            AudioFileCell *cell = (AudioFileCell *)[tableView cellForRowAtIndexPath:indexPath];
//    NSLog(@"select index path %li",indexPath.row);
//    NSLog(@"cell label is %@",cell.lbTitle.text);
//
//}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    AudioFileCell *cell = (AudioFileCell *)[tableView cellForRowAtIndexPath:indexPath];
//    AVObject *avObj = cellModels[indexPath.row];
    Audio *mAudio = cellModels[indexPath.row];
    NSString *songName = mAudio.title;
    NSURL *songURL = mAudio.songUrl;
    
    
    //check whether file exists
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectoryPath = [paths objectAtIndex:0];
    
    NSString *fileNameToBeChecked = [songURL lastPathComponent];
    NSString *filePathToBeChecked = [documentDirectoryPath stringByAppendingPathComponent:fileNameToBeChecked];
    
    chosenAudioLocalUrl = [NSURL fileURLWithPath:[documentDirectoryPath stringByAppendingPathComponent:fileNameToBeChecked]];
    chosenAudio = mAudio;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePathToBeChecked]) {
        NSLog(@"file: %@ exists already", filePathToBeChecked);
        NSURL *filePath = [NSURL URLWithString:filePathToBeChecked];
        [self playAudioWithURL:filePath];
    } else {
        //file not exists, need to download
        //download audio file mp3

//        cell.indicator.hidden = NO;
        [tableView reloadData];
        NSLog(@"download file %@ with link:%@", songName, songURL);
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        NSURLRequest *request = [NSURLRequest requestWithURL:songURL];
        NSURLSessionDownloadTask *downloadTask = [sessionManager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            
            NSURL *destinationURL = [NSURL fileURLWithPath:[documentDirectoryPath stringByAppendingPathComponent:[response suggestedFilename]]];
            return destinationURL;
            
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            NSLog(@"file downloaded to %@",filePath);
            //        [player url] = filePath;
            NSLog(@"error is %@",error.description);

            
//            cell.indicator.hidden = YES;
            [tableView reloadData];
            [self playAudioWithURL:filePath];
        }];
        [downloadTask resume];
    }
}


- (void) goPressed: (UIButton *)sender
{
    
    NSLog(@"go pressed at %li",(long)sender.tag);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectoryPath = [paths objectAtIndex:0];
//    AVObject *avObj = cellModels[sender.tag];
//    AVFile *songFile = [avObj objectForKey:kAudioFileMp3];
//    NSString *songURL = songFile.url;
    Audio *mAudio = cellModels[sender.tag];
    NSString *songURL = [mAudio.songUrl absoluteString];
    NSString *fileNameToBeChecked = [songURL lastPathComponent];

    chosenAudioLocalUrl = [NSURL fileURLWithPath:[documentDirectoryPath stringByAppendingPathComponent:fileNameToBeChecked]];
    chosenAudio = mAudio;
    
    [self performSegueWithIdentifier:@"goToRecord" sender:sender];
}



- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //stop player
    if ([self.player isPlaying]) {
        [self.player stop];
    }
    
    self.navigationItem.title = @"";
    RecordAndPlayViewController *recordVC = [segue destinationViewController];
    recordVC.songLocalURL = chosenAudioLocalUrl;
    recordVC.mAudio = chosenAudio;
}



@end