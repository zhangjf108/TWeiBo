//
//  FileUtil.m
//  TWeiBo
//
//  Created by 健锋 章 on 11-9-11.
//  Copyright 2011年 Zelome Inc. All rights reserved.
//

#import "FileUtil.h"

@implementation FileUtil

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(NSString *) documentsPath {
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory, 
                                        NSUserDomainMask, 
                                        YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return documentsDir;
}


-(void) writeToFile:(NSString *) text withFileName:(NSString *) filePath {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:text];
    [array writeToFile:filePath atomically:YES];
    [array release];
}

-(NSString *) readFromFile:(NSString *) filePath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSArray *array = [[NSArray alloc] initWithContentsOfFile: filePath];
        NSString *data = [NSString stringWithFormat:@"%@",[array objectAtIndex:0]];
        [array release];
        return data;
    }
    else
        return nil;
}

@end
