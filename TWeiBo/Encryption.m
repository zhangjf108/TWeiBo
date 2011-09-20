//
//  EncryptionUtil.m
//  WeiBo
//
//  Created by 章 健锋 on 11-7-4.
//  Copyright 2011年 The9. All rights reserved.
//

#import "Encryption.h"
#import "NSData+Base64.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation Encryption

+ (NSString *)HMAC_SHA1:(NSString *)data withKey:(NSString *)key {
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
    
    NSString *hash = [HMAC base64EncodedString];
    [HMAC release];
    
    return hash;
}

@end
