//
//  OtherUtil.m
//  WeiBo
//
//  Created by 健锋 章 on 11-8-7.
//  Copyright 2011年 Zelome. All rights reserved.
//

#import "OtherUtil.h"
#import "Reachability.h"

@implementation OtherUtil

+ (void) alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancelButton {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title 
                                                    message:message 
                                                   delegate:self 
                                          cancelButtonTitle:cancelButton 
                                          otherButtonTitles:nil, 
                                                            nil];
    [alert show];
    [alert release];
}

+ (BOOL) isNetConnection {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    return [reachability isReachable];
}

@end
