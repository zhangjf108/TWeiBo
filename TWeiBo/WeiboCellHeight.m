//
//  WeiboCellHeight.m
//  TWeiBo
//
//  Created by 健锋 章 on 11-9-12.
//  Copyright 2011年 Zelome Inc. All rights reserved.
//

#import "WeiboCellHeight.h"
#import "NSString+Util.h"

@implementation WeiboCellHeight

- (float) getQQWeiboCellHeightWithContent:(NSDictionary *)content {
    int height = 26;
    
    NSString *origext = [[content objectForKey:@"origtext"] htmlEscape];
    if (origext !=  (NSString *)[NSNull null]) {
        UILabel *tmpLabel = [[UILabel alloc] init];
        tmpLabel.text = origext;
        tmpLabel.font = [UIFont systemFontOfSize:14];
        tmpLabel.lineBreakMode = UILineBreakModeWordWrap;
        tmpLabel.numberOfLines = 0;
        
        CGSize maximumLabelSize = CGSizeMake(240 ,MAXFLOAT);
        CGSize expectedLabelSize = [tmpLabel.text sizeWithFont:[UIFont systemFontOfSize:14]
                                             constrainedToSize:maximumLabelSize 
                                                 lineBreakMode:UILineBreakModeWordWrap];
        height += expectedLabelSize.height;
    }
    
    NSArray *oriImageUrls = [content objectForKey:@"image"];
    if (oriImageUrls != (NSArray *)[NSNull null]) {
        height += 86;
    }
    
    NSDictionary *source = [content objectForKey:@"source"];
    if (source != (NSDictionary *)[NSNull null]) {
        UILabel *sourceContent = [[UILabel alloc] init];
        sourceContent.text = [[NSString stringWithFormat:@"%@:%@", [source objectForKey:@"nick"],[source objectForKey:@"origtext"]] htmlEscape];
        sourceContent.font = [UIFont systemFontOfSize:14];
        sourceContent.lineBreakMode = UILineBreakModeWordWrap;
        sourceContent.numberOfLines = 0;
        
        CGSize maximumLabelSize = CGSizeMake(240 ,MAXFLOAT);
        CGSize expectedLabelSize = [sourceContent.text sizeWithFont:[UIFont systemFontOfSize:14]
                                                  constrainedToSize:maximumLabelSize 
                                                      lineBreakMode:UILineBreakModeWordWrap];
        
        height += expectedLabelSize.height + 3;
        
        NSArray *sourceImages = [source objectForKey:@"image"];
        if (sourceImages != (NSArray *)[NSNull null]) {
            height += 86;
        }
        
        height += 15;
    }
    
    if (height < 40) {
        height = 40;
    }
    
    return height + 25;
}

- (float) getSinaWeiboCellHeightWithContent:(NSDictionary *)content {
    int height = 26;
    
    NSArray *contentKeys = [content allKeys];
    
    //微博内容    
    if ([contentKeys containsObject:@"text"]) {
        UILabel *tmpLabel = [[UILabel alloc] init];
        tmpLabel.text = [[content objectForKey:@"text"] htmlEscape];
        tmpLabel.font = [UIFont systemFontOfSize:14];
        tmpLabel.lineBreakMode = UILineBreakModeWordWrap;
        tmpLabel.numberOfLines = 0;
        
        CGSize maximumLabelSize = CGSizeMake(240 ,MAXFLOAT);
        CGSize expectedLabelSize = [tmpLabel.text sizeWithFont:[UIFont systemFontOfSize:14]
                                          constrainedToSize:maximumLabelSize 
                                              lineBreakMode:UILineBreakModeWordWrap];
        height += expectedLabelSize.height;
    }
    
    //图片
    if ([contentKeys containsObject:@"thumbnail_pic"]) {        
        height += 86;
    }
    
    if ([contentKeys containsObject:@"retweeted_status"]) {
        NSDictionary *source = [content objectForKey:@"retweeted_status"];
        
        NSDictionary *retweetUser = [source objectForKey:@"user"];
        NSArray *retweetKeys = [source allKeys];
        
        NSString *soureString = [[source objectForKey:@"text"] htmlEscape];
        //内容
        UILabel *sourceContent = [[UILabel alloc] init];
        sourceContent.text = [NSString stringWithFormat:@"%@：%@", 
                              [retweetUser objectForKey:@"name"],
                              soureString];
        sourceContent.font = [UIFont systemFontOfSize:14];
        sourceContent.backgroundColor = [UIColor clearColor];
        sourceContent.lineBreakMode = UILineBreakModeWordWrap;
        sourceContent.numberOfLines = 0;
        
        CGSize maximumLabelSize = CGSizeMake(240 ,MAXFLOAT);
        CGSize expectedLabelSize = [sourceContent.text sizeWithFont:[UIFont systemFontOfSize:14]
                                                  constrainedToSize:maximumLabelSize 
                                                      lineBreakMode:UILineBreakModeWordWrap];
        
        height += (expectedLabelSize.height + 3);
        
        if ([retweetKeys containsObject:@"thumbnail_pic"]) {
            height += 86;
        }
        
        height += 15;
    }
    
    if (height < 40) {
        height = 40;
    }
    
    return height + 25;
}

@end
