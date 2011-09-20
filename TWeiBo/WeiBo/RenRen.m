//
//  RenRen.m
//  WeiBo
//
//  Created by 健锋 章 on 11-8-2.
//  Copyright 2011年 Zelome. All rights reserved.
//

#import "RenRen.h"
#import "ASIHTTPRequest.h"

#define AppID 153877
#define AppKey @"cabb92599bca4a819be284048276b4db"
#define Secret @"2ba3c817368343fd9465c720b0d2702e"
#define AuthUrl @"https://graph.renren.com/oauth/authorize"
#define RedirectUri @"http://graph.renren.com/oauth/login_success.html"

@implementation RenRen

- (NSURL *) getAuthUrl {
    NSString *authUrl = [NSString stringWithFormat:@"%@?client_id=%d&redirect_uri=%@&response_type=token&display=touch", AuthUrl, AppID, RedirectUri];    
        
    return [[[NSURL alloc] initWithString:authUrl] autorelease];
}

@end
