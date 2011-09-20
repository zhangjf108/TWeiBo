//
//  NSData+URLEncode.h
//  WeiBo
//
//  Created by 章 健锋 on 11-7-6.
//  Copyright 2011年 The9. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Util)

//字符串长度
- (int) strLength;

//URL编码
- (NSString *) urlEncode;


//URL解码
- (NSString *) urlDecode;

//html转义
- (NSString *) htmlEscape;


@end
