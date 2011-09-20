//
//  MessageViewController.h
//  TWeiBo
//
//  Created by 健锋 章 on 11-8-20.
//  Copyright 2011年 Zelome Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoreLoadCell.h"

@interface MessageViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *msgTalbeView;

}

@property (nonatomic, retain) IBOutlet UITableView *msgTalbeView;

@end
