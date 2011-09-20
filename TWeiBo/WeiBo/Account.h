//
//  Account.h
//  WeiBo
//
//  Created by 健锋 章 on 11-8-10.
//  Copyright 2011年 Zelome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Account : NSObject

/**
 * 检查该账号是否已经认证，如果没有则插入
 */
- (void) checkAuth:(NSString *) platform
            token:(NSString *) token
      tokenSecret:(NSString *) tokenSecret
       parameters:(NSDictionary *)parameters;

/**
 * 获取所有账号信息
 */
- (NSArray *) getAccountList;

/**
 * 根据ID删除账号
 */
- (void) deleteAccountById:(int) accountId;

- (void) updateAccountNextFlag:(NSString *) nextFlag byId:(NSString *) accountId;

@end
