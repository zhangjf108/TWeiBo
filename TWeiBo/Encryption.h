//
//  EncryptionUtil.h
//  WeiBo
//
//  Created by 章 健锋 on 11-7-4.
//  Copyright 2011年 The9. All rights reserved.
//



@interface Encryption : NSObject

//HMAC_SHA1
+ (NSString *)HMAC_SHA1:(NSString *) data withKey:(NSString *) key;

@end
