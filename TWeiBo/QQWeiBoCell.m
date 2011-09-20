//
//  WeiBoCell.m
//  TWeiBo
//
//  Created by 健锋 章 on 11-9-11.
//  Copyright 2011年 Zelome Inc. All rights reserved.
//

#import "QQWeiBoCell.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+Util.h"
#import "StringUtil.h"

@implementation QQWeiBoCell

static int currentTime;
static NSDictionary *userDict;

#pragma mark -
#pragma mark Static method
static CGRect getFrameByType(NSString *type) {
    CGRect frame;
    if ([@"head" isEqualToString:type]) {
        frame = CGRectMake(5, 8, 40, 40);
    } else if ([@"nick" isEqualToString:type]) {
        frame = CGRectMake(55, 8, 150, 35);
    } else if ([@"image" isEqualToString:type]) {
        frame = CGRectMake(5, 10, 40, 40);
    } else if ([@"date" isEqualToString:type]) {
        frame = CGRectMake(240, 5, 70, 20);
    }
    
    return frame;
}

#pragma mark -
#pragma mark Private method
-(NSString *) getDateFormat:(int)timeStamp {
    int duration = currentTime - timeStamp;
    
    NSString *dateText;
    
    if (duration <= 60) {
        dateText = @"刚刚";
    } else if (duration <= 18000) {
        int hour = duration / 3600;
        int minute = (duration - 3600 * hour) / 60;        
        if (hour != 0) {
            dateText = [NSString stringWithFormat:@"%d小时前", hour];
        } else {
            dateText = [NSString stringWithFormat:@"%d分钟前", minute];
        }
    } else {
        NSDate *dateStr = [NSDate dateWithTimeIntervalSince1970:timeStamp];
        [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        
        if (duration <= 43200) {
            [dateFormatter setDateFormat:@"HH:mm"];        
            dateText = [dateFormatter stringFromDate:dateStr];
        } else {
            [dateFormatter setDateFormat:@"MM-dd"];
            dateText = [dateFormatter stringFromDate:dateStr];
        }
    }
    
    return dateText;
}


#pragma mark -
#pragma mark Instance method
- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier 
            content:(NSDictionary *)content 
           userDict:(NSDictionary *)_userDict {
    
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        weiboContent = content;
        [weiboContent retain];
        
        userDict = _userDict;
        
        //NSLog(@"%@", userDict);
        
        //当前时间戳
        currentTime = (int)[[NSDate date] timeIntervalSince1970];
        cellHeight = 26;        
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    NSString *headUrl = [NSString stringWithFormat:@"%@/100", [weiboContent objectForKey:@"head"]];
    
    head = [[UIImageView alloc] initWithFrame:getFrameByType(@"head")];
    [head setImageWithURL:[NSURL URLWithString:headUrl] 
         placeholderImage:[UIImage imageNamed:@"logo_gray40.png"]];
        
    head.layer.masksToBounds = YES;
    head.layer.cornerRadius = 5.0;
    head.layer.borderWidth = 2.0;
    head.layer.borderColor = [[UIColor clearColor] CGColor];
    [self addSubview:head];
        
    //昵称
    nick = [weiboContent objectForKey:@"nick"];
    [nick drawInRect:getFrameByType(@"nick")
            withFont:[UIFont fontWithName:@"Arial Hebrew" size:16]];
    
    //微博内容(需要正则匹配替换@)
    NSString *origtext = [[weiboContent objectForKey:@"origtext"] htmlEscape];
    
    origtext = [StringUtil replaceString:origtext InDictionary:userDict];
    
    if (origtext != (NSString *)[NSNull null]) {
        label = [[UILabel alloc] init];
        label.text = origtext;
        label.font = [UIFont systemFontOfSize:14];
        label.lineBreakMode = UILineBreakModeWordWrap;
        label.numberOfLines = 0;
        
        CGSize maximumLabelSize = CGSizeMake(240 ,MAXFLOAT);
        CGSize expectedLabelSize = [label.text sizeWithFont:[UIFont systemFontOfSize:14]
                                          constrainedToSize:maximumLabelSize 
                                              lineBreakMode:UILineBreakModeWordWrap];
        cellHeight += expectedLabelSize.height;
        
        [label drawTextInRect:CGRectMake(55, 26, expectedLabelSize.width, expectedLabelSize.height)];
    }
    
    //发送时间
    int timestamp = [[weiboContent objectForKey:@"timestamp"] intValue];
    NSString *dateText = [self getDateFormat:timestamp];
    date = [[UILabel alloc] init];
    date.text = dateText;
    date.textAlignment = UITextAlignmentRight;
    date.textColor = [UIColor orangeColor];
    date.font = [UIFont systemFontOfSize:12];
    date.frame = getFrameByType(@"date");
    [self addSubview:date];
    
    //图片
    NSArray *oriImageUrls = [weiboContent objectForKey:@"image"];
    if (oriImageUrls != (NSArray *)[NSNull null]) {
        oriImage = [[UIImageView alloc] initWithFrame:CGRectMake(55, cellHeight + 5, 80, 80)];
        NSString *imageUrl = [NSString stringWithFormat:@"%@/160", [oriImageUrls objectAtIndex:0]];
        [oriImage setImageWithURL:[NSURL URLWithString:imageUrl]
                 placeholderImage:[UIImage imageNamed:@"logo_gray80.png"]];
        oriImage.contentMode = UIViewContentModeScaleAspectFit;
        oriImage.layer.masksToBounds = YES;
        oriImage.layer.cornerRadius = 2.0; 
        oriImage.layer.borderWidth = 0.5;
        oriImage.layer.borderColor = [[UIColor whiteColor] CGColor];
        [self addSubview:oriImage];
        
        cellHeight += 86;
    }
    
    NSDictionary *source = [weiboContent objectForKey:@"source"];
    if (source != (NSDictionary *)[NSNull null]) {        
        //内容
        sourceContent = [[UILabel alloc] init];
        
        NSString *soureString = [[source objectForKey:@"origtext"] htmlEscape];
        soureString = [StringUtil replaceString:soureString InDictionary:userDict];
        
        sourceContent.text = [NSString stringWithFormat:@"%@：%@", 
                              [source objectForKey:@"nick"],
                              soureString];
        sourceContent.font = [UIFont systemFontOfSize:14];
        sourceContent.backgroundColor = [UIColor clearColor];
        sourceContent.lineBreakMode = UILineBreakModeWordWrap;
        sourceContent.numberOfLines = 0;
        
        CGSize maximumLabelSize = CGSizeMake(240 ,MAXFLOAT);
        CGSize expectedLabelSize = [sourceContent.text sizeWithFont:[UIFont systemFontOfSize:14]
                                               constrainedToSize:maximumLabelSize 
                                                   lineBreakMode:UILineBreakModeWordWrap];
        
        sourceContent.frame = CGRectMake(64, cellHeight + 10, expectedLabelSize.width - 2,expectedLabelSize.height);
        [self addSubview:sourceContent];
        
        cellHeight += (expectedLabelSize.height + 3);
        
        //NSDictionary *sourceVideo = [weiboContent objectForKey:@"vedio"];
        NSArray *sourceImages = [source objectForKey:@"image"];
        if (sourceImages != (NSArray *)[NSNull null]) {
            sourceImage = [[UIImageView alloc] initWithFrame:CGRectMake(65, cellHeight + 10, 80, 80)];
            NSString *soureImageUrl = [NSString stringWithFormat:@"%@/160", [sourceImages objectAtIndex:0]];
            [sourceImage setImageWithURL:[NSURL URLWithString:soureImageUrl]
                        placeholderImage:[UIImage imageNamed:@"logo_gray80.png"]];
            sourceImage.contentMode = UIViewContentModeScaleAspectFit;
            sourceImage.layer.masksToBounds = YES;
            sourceImage.layer.cornerRadius = 2.0; 
            sourceImage.layer.borderWidth = 0.5;
            sourceImage.layer.borderColor = [[UIColor clearColor] CGColor];
            [self addSubview:sourceImage];
            
            //cellHeight += 82;
        }
                
        //画边框及填充背景色
        float x = 60;
        float y = cellHeight - expectedLabelSize.height + 5;
        float w = 247;
        float h = expectedLabelSize.height + 5;
        float r = 5.0;// 圆角
        
        if (sourceImages != (NSArray *)[NSNull null]) {
            h += 86;
            cellHeight += 86;
        }
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGMutablePathRef path = CGPathCreateMutable();
        // 矩形
        CGPathMoveToPoint(path, NULL, x, y + r);
        CGPathAddArcToPoint(path, NULL, x, y + h, x + r, y + h, r);
        CGPathAddArcToPoint(path, NULL, x + w, y + h, x + w, y + h - r, r);
        CGPathAddArcToPoint(path, NULL, x + w, y, x + w - r, y, r);
        CGPathAddArcToPoint(path, NULL, x, y, x, y + r,r);
        
        // 箭头
        CGPathMoveToPoint(path, NULL, x + r + 10.0, y);
        CGPathAddLineToPoint(path, NULL, x + r + 15.0, y - 6);
        CGPathAddLineToPoint(path, NULL, x + r + 21.0, y);
        
        // 边框
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGFloat borderColour[4] = {180.0/255, 180.0/255.0, 180.0/255.0, 1.0};
        CGContextSetLineWidth(context, 1.0);
        CGContextAddPath(context, path);
        CGContextSetStrokeColorSpace(context, CGColorSpaceCreateDeviceRGB());
        CGContextSetStrokeColor(context, borderColour);
        CGContextStrokePath(context);
        
        CGSize shadowOffset = CGSizeMake(0, 0);
        CGContextSaveGState(context);
        CGContextSetShadow (context, shadowOffset, 5);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGFloat shadowColour[4] = {230.0/255, 230.0/255.0, 230.0/255.0, 0.3};
        CGContextSetLineWidth(context, 2.0);
        CGContextAddPath(context, path);
        CGContextSetStrokeColorSpace(context, CGColorSpaceCreateDeviceRGB());
        CGContextSetStrokeColor(context, shadowColour);
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
        
        // 填充矩形内部颜色
        CGContextAddPath(context, path);
        CGContextSetFillColorSpace(context, CGColorSpaceCreateDeviceRGB());
        CGFloat fillColour[4] = {250.0/255, 250.0/255.0, 250.0/255.0, 1};
        CGContextSetFillColor(context, fillColour);
        CGContextEOFillPath(context);
        // 释放内存
        CFRelease(path);
        
        cellHeight += 15;
    }
    
    from = [[UILabel alloc] initWithFrame:CGRectMake(55, cellHeight + 5, 150, 12)];
    from.text = [NSString stringWithFormat:@"来自 %@", [weiboContent objectForKey:@"from"]];
    from.textAlignment = UITextAlignmentLeft;
    from.textColor = [UIColor grayColor];
    from.font = [UIFont systemFontOfSize:11];
    [self addSubview:from];
        
    int qMcount = [[weiboContent objectForKey:@"mcount"] intValue];
    int qCount = [[weiboContent objectForKey:@"count"] intValue];
    if (qMcount + qCount != 0) {
        count = [[UILabel alloc] init];
        count.text = [NSString stringWithFormat:@"%d", qMcount + qCount];
        count.textAlignment = UITextAlignmentLeft;
        count.textColor = [UIColor grayColor];
        count.font = [UIFont systemFontOfSize:11];
        count.lineBreakMode = UILineBreakModeWordWrap;
        count.numberOfLines = 0;
        
        CGSize maximumLabelSize = CGSizeMake(250 ,MAXFLOAT);
        CGSize expectedLabelSize = [count.text sizeWithFont:[UIFont systemFontOfSize:11]
                                                  constrainedToSize:maximumLabelSize 
                                                      lineBreakMode:UILineBreakModeWordWrap];
        
        count.frame = CGRectMake(307 - expectedLabelSize.width, cellHeight + 5, expectedLabelSize.width, expectedLabelSize.height);
        
        [self addSubview:count];
        
        countImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reply.png"]];
        countImage.frame = CGRectMake(307 - expectedLabelSize.width - 16, cellHeight + 7, 12, 11);
        [self addSubview:countImage];
    }
    
}


- (void) dealloc {
    [super dealloc];
    [weiboContent release];
    [head release];
    [label release];
    [date release];
    [oriImage release];
    [sourceContent release];
    [sourceImage release];
    [sourceVideo release];
    [from release];
    [count release];
    [countImage release];
}

@end
