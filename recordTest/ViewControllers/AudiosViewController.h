//
//  AudiosViewController.h
//  mie
//
//  Created by YAO DONG LI on 24/1/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import "BaseViewController.h"
#import "AudioCat.h"

@interface AudiosViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) AudioCat *audioCat;
@end
