//
//  DateTimeUtil.m
//  WeiBo
//
//  Created by 章 健锋 on 11-7-4.
//  Copyright 2011年 The9. All rights reserved.
//

#import "DateTime.h"

@implementation DateTime

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (NSString *) getCurrentTimeStamp {    
    return [NSString stringWithFormat:@"%0.0f",[[NSDate date] timeIntervalSince1970]];
}

@end
