//
//  AccountViewController.h
//  TWeiBo
//
//  Created by 健锋 章 on 11-8-20.
//  Copyright 2011年 Zelome Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
    
    UITableView *accountsTableView;
    //数据
    NSMutableArray *accountList;
}

@property (nonatomic, retain) UITableView *accountsTableView;
@property (nonatomic, retain) NSMutableArray *accountList;

- (IBAction)addAccount:(id)sender;

@end
