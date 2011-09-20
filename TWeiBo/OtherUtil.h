//
//  OtherUtil.h
//  WeiBo
//
//  Created by 健锋 章 on 11-8-7.
//  Copyright 2011年 Zelome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OtherUtil : NSObject

//简化的弹窗
+ (void) alertWithTitle:(NSString *)title 
                message:(NSString *)message 
                 cancel:(NSString *)cancelButton;

//检测网络链接
+ (BOOL) isNetConnection;


@end
