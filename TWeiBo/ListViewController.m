//
//  ListViewController.m
//  TWeiBo
//
//  Created by 健锋 章 on 11-8-24.
//  Copyright 2011年 Zelome Inc. All rights reserved.
//

#import "ListViewController.h"
#import "QQOAuthViewController.h"
#import "SinaOAuthViewController.h"
#import "Account.h"

@implementation ListViewController

//记录是否跳转
int original;
int now;

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
    Account *account = [[Account alloc] init];
    original = now = [[account getAccountList] count];
    [account release];
}

- (void) viewDidAppear:(BOOL)animated
{
    Account *account = [[Account alloc] init];
    now = [[account getAccountList] count];
    [account release];
    
    if (now != original) {
        original = now;
        [self back:nil];
    }
}

- (IBAction) qqWeibo:(id)sender
{
    QQOAuthViewController *qqOAuthView = [[[QQOAuthViewController alloc] init] autorelease];
    qqOAuthView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:qqOAuthView animated:YES];
}

- (IBAction) sinaWeibo:(id)sender
{
    SinaOAuthViewController *sinaOAuthView = [[[SinaOAuthViewController alloc] init] autorelease];
    sinaOAuthView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:sinaOAuthView animated:YES];
}

- (IBAction) back:(id)sender
{
    //[[self parentViewController] dismissModalViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
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
