//
//  SQLite3Lib.m
//  WeiBo
//
//  Created by 健锋 章 on 11-8-8.
//  Copyright 2011年 Zelome. All rights reserved.
//

#import "SQLite3Lib.h"

//数据库文件
#define DBFILE @"database.sql"

@implementation SQLite3Lib


#pragma mark -
#pragma mark Private method

- (NSString *) filePath:(NSString *)fileSql {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, 
                                                         NSUserDomainMask, 
                                                         YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:fileSql];
}

- (void) createAccountTable {
    char *err;
    NSString *createSql = @"CREATE TABLE IF NOT EXISTS `account` (Id INTEGER PRIMARY KEY AUTOINCREMENT,"
                            "Type TEXT,UserId TEXT,Name TEXT,NickName TEXT,Head TEXT,Token TEXT, TokenSecret TEXT,CreateTime TEXT,NextFlag Text)";
    if (sqlite3_exec(db, [createSql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(db);
        NSAssert(0, @"table failed to create.");
    }
}

#pragma mark -
#pragma mark instance method

- (void) checkDBIsExsit {
    NSString *file = [self filePath:DBFILE];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file] == FALSE)
    {
        [self openDB];
        //初始化所有表
        [self createAccountTable];
        [self closeDB];
    }
}

- (void) openDB {
    NSString *dbFile = [self filePath:DBFILE];
    //open db
    if (sqlite3_open([dbFile UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
    }
}

- (void) closeDB {
    sqlite3_close(db);
}

- (BOOL) insertRecord:(NSString *) sql {
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(db);
        return NO;
    }
    
    return YES;
}

//如果查询结果有多行则取第一行
- (NSDictionary *) queryRow:(NSString *)sql {
    NSMutableDictionary *row = [[[NSMutableDictionary alloc] init] autorelease];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        int count = sqlite3_column_count(statement);
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSString *key;
            NSString *value;
            for (int i = 0; i < count; ++i) {
                NSString *type = [[NSString stringWithFormat:@"%s", 
                                   sqlite3_column_decltype(statement, i)] lowercaseString];
                
                if ([@"integer" isEqualToString:type]) {
                    key = [NSString stringWithFormat:@"%s", sqlite3_column_name(statement, i)];
                    value = [NSString stringWithFormat:@"%d", sqlite3_column_int(statement, i)];                    
                    [row setValue:value forKey:key];
                } else if ([@"text" isEqualToString:type]) {
                    key = [NSString stringWithFormat:@"%s", sqlite3_column_name(statement, i)];
                    value = [NSString stringWithFormat:@"%s", sqlite3_column_text(statement, i)];                    
                    [row setValue:value forKey:key];
                }
            }
            break;
        }
        //deletes the compiled statement from memory
        sqlite3_finalize(statement);
    }
    return row;
}

- (NSArray *) queryAll:(NSString *)sql {
    NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        int count = sqlite3_column_count(statement);
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *row = [[[NSMutableDictionary alloc] init] autorelease];
            NSString *key;
            NSString *value;
            for (int i = 0; i < count; ++i) {
                NSString *type = [[NSString stringWithFormat:@"%s", 
                                            sqlite3_column_decltype(statement, i)] lowercaseString];
                
                if ([@"integer" isEqualToString:type]) {
                    key = [NSString stringWithFormat:@"%s", sqlite3_column_name(statement, i)];
                    value = [NSString stringWithFormat:@"%d", sqlite3_column_int(statement, i)];                    
                    [row setValue:value forKey:key];
                } else if ([@"text" isEqualToString:type]) {
                    key = [NSString stringWithFormat:@"%s", sqlite3_column_name(statement, i)];
                    //用(char *)代替(NSString *)避免中文乱码问题
                    value = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, i) 
                                                     encoding:NSUTF8StringEncoding];                  
                    [row setValue:value forKey:key];
                }
            }
            [result addObject:row];
        }
        
        //deletes the compiled statement from memory
        sqlite3_finalize(statement);
    }

    return result;
}

- (BOOL) executeSql:(NSString *)sql {
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, nil) != SQLITE_OK) {
        sqlite3_close(db);
        return NO;
    }
    return YES;
}

@end
