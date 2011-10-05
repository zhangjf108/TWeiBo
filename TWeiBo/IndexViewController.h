//
//  IndexViewController.h
//  TWeiBo
//
//  Created by 健锋 章 on 11-8-20.
//  Copyright 2011年 Zelome Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "MoreLoadCell.h"
#import "Account.h"

@interface IndexViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
    BOOL isflage;
    EGORefreshTableHeaderView *_refreshHeaderView;   
    BOOL _reloading;
    
    NSMutableArray *weiboArray;
    
    NSMutableArray *sortArray;
    
    NSMutableDictionary *userDict;
    
    NSArray *accountArray;
    
    UIPickerView *accountPickView;
    
    MoreLoadCell *moreLoadCell;
    
    IBOutlet UIButton *titleBtn;
    IBOutlet UIBarItem *sendItem;
    IBOutlet UIBarItem *refreshItem;
}

@property(nonatomic, retain) NSMutableArray *weiboArray;
@property(nonatomic, retain) NSMutableArray *sortArray;
@property(nonatomic, retain) NSMutableDictionary *userDict;
@property(nonatomic, retain) NSArray *accountArray;
@property(nonatomic, retain) IBOutlet UIButton *titleBtn;
@property(nonatomic, retain) IBOutlet UIBarItem *sendItem;
@property(nonatomic, retain) IBOutlet UIBarItem *refreshItem;

//发送新微薄
- (IBAction) loadSendView:(id)sender;
//刷新
- (IBAction) refresh:(id)sender;

//下拉更新
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
