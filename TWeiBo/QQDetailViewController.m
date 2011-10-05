//
//  QQDetailViewController.m
//  TWeiBo
//
//  Created by 健锋 章 on 11-10-5.
//  Copyright (c) 2011年 Zelome Inc. All rights reserved.
//

#import "QQDetailViewController.h"

@implementation QQDetailViewController

@synthesize content;

#pragma mark -
#pragma mark Instance Methods

- (void) setDetailContent:(NSDictionary *)detailContent {
    self.content = detailContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"微博正文";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [content release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
