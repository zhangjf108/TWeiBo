//
//  UIImage+Compress.h
//  TWeiBo
//
//  Created by 健锋 章 on 11-9-14.
//  Copyright (c) 2011年 Zelome Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Compress)

- (UIImage *)compressedImage;  

- (CGFloat)compressionQuality;  

- (NSData *)compressedData;  

- (NSData *)compressedData:(CGFloat)compressionQuality;

@end
