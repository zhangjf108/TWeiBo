//
//  QQOAuthViewController.m
//  TWeiBo
//
//  Created by 健锋 章 on 11-8-27.
//  Copyright 2011年 Zelome Inc. All rights reserved.
//

#import "QQOAuthViewController.h"
#import "QQWeiBo.h"
#import "Account.h"

@implementation QQOAuthViewController

@synthesize oauthToken;
@synthesize oauthTokenSecret;
@synthesize oauthWebView;


MBProgressHUD *HUD;
//第几次请求
int qqLoad = 0;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    HUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    [self.view addSubview:HUD];
    HUD.dimBackground = NO;
    HUD.delegate = self;
    HUD.labelText = @"Loading...";
    [HUD show:YES];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    NSMutableDictionary *parameters = [[[NSMutableDictionary alloc] init] autorelease];
    QQWeiBo *qqWeibo = [[QQWeiBo alloc] init];
    NSURL *oAuthUrl = [qqWeibo getOauthUrl:@"request_token"
                                httpMethod:@"GET" 
                                     token:nil
                               tokenSecret:nil
                                    verify:nil 
                               callbackUrl:@"null" 
                                parameters:parameters];
    NSDictionary *dic = [qqWeibo oauthRequest:oAuthUrl];
    [qqWeibo release];
    
    if (dic) {
        NSString *requestToken = [dic valueForKey:@"oauth_token"];
        
        //设置全局变量
        self.oauthToken = requestToken;
        self.oauthTokenSecret = [dic valueForKey:@"oauth_token_secret"];
        
        NSURL *authorizeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"https://open.t.qq.com/cgi-bin/authorize?oauth_token=",requestToken]];
        
        self.oauthWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 43, 320, 460)];
        
        [self.view addSubview:self.oauthWebView];
        
        self.oauthWebView.delegate = self;
        
        [self.oauthWebView loadRequest:[NSURLRequest requestWithURL:authorizeUrl]];
    } else {
        [self networkError];
    }
    [HUD hide:YES];
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    HUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 50, 320, 350)];
    [self.view addSubview:HUD];
    HUD.dimBackground = NO;
    HUD.delegate = self;
    HUD.mode = MBProgressHUDModeIndeterminate;
    if (qqLoad == 0) {
        HUD.labelText = @"Loading...";
        qqLoad += 1;
    } else {
        HUD.labelText = @"正在授权...";
    }
    
    [HUD show:YES];
     
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [HUD hide:YES];
    
    NSString *url = [[[webView request] URL] description];
    NSArray *resultArray = [url componentsSeparatedByString:@"&"];
    NSMutableDictionary *result = [[[NSMutableDictionary alloc] init] autorelease];
    
    for (NSString *value in resultArray) {
        NSArray *tmp = [value componentsSeparatedByString:@"="];
        [result setValue:[tmp objectAtIndex:1] forKey:[tmp objectAtIndex:0]];
    }
        
    if ([result valueForKey:@"v"]) 
    {
        NSMutableDictionary *parameters = [[[NSMutableDictionary alloc] init] autorelease];
        QQWeiBo *qqWeibo = [[QQWeiBo alloc] init];
        NSURL *oAuthUrl = [qqWeibo getOauthUrl:@"access_token"
                                    httpMethod:@"GET" 
                                         token:self.oauthToken
                                   tokenSecret:self.oauthTokenSecret
                                        verify:[result valueForKey:@"v"] 
                                   callbackUrl:nil
                                    parameters:parameters];
            
        NSDictionary *result = [qqWeibo oauthRequest:oAuthUrl];
                
        if (result) {
            [parameters removeAllObjects];
            //获取用户信息
            Account *account = [[Account alloc] init];
            [account checkAuth:@"QQ" token:[result valueForKey:@"oauth_token"] 
                   tokenSecret:[result valueForKey:@"oauth_token_secret"] 
                    parameters:parameters];
            [account release];
            
            [qqWeibo release];
            [self cancel:nil];
            sleep(1);
        } else {
            [self networkError];
        }
        
    }

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

- (void) networkError
{
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]] autorelease];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = @"请检查你的网络";
    [HUD show:YES];
    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:2.0];
}

- (void) hideHUD {
    if (HUD) {
        [HUD removeFromSuperview];
    }
    [self cancel:nil];
}

- (IBAction) cancel:(id)sender
{
    if (HUD) {
        [HUD removeFromSuperview];
    }
    //[self.parentViewController dismissModalViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [oauthWebView release];
    [HUD release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
