//
//  SQLite3Lib.h
//  WeiBo
//
//  Created by 健锋 章 on 11-8-8.
//  Copyright 2011年 Zelome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLite3.h"

@interface SQLite3Lib : NSObject {
    sqlite3 *db;
}

/**
 * 检查库是否已经存在，如不存在则新建库并初始化所有表
 */
- (void) checkDBIsExsit;

/**
 * 打开db
 */
- (void) openDB;

/**
 * 关闭DB
 */
- (void) closeDB;

/**
 * 插入记录
 */
- (BOOL) insertRecord:(NSString *)sql;

/**
 * 查询一条记录
 */
- (NSDictionary *) queryRow:(NSString *)sql;

/**
 * 查询多条记录
 */
- (NSArray *) queryAll:(NSString *)sql;

/**
 * 执行插入，删除，更新的SQL语句
 */
- (BOOL) executeSql:(NSString *)sql;

@end
