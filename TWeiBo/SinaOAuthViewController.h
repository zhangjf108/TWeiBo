//
//  SinaOAuthViewController.h
//  TWeiBo
//
//  Created by 健锋 章 on 11-8-27.
//  Copyright 2011年 Zelome Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface SinaOAuthViewController : UIViewController<UIWebViewDelegate, MBProgressHUDDelegate> {
    NSString *oauthToken;
    NSString *oauthTokenSecret;
    IBOutlet UIWebView *oauthWebView;
}

@property (nonatomic, retain) NSString *oauthToken;
@property (nonatomic, retain) NSString *oauthTokenSecret;
@property (nonatomic, retain) IBOutlet UIWebView *oauthWebView;

- (IBAction) cancel:(id)sender;
- (void) networkError;

@end
