//
//  FileUtil.h
//  TWeiBo
//
//  Created by 健锋 章 on 11-9-11.
//  Copyright 2011年 Zelome Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtil : NSObject

-(NSString *) documentsPath;
-(void) writeToFile:(NSString *) text withFileName:(NSString *) filePath;
-(NSString *) readFromFile:(NSString *) filePath;

@end
