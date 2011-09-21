//
//  MessageViewController.m
//  TWeiBo
//
//  Created by 健锋 章 on 11-8-20.
//  Copyright 2011年 Zelome Inc. All rights reserved.
//

#import "MessageViewController.h"
#import "QQWeiBoCell.h"
#import "FileUtil.h"
#import "NSObject+SBJson.h"
#import "WeiboCellHeight.h"

@implementation MessageViewController

@synthesize msgTalbeView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.msgTalbeView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 200) style:UITableViewStylePlain];
    [self.msgTalbeView setDelegate:self];
    [self.msgTalbeView setDataSource:self];
    //[self.msgTalbeView setSeparatorColor:[UIColor clearColor]];
    [self.view addSubview:self.msgTalbeView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = @"稍安勿躁，好戏就在后头～";
    
    return cell;
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  44;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void) beginLoadMore {
    [self performSelectorInBackground:@selector(loadMore) withObject:nil];
}

- (void) loadMore {   
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    //加载数据
    
    
    [pool release];
    
    [self performSelectorOnMainThread:@selector(appendTableWith:) withObject:nil waitUntilDone:NO];
}

-(void) appendTableWith:(NSArray *)data
{
    
}

- (void) viewWillAppear:(BOOL)animated 
{
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
