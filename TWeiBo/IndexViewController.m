//
//  IndexViewController.m
//  TWeiBo
//
//  Created by 健锋 章 on 11-8-20.
//  Copyright 2011年 Zelome Inc. All rights reserved.
//

#import "IndexViewController.h"
#import "SendViewController.h"
#import "QQWeiBo.h"
#import "SinaWeiBo.h"
#import "DateTime.h"
#import "Account.h"
#import "NSObject+SBJson.h"
#import "FileUtil.h"
#import "NSString+Util.h"
#import "QQWeiBoCell.h"
#import "SinaWeiBoCell.h"
#import "WeiboCellHeight.h"

@implementation IndexViewController

@synthesize sendItem, refreshItem, weiboArray, userDict;

int lastUpdate  = 0;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction) loadSendView:(id)sender {
    SendViewController *sendView = [[[SendViewController alloc] init] autorelease];
    sendView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:sendView animated:YES];
}

- (IBAction) refresh:(id)sender {       
    [self.tableView setContentOffset:CGPointMake(0, -66)];
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:self.tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    weiboArray = [[NSMutableArray alloc] init];
    userDict = [[NSMutableDictionary alloc] init];
    
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
	}
    
    //加载本地文件数据
    FileUtil *file = [[FileUtil alloc] init];
    NSString *fileName = [[file documentsPath] stringByAppendingPathComponent:@"dict.txt"];
    NSString *fileContent = [file readFromFile:fileName];
    
    if (fileContent != nil) {
        NSDictionary *dict = [fileContent JSONValue];
        
        lastUpdate = [[dict objectForKey:@"lastUpdate"] intValue];
        userDict = [[dict objectForKey:@"user"] retain];
        weiboArray = [[dict objectForKey:@"weibo"] retain];
    } else {
        [self performSelectorOnMainThread:@selector(loadData) withObject:nil waitUntilDone:YES];
    }
    
    [file release];
    
	[_refreshHeaderView refreshLastUpdatedDate];

}

- (void) viewWillAppear:(BOOL)animated 
{
    
}

#pragma mark -
#pragma mark Private Methods

-(NSDictionary *) getQQWeiboListWithToken:(NSString *) token tokenSecret:(NSString *) tokenSecret {
    NSMutableDictionary *parameters = [[[NSMutableDictionary alloc] init] autorelease];
    [parameters setValue:@"0" forKey:@"Pageflag"];
    [parameters setValue:@"0" forKey:@"PageTime"];
    [parameters setValue:@"70" forKey:@"Reqnum"];
    [parameters setValue:@"0" forKey:@"type"];
    [parameters setValue:@"0" forKey:@"Contenttype"];
    [parameters setValue:@"0" forKey:@"Accesslevel"];
    
    QQWeiBo *qqWeibo = [[QQWeiBo alloc] init];
    NSDictionary *result = [qqWeibo apiGetRequest:1 
                                        reqMethod:@"statuses/home_timeline" 
                                            token:token 
                                      tokenSecret:tokenSecret 
                                       parameters:parameters];
    [qqWeibo release];
    return result;
}

-(NSDictionary *) getQQWeiboListNextWithToken:(NSString *) token 
                                  tokenSecret:(NSString *) tokenSecret 
                                     pageTime:(NSString *) pageTime {
    NSMutableDictionary *parameters = [[[NSMutableDictionary alloc] init] autorelease];
    
    [parameters setValue:@"1" forKey:@"pageflag"];
    [parameters setValue:pageTime forKey:@"pagetime"];
    [parameters setValue:@"70" forKey:@"reqnum"];
    [parameters setValue:@"0" forKey:@"type"];
    [parameters setValue:@"0" forKey:@"contenttype"];
    [parameters setValue:@"0" forKey:@"accesslevel"];
    
    QQWeiBo *qqWeibo = [[QQWeiBo alloc] init];
    NSDictionary *result = [qqWeibo apiGetRequest:1 
                                        reqMethod:@"statuses/home_timeline" 
                                            token:token 
                                      tokenSecret:tokenSecret 
                                       parameters:parameters];
    [qqWeibo release];
    
    return result;
}

-(NSArray *) getSinaWeiboListWithToken:(NSString *) token 
                           tokenSecret:(NSString *) tokenSecret {
    NSMutableDictionary *parameters = [[[NSMutableDictionary alloc] init] autorelease];
    [parameters setValue:@"20" forKey:@"count"];
    [parameters setValue:@"0" forKey:@"base_app"];
    [parameters setValue:@"0" forKey:@"feature"];
    
    SinaWeiBo *sinaWeibo = [[SinaWeiBo alloc] init];
    NSArray *result = [sinaWeibo apiGetRequestWithReqMethod:@"statuses/home_timeline.json" 
                                                      token:token 
                                                tokenSecret:tokenSecret
                                                 parameters:parameters];
    [sinaWeibo release];
    return result;
}

-(NSArray *) getSinaWeiboListNextWithToken:(NSString *) token 
                               tokenSecret:(NSString *) tokenSecret 
                                     maxId:(NSString *) maxId {
    NSMutableDictionary *parameters = [[[NSMutableDictionary alloc] init] autorelease];
    [parameters setValue:@"20" forKey:@"count"];
    [parameters setValue:@"0" forKey:@"base_app"];
    [parameters setValue:maxId forKey:@"max_id"];
    [parameters setValue:@"0" forKey:@"feature"];
    
    SinaWeiBo *sinaWeibo = [[SinaWeiBo alloc] init];
    NSArray *result = [sinaWeibo apiGetRequestWithReqMethod:@"statuses/home_timeline.json" 
                                                      token:token 
                                                tokenSecret:tokenSecret
                                                 parameters:parameters];
    [sinaWeibo release];
    return result;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [weiboArray count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"QQWeiBoCell";
    //更多Cell
    if (indexPath.row == [weiboArray count]) {
        
        moreLoadCell = [[MoreLoadCell alloc] 
                        initWithStyle:(UITableViewCellStyle)UITableViewCellStyleDefault 
                        reuseIdentifier:(NSString *)CellIdentifier];
        moreLoadCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //[self performSelector:@selector(beginLoadMore)];
        
        return moreLoadCell;
    }
    
    NSDictionary *content = [weiboArray objectAtIndex:indexPath.row];
    NSArray *contentKeys = [content allKeys];
    
    if ([contentKeys containsObject:@"created_at"]) {
        
       SinaWeiBoCell *cell = [[[SinaWeiBoCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                reuseIdentifier:CellIdentifier 
                                                        content:content] autorelease];
        return cell;
        
    } else {
        
       QQWeiBoCell *cell = [[[QQWeiBoCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                   reuseIdentifier:CellIdentifier 
                                           content:content
                                          userDict:userDict] autorelease];
        
        return cell;
    }

}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //更多
    if (indexPath.row == [weiboArray count]) {
        return 60;
    }
    
    NSDictionary *content = [weiboArray objectAtIndex:indexPath.row];
    NSArray *contentKeys = [content allKeys];
    
     WeiboCellHeight *cellheight = [[WeiboCellHeight alloc] init];
    int height = 0;
    if ([contentKeys containsObject:@"created_at"]) {
        height = [cellheight getSinaWeiboCellHeightWithContent:content];
    } else {
        height = [cellheight getQQWeiboCellHeightWithContent:content];
    }
     
    [cellheight release];
    return height;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [weiboArray count]) {
        [self performSelector:@selector(beginLoadMore)];
    }
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    sendItem.enabled = NO;
    refreshItem.enabled = NO;
    
    _reloading = YES;
    
    [self performSelectorInBackground:@selector(loadData) withObject:nil];
}

- (void) loadData {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    Account *account = [[Account alloc] init];
    NSArray *accountArray = [account getAccountList];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *tempUser = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *accountInfo in accountArray) {
        if ([@"QQ" isEqualToString:[accountInfo objectForKey:@"Type"]]) {
            NSDictionary *qqContent =  [self getQQWeiboListWithToken:[accountInfo objectForKey:@"Token"] 
                                                         tokenSecret:[accountInfo objectForKey:@"TokenSecret"]];
            if (qqContent != nil) {
                NSArray *temp = [[qqContent objectForKey:@"data"] objectForKey:@"info"];
                
                [tempArray addObjectsFromArray:temp];
                [tempArray retain];
                [tempUser setDictionary:[[qqContent objectForKey:@"data"] objectForKey:@"user"]];
                [tempUser retain];
                
                //更新帐号信息
                NSDictionary *lastWeibo = [temp lastObject];
                [account updateAccountNextFlag:[lastWeibo objectForKey:@"timestamp"] byId:[accountInfo objectForKey:@"Id"]];
                
            }
        } else if ([@"Sina" isEqualToString:[accountInfo objectForKey:@"Type"]]) {
            NSArray *sinaContent = [self getSinaWeiboListWithToken:[accountInfo objectForKey:@"Token"] 
                                                            tokenSecret:[accountInfo objectForKey:@"TokenSecret"]];
            if (sinaContent != nil) {
                [tempArray addObjectsFromArray:sinaContent];
                [tempArray retain];
                
                NSDictionary *lastWeibo = [sinaContent lastObject];
                [account updateAccountNextFlag:[lastWeibo objectForKey:@"id"] byId:[accountInfo objectForKey:@"Id"]];
            }
        }
    }
    
    if ([tempArray count] > 0) {
        weiboArray = tempArray;
    }
    
    if ([tempUser count] > 0) {
        userDict = tempUser;
        [userDict retain];
    }
    
    [tempArray release];
    [tempUser release];
    [account release];
    
    //当前时间戳
    lastUpdate = (int)[[NSDate date] timeIntervalSince1970];
    
    //写本地文件
    if ([weiboArray count] > 0) {
        FileUtil *file = [[FileUtil alloc] init];
        NSString *fileName = [[file documentsPath] stringByAppendingPathComponent:@"dict.txt"];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:weiboArray forKey:@"weibo"];
        [dict setObject:[NSString stringWithFormat:@"%d", lastUpdate] forKey:@"lastUpdate"];
        [dict setObject:userDict forKey:@"user"];
        NSString *text = [dict JSONRepresentation];
        [file writeToFile:text withFileName:fileName];
        [file release];
    }
    
    [self performSelector:@selector(doneLoadingTableViewData)];
    
    [pool release];
}

- (void)doneLoadingTableViewData{
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    
    [self.tableView reloadData];
    
    sendItem.enabled = YES;
    refreshItem.enabled = YES;
    
}

- (void) beginLoadMore {
    [moreLoadCell setText:@"正在载入..."];
    [moreLoadCell spinnerStartAnimating];
    [self performSelectorInBackground:@selector(loadMore) withObject:nil];
}

- (void) loadMore {   
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    //加载数据
    Account *account = [[Account alloc] init];
    NSArray *accountArray = [account getAccountList];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *tempUser = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *accountInfo in accountArray) {
        if ([@"QQ" isEqualToString:[accountInfo objectForKey:@"Type"]]) {
            NSDictionary *qqContent =  [self getQQWeiboListNextWithToken:[accountInfo objectForKey:@"Token"] 
                                                             tokenSecret:[accountInfo objectForKey:@"TokenSecret"] 
                                                                pageTime:[accountInfo objectForKey:@"NextFlag"]];
            
            if (qqContent != nil) {
                NSArray *temp = [[qqContent objectForKey:@"data"] objectForKey:@"info"];
                
                [tempArray addObjectsFromArray:temp];
                [tempArray retain];
                [tempUser addEntriesFromDictionary:[[qqContent objectForKey:@"data"] objectForKey:@"user"]];
                [tempUser retain];
                
                //更新帐号信息
                NSDictionary *lastWeibo = [temp lastObject];
                [account updateAccountNextFlag:[lastWeibo objectForKey:@"timestamp"] byId:[accountInfo objectForKey:@"Id"]];
                
            }
        } else if ([@"Sina" isEqualToString:[accountInfo objectForKey:@"Type"]]) {
            NSArray *sinaContent = [self getSinaWeiboListNextWithToken:[accountInfo objectForKey:@"Token"]
                                                           tokenSecret:[accountInfo objectForKey:@"TokenSecret"]
                                                                 maxId:[accountInfo objectForKey:@"NextFlag"]];
            
            if (sinaContent != nil) {
                [tempArray addObjectsFromArray:sinaContent];
                [tempArray retain];
                
                NSDictionary *lastWeibo = [sinaContent lastObject];
                [account updateAccountNextFlag:[lastWeibo objectForKey:@"id"] byId:[accountInfo objectForKey:@"Id"]];
            }
        }
    }
    
    [account release];
    
    [moreLoadCell spinnerStopAnimating];
    
    [weiboArray addObjectsFromArray:tempArray];
    [userDict addEntriesFromDictionary:tempUser];
    [self.tableView reloadData];
    
    [tempArray release];
    [tempUser release];
    
    [moreLoadCell setText:@"载入更多..."];
    
    [pool release];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	[self reloadTableViewDataSource];
	//[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.5];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading;
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate dateWithTimeIntervalSince1970:lastUpdate];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [_refreshHeaderView release];
    [moreLoadCell release];
    [sendItem release];
    [refreshItem release];
    [weiboArray release];
    [userDict release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
