//
//  QQDetailViewController.h
//  TWeiBo
//
//  Created by 健锋 章 on 11-10-5.
//  Copyright (c) 2011年 Zelome Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QQDetailViewController : UIViewController {
    NSDictionary *content;
}

@property(nonatomic, retain) NSDictionary *content;

- (void) setDetailContent:(NSDictionary *) detailContent;

@end
