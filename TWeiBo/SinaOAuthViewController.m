//
//  SinaOAuthViewController.m
//  TWeiBo
//
//  Created by 健锋 章 on 11-8-27.
//  Copyright 2011年 Zelome Inc. All rights reserved.
//

#import "SinaOAuthViewController.h"
#import "SinaWeiBo.h"
#import "Account.h"
#import "OtherUtil.h"

@implementation SinaOAuthViewController

@synthesize oauthToken;
@synthesize oauthTokenSecret;
@synthesize oauthWebView;

MBProgressHUD *HUD;
int sinaLoad = 0;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];    
    
    HUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 50, 320, 350)];
    [self.view addSubview:HUD];
    HUD.dimBackground = NO;
    HUD.delegate = self;
    HUD.labelText = @"Loading...";
    [HUD show:YES];
     
}

- (void) viewDidAppear:(BOOL)animated
{
    NSMutableDictionary *parameters = [[[NSMutableDictionary alloc] init] autorelease];
    SinaWeiBo *sinaWeibo = [[SinaWeiBo alloc] init];
    NSURL *oAuthUrl = [sinaWeibo getOauthUrl:@"oauth/request_token"
                                  httpMethod:@"GET" 
                                       token:nil
                                 tokenSecret:nil
                                      verify:nil 
                                 callbackUrl:nil 
                                  parameters:parameters];
    
    NSDictionary *dic = [sinaWeibo oauthRequest:oAuthUrl];
    
    [sinaWeibo release];
    
    if (dic) {
        NSString *requestToken = [dic valueForKey:@"oauth_token"];
        
        //设置全局变量
        self.oauthToken = requestToken;
        self.oauthTokenSecret = [dic valueForKey:@"oauth_token_secret"];
        
        NSURL *authorizeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"http://api.t.sina.com.cn/oauth/authorize?oauth_token=",requestToken]];
        
        self.oauthWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 43, 320, 460)];
        self.oauthWebView.delegate = self;
        [self.view addSubview:self.oauthWebView];
        
        [self.oauthWebView loadRequest:[NSURLRequest requestWithURL:authorizeUrl]];
    } else {
        [self networkError];
    }
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    if (HUD) {
        [HUD removeFromSuperview];
    }
    HUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 50, 320, 350)];
    [self.view addSubview:HUD];
    HUD.dimBackground = NO;
    HUD.delegate = self;
    HUD.mode = MBProgressHUDModeIndeterminate;
    if (sinaLoad == 0) {
        HUD.labelText = @"Loading...";
        sinaLoad += 1;
        [HUD show:YES];
    } else {
        HUD.labelText = @"正在授权...";
        [HUD show:YES];
    }
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [HUD hide:YES];
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    NSString *oauthVerifier = [webView stringByEvaluatingJavaScriptFromString:@"document.querySelector('div.getCodeWrap span.fb').innerHTML"];

    if ([oauthVerifier length] > 0) {
        NSMutableDictionary *parameters = [[[NSMutableDictionary alloc] init] autorelease];
        SinaWeiBo *sinaWeibo = [[SinaWeiBo alloc] init];
        NSURL *oAuthUrl = [sinaWeibo getOauthUrl:@"oauth/access_token"
                                      httpMethod:@"GET" 
                                           token:self.oauthToken
                                     tokenSecret:self.oauthTokenSecret
                                          verify:oauthVerifier 
                                     callbackUrl:nil
                                      parameters:parameters];
        
        NSDictionary *result = [sinaWeibo oauthRequest:oAuthUrl];
        
        if (result) {
            //获取用户信息
            [parameters removeAllObjects];
            [parameters setValue:[result objectForKey:@"user_id"] forKey:@"user_id"];
            Account *account = [[Account alloc] init];
            [account checkAuth:@"Sina" token:[result valueForKey:@"oauth_token"] 
                   tokenSecret:[result valueForKey:@"oauth_token_secret"] 
                    parameters:parameters];
            [account release];
            
            [sinaWeibo release];
            [self cancel:nil];
            sleep(1);
        } else {
            [self networkError];
        }
    }
}

- (void) networkError
{
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]] autorelease];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = @"请检查你的网络";
    [HUD show:YES];
    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:1.5];
}

- (IBAction) cancel:(id)sender
{
    if (HUD) {
        [HUD removeFromSuperview];
    }
    //[self.parentViewController dismissModalViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
}

- (void) hideHUD {
    if (HUD) {
        [HUD removeFromSuperview];
    }
    [self cancel:nil];
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
