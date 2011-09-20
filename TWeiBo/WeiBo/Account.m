//
//  Account.m
//  WeiBo
//
//  Created by 健锋 章 on 11-8-10.
//  Copyright 2011年 Zelome. All rights reserved.
//

#import "Account.h"
#import "QQWeiBo.h"
#import "SinaWeiBo.h"
#import "SQLite3Lib.h"
#import "OtherUtil.h"

@implementation Account

- (void) checkAuth:(NSString *)platform 
             token:(NSString *)token 
       tokenSecret:(NSString *)tokenSecret 
        parameters:(NSDictionary *)parameters {
    
    //持久保存Token
    SQLite3Lib *sqlite3Lib = [[SQLite3Lib alloc] init];
    [sqlite3Lib openDB];
    NSString *sql = [[NSString alloc] init];
    sql = [NSString stringWithFormat:@"SELECT * FROM account WHERE Type='%@' AND Token='%@' AND TokenSecret='%@' LIMIT 1", platform,  token, tokenSecret];

    if ([[sqlite3Lib queryRow:sql] count] <= 0) {
        id plat;
        NSDictionary *userInfo = [[[NSDictionary alloc] init] autorelease];
        if ([@"QQ" isEqualToString:platform]) {
            plat = [[QQWeiBo alloc] init];
            userInfo = [[plat apiGetRequest:1 reqMethod:@"user/info" 
                                                    token:token 
                                              tokenSecret:tokenSecret 
                                               parameters:parameters] objectForKey:@"data"];
            if (userInfo != nil) {
                sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO account values(null,'QQ','%@','%@','%@','%@','%@','%@',DATETIME('now'),'')",@"",[userInfo objectForKey:@"name"],[userInfo objectForKey:@"nick"],[userInfo objectForKey:@"head"],token,tokenSecret];
            } else {
                [OtherUtil alertWithTitle:nil message:@"认证失败" cancel:@"确定"];
            }
            
        } else if ([@"Sina" isEqualToString:platform]) {
            plat = [[SinaWeiBo alloc] init];
            userInfo = [plat apiGetRequest:1 reqMethod:@"users/show.json"
                                                    token:token 
                                              tokenSecret:tokenSecret 
                                               parameters:parameters];
            
            if (userInfo != nil) {
                sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO account values(null,'Sina','%@','%@','%@','%@','%@','%@',DATETIME('now'),'')",[userInfo objectForKey:@"id"],[userInfo objectForKey:@"name"],[userInfo objectForKey:@"screen_name"],[userInfo objectForKey:@"profile_image_url"],token,tokenSecret];
            } else {
                [OtherUtil alertWithTitle:nil message:@"认证失败" cancel:@"确定"];
            }
        }
        [sqlite3Lib insertRecord:sql];
    } else {
        [OtherUtil alertWithTitle:nil message:@"账号已存在" cancel:@"确定"];
    }
    
    [sqlite3Lib closeDB];
    [sqlite3Lib release];
}

- (NSArray *) getAccountList {
    SQLite3Lib *sqlite3Lib = [[SQLite3Lib alloc] init];
    [sqlite3Lib openDB];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM account"];
    NSArray *accountList = [sqlite3Lib queryAll:sql];
    [sqlite3Lib closeDB];
    [sqlite3Lib release];
    
    return accountList;
}

- (void) deleteAccountById:(int) accountId {
    SQLite3Lib *sqlite3Lib = [[SQLite3Lib alloc] init];
    [sqlite3Lib openDB];
    [sqlite3Lib executeSql:[NSString stringWithFormat:@"DELETE FROM account WHERE Id=%d", accountId]];
    [sqlite3Lib closeDB];
    [sqlite3Lib release];
}

- (void) updateAccountNextFlag:(NSString *) nextFlag byId:(NSString *) accountId {
    SQLite3Lib *sqlite3Lib = [[SQLite3Lib alloc] init];
    [sqlite3Lib openDB];
    [sqlite3Lib executeSql:[NSString stringWithFormat:@"UPDATE account set NextFlag=%@ WHERE Id=%@", nextFlag, accountId]];
    [sqlite3Lib closeDB];
    [sqlite3Lib release];
}

@end
