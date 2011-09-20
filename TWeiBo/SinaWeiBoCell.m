//
//  WeiBoCell.m
//  TWeiBo
//
//  Created by 健锋 章 on 11-9-11.
//  Copyright 2011年 Zelome Inc. All rights reserved.
//

#import "SinaWeiBoCell.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+Util.h"
#import "StringUtil.h"

@implementation SinaWeiBoCell

static int currentTime;

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
-(NSString *) getDateFormat:(NSString *) dateString {
    
    NSDateFormatter* dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    
    [dateFormat setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:usLocale];  
    
    NSDate *dateTemp =[dateFormat dateFromString:dateString];
    
    int timeStamp = (int)[dateTemp timeIntervalSince1970]; 
    
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
            content:(NSDictionary *)content {
    
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        weiboContent = content;
        [weiboContent retain];
    
        
        //NSLog(@"%@", userDict);
        
        //当前时间戳
        currentTime = (int)[[NSDate date] timeIntervalSince1970];
        cellHeight = 26;        
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    NSDictionary *user = [weiboContent objectForKey:@"user"];
    NSArray *contentKeys = [weiboContent allKeys];
    
    head = [[UIImageView alloc] initWithFrame:getFrameByType(@"head")];
    [head setImageWithURL:[NSURL URLWithString:[user objectForKey:@"profile_image_url"]]
         placeholderImage:[UIImage imageNamed:@"sina48.png"]];
        
    head.layer.masksToBounds = YES;
    head.layer.cornerRadius = 5.0;
    head.layer.borderWidth = 2.0;
    head.layer.borderColor = [[UIColor clearColor] CGColor];
    [self addSubview:head];
        
    //昵称
    nick = [user objectForKey:@"name"];
    [nick drawInRect:getFrameByType(@"nick")
            withFont:[UIFont fontWithName:@"Arial Hebrew" size:16]];
    
    //微博内容    
    if ([contentKeys containsObject:@"text"]) {
        label = [[UILabel alloc] init];
        label.text = [[weiboContent objectForKey:@"text"] htmlEscape];
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
    NSString *dateText = [self getDateFormat:[weiboContent objectForKey:@"created_at"]];
    date = [[UILabel alloc] init];
    date.text = dateText;
    date.textAlignment = UITextAlignmentRight;
    date.textColor = [UIColor orangeColor];
    date.font = [UIFont systemFontOfSize:12];
    date.frame = getFrameByType(@"date");
    [self addSubview:date];
    
    
    
    //图片
    if ([contentKeys containsObject:@"thumbnail_pic"]) {
        oriImage = [[UIImageView alloc] initWithFrame:CGRectMake(55, cellHeight + 5, 80, 80)];
        NSString *imageUrl = [weiboContent objectForKey:@"thumbnail_pic"];
        [oriImage setImageWithURL:[NSURL URLWithString:imageUrl]
                 placeholderImage:[UIImage imageNamed:@"sina48.png"]];
        oriImage.contentMode = UIViewContentModeScaleAspectFit;
        oriImage.layer.masksToBounds = YES;
        oriImage.layer.cornerRadius = 2.0; 
        oriImage.layer.borderWidth = 0.5;
        oriImage.layer.borderColor = [[UIColor whiteColor] CGColor];
        [self addSubview:oriImage];
        
        cellHeight += 86;
    }
    
    if ([contentKeys containsObject:@"retweeted_status"]) {
        NSDictionary *source = [weiboContent objectForKey:@"retweeted_status"];
        
        NSDictionary *retweetUser = [source objectForKey:@"user"];
        NSArray *retweetKeys = [source allKeys];

        NSString *soureString = [[source objectForKey:@"text"] htmlEscape];
        //内容
        sourceContent = [[UILabel alloc] init];
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
        
        sourceContent.frame = CGRectMake(64, cellHeight + 10, expectedLabelSize.width - 2,expectedLabelSize.height);
        [self addSubview:sourceContent];
        
        cellHeight += (expectedLabelSize.height + 3);
        
        if ([retweetKeys containsObject:@"thumbnail_pic"]) {
            sourceImage = [[UIImageView alloc] initWithFrame:CGRectMake(65, cellHeight + 10, 80, 80)];
            NSString *soureImageUrl = [source objectForKey:@"thumbnail_pic"];
            [sourceImage setImageWithURL:[NSURL URLWithString:soureImageUrl] 
                        placeholderImage:[UIImage imageNamed:@"sina48.png"]];
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
        
        if ([retweetKeys containsObject:@"thumbnail_pic"]) {
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
    from.text = @"来自 新浪微博";
    from.textAlignment = UITextAlignmentLeft;
    from.textColor = [UIColor grayColor];
    from.font = [UIFont systemFontOfSize:11];
    [self addSubview:from];
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
}

@end
