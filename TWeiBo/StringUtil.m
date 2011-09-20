//
//  StringUtil.m
//  WeiBo
//
//  Created by 健锋 章 on 11-7-31.
//  Copyright 2011年 Zelome. All rights reserved.
//

#import "StringUtil.h"

@implementation StringUtil

+ (NSString *) replaceString:(NSString *) string InDictionary:(NSDictionary *) dict {
    NSMutableString *str = [[[NSMutableString alloc] initWithString:string] autorelease];
    NSArray *replaceKey = [dict allKeys];
    for (NSString *key in replaceKey) {
        [str replaceOccurrencesOfString:key 
                             withString:[dict objectForKey:key] 
                                options:NSStringEnumerationByComposedCharacterSequences 
                                  range:NSMakeRange(0, [str length])];
    }
    
    return str;
}

@end
