//
//  WeiBoCell.h
//  TWeiBo
//
//  Created by 健锋 章 on 11-9-11.
//  Copyright 2011年 Zelome Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QQWeiBoCell : UITableViewCell {
    NSDictionary *weiboContent;
    
    float cellHeight;
    
    //头像
    UIImageView *head;
    //昵称
    NSString *nick;
    //发送日期
    UILabel *date;
    //微博内容
    UILabel *label;
    //图片
    UIImageView *oriImage;
    
    //source
    UILabel *sourceContent;
    UIImageView *sourceImage;
    UIImageView *sourceVideo;
    
    //来源
    UILabel *from;
    //微博被转次数
    UILabel *count;
    UIImageView *countImage;
}

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier 
            content:(NSDictionary *)content
           userDict:(NSDictionary *)_userDict;


@end
