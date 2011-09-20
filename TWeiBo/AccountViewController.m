//
//  AccountViewController.m
//  TWeiBo
//
//  Created by 健锋 章 on 11-8-20.
//  Copyright 2011年 Zelome Inc. All rights reserved.
//

#import "AccountViewController.h"
#import "ListViewController.h"
#import "Account.h"

//按钮
#define BARBUTTON(TITLE, SELECTOR)  [[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@implementation AccountViewController

@synthesize accountsTableView;
@synthesize accountList;

//tableview是否处于编辑模式
bool isEditing;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)addAccount:(id)sender {
    ListViewController *listView = [[[ListViewController alloc] init] autorelease];
    listView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:listView animated:YES];
}

- (void) viewDidAppear:(BOOL)animated
{
    //读取账号信息
    Account *account = [[Account alloc] init];
    self.accountList = [NSMutableArray arrayWithArray:[account getAccountList]];
    [account release];
    
    if ([self.accountList count] <= 0) {
        [self addAccount:nil];
    }
    
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"编辑", @selector(deleteContent:));
    
    //创建TableView
    self.accountsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 373) 
                                                          style:UITableViewStyleGrouped];
    isEditing = YES;
    [self.accountsTableView setDelegate:self];
    [self.accountsTableView setDataSource:self];
    [self.accountsTableView setEditing:NO animated:YES];
    [self.accountsTableView endUpdates];
    [self.view addSubview:self.accountsTableView];
}

//处理编辑按钮
-(void)deleteContent:(id)sender {
    if(isEditing == YES)
    {
        [self.accountsTableView beginUpdates];
        [self.accountsTableView setEditing:YES animated:YES];
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"完成", @selector(deleteContent:));
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
        isEditing = NO;
    } else {
        [self.accountsTableView setEditing:NO animated:YES];
        [self.accountsTableView endUpdates];
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"编辑", @selector(deleteContent:));
        isEditing = YES;
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.accountList count];
}

/*
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
 return @"title";
 }
 */

//自定义删除按钮文字
- (NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

//填充每一个cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *rowData = [self.accountList objectAtIndex:indexPath.row];
    
    
    if ([@"Sina" isEqualToString:[rowData objectForKey:@"Type"]]) {
        cell.imageView.image = [UIImage imageNamed:@"sina32.png"];
    } else if ([@"QQ" isEqualToString:[rowData objectForKey:@"Type"]]) {
        cell.imageView.image = [UIImage imageNamed:@"qq32.png"];
    }
    
    
	cell.textLabel.text = [rowData objectForKey:@"NickName"];
    //是否能被选中
    //cell.userInteractionEnabled = NO;
    //小箭头
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSDictionary *delRow = [self.accountList objectAtIndex:indexPath.row];
        
        //删除该条记录
        Account *account = [[Account alloc] init];
        [account deleteAccountById:[[delRow objectForKey:@"Id"] intValue]];
        [account release];
        
        [self.accountList removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if ([self.accountList count] <= 0) {
            [self addAccount:nil];
        }
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
