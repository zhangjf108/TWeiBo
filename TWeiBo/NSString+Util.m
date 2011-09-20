//
//  NSData+URLEncode.m
//  WeiBo
//
//  Created by 章 健锋 on 11-7-6.
//  Copyright 2011年 The9. All rights reserved.
//

#import "NSString+Util.h"

@implementation NSString (Util)

- (int) strLength {
    const char *str1 = [self cStringUsingEncoding:NSUTF8StringEncoding];
    int enLength = 0;
    int chLength = 0;
    int total = strlen(str1);
    //return size;
    
    for(int i = 0; i < total; i++) {
        if(str1[i] >= 0) {
            enLength++;
        } else {
            chLength++;
        }
    }
    
    return enLength + chLength / 3 * 2;
}


- (NSString *) urlEncode {
    return [(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, 
                                                               (CFStringRef)self, 
                                                               NULL, 
                                                               (CFStringRef)@"!*'();:@&=+$,/?%#[]", 
                                                               kCFStringEncodingUTF8) autorelease];
}

- (NSString *) urlDecode {
   return [(NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                        (CFStringRef)self,
                                                                        CFSTR(""),
                                                                        kCFStringEncodingUTF8) autorelease];
}

- (NSString *) htmlEscape {
    NSDictionary *escapeHtmlDict = [[[NSDictionary alloc] initWithObjectsAndKeys:@"\"", @"&quot;",
                                                                                 @"&", @"&amp;",
                                                                                 @"<", @"&lt;",
                                                                                 @">", @"&gt;",
                                                                                 @" ", @"&nbsp;",
                                                                                    nil] autorelease];
    
    NSMutableString *str = [[[NSMutableString alloc] initWithString:self] autorelease];
    NSArray *escapeKeys = [escapeHtmlDict allKeys];
    for (NSString *key in escapeKeys) {
        [str replaceOccurrencesOfString:key 
                             withString:[escapeHtmlDict objectForKey:key] 
                                options:NSStringEnumerationByComposedCharacterSequences 
                                  range:NSMakeRange(0, [str length])];
    }
    
    return str;
}

@end
