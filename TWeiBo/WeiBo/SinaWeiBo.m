//
//  SinaWeiBo.m
//  WeiBo
//
//  Created by 健锋 章 on 11-8-2.
//  Copyright 2011年 Zelome. All rights reserved.
//

#import "SinaWeiBo.h"
#import "stdlib.h"
#import <CommonCrypto/CommonHMAC.h>
#import "NSString+Util.h"
#import "Encryption.h"
#import "ASIFormDataRequest.h"
#import "NSData+Base64.h"
#import "NSObject+SBJson.h"

#define AppKey @"3259207134"
#define AppSecret @"7857ced7576f16c8bc78c7e37ee0d5e7"
#define OAuthUrl @"http://api.t.sina.com.cn/"
#define ApiUrl @"http://api.t.sina.com.cn/"
#define OAuthVersion @"1.0"
#define OAuthSignatureMethod @"HMAC-SHA1"
#define OAuthFormat @"json"
#define GetMethod @"GET"
#define PostMethod @"POST"

#define OAuthConsumerKeyKey @"oauth_consumer_key"
#define OAuthCallbackKey @"oauth_callback"
#define OAuthVersionKey @"oauth_version"
#define OAuthSignatureMethodKey @"oauth_signature_method"
#define OAuthSignatureKey @"oauth_signature"
#define OAuthTimestampKey @"oauth_timestamp"
#define OAuthNonceKey @"oauth_nonce"
#define OAuthTokenKey @"oauth_token"
#define oAauthVerifier @"oauth_verifier"
#define OAuthTokenSecretKey @"oauth_token_secret"
#define OAuthFormatKey @"format"


#pragma mark -
#pragma mark Static methods

static NSInteger SortParameter(NSString *key1, NSString *key2, void *context) {
	NSComparisonResult r = [key1 compare:key2];
	if(r == NSOrderedSame) { // compare by value in this case
		NSDictionary *dict = (NSDictionary *)context;
		NSString *value1 = [dict objectForKey:key1];
		NSString *value2 = [dict objectForKey:key2];
		return [value1 compare:value2];
	}
	return r;
}

@implementation SinaWeiBo

#pragma mark -
#pragma mark Private method

//Normalizes the request parameters according to the spec.
- (NSString *)normalizedRequestUrl: (NSString *) reqUrl 
                        parameters:(NSDictionary *) parameters {
	
	NSMutableArray *parametersArray = [NSMutableArray array];
	NSArray *sortedKeys = [[parameters allKeys] sortedArrayUsingFunction:SortParameter context:parameters];
	for (NSString *key in sortedKeys) {
		NSString *value = [parameters valueForKey:key];
		[parametersArray addObject:[NSString stringWithFormat:@"%@=%@", [key urlEncode], [value urlEncode]]];
	}
    
	return [NSString stringWithFormat:@"%@?%@", reqUrl, [parametersArray componentsJoinedByString:@"&"]];
}

//Generate the timestamp for the signature.
- (NSString *)generateTimeStamp {
	
	return [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
}

- (NSString *)generateNonce {
	// Just a simple implementation of a random number between 123400 and 9999999
	return [NSString stringWithFormat:@"%u", arc4random() % (9999999 - 123400) + 123400];
}

//生成BaseString
- (NSString *)generateSignatureBaseWithUrl:(NSString *)url 
								httpMethod:(NSString *)httpMethod 
								parameters:(NSDictionary *)parameters {
	
	NSMutableArray *parametersArray = [NSMutableArray array];
	NSArray *sortedKeys = [[parameters allKeys] sortedArrayUsingFunction:SortParameter context:parameters];
	for (NSString *key in sortedKeys) {
		NSString *value = [parameters valueForKey:key];
        [parametersArray addObject:[NSString stringWithFormat:@"%@=%@", [key urlEncode], [value urlEncode]]];
	}
    
	NSString *signatureBaseString = [NSString stringWithFormat:@"%@&%@&%@",
									 httpMethod,
                                     [url urlEncode], 
                                     [[parametersArray componentsJoinedByString:@"&"] urlEncode]];
    
	return signatureBaseString;
}

//生成Signature
- (NSString *) generateSig:(NSString *)reqMethod 
                httpMethod:(NSString *)httpMethod 
                     token:(NSString *)token 
               tokenSecret:(NSString *)tokenSecret
                     nonce:(NSString *)nonce
                 timeStamp:(NSString *)timeStamp
                parameters:(NSDictionary *)parameters {
    
    [parameters setValue:AppKey forKey:OAuthConsumerKeyKey];
    [parameters setValue:OAuthVersion forKey:OAuthVersionKey];
    [parameters setValue:nonce forKey:OAuthNonceKey];
    [parameters setValue:timeStamp forKey:OAuthTimestampKey];
    [parameters setValue:OAuthSignatureMethod forKey:OAuthSignatureMethodKey];
    [parameters setValue:token forKey:OAuthTokenKey];
    
    NSString *reqUrl = [ApiUrl stringByAppendingString:reqMethod];
    
    NSString *baseString = [self generateSignatureBaseWithUrl:reqUrl httpMethod:httpMethod parameters:parameters];
    NSString *sigKey = [AppSecret stringByAppendingFormat:@"%@%@", @"&", tokenSecret];
    
    return [Encryption HMAC_SHA1:baseString withKey:sigKey];    
}

#pragma mark -
#pragma mark QOauth instance methods

- (NSURL *)getOauthUrl:(NSString *)reqMethod 
            httpMethod:(NSString *)httpMethod 
                 token:(NSString *)token
           tokenSecret:(NSString *)tokenSecret
                verify:(NSString *)verify 
           callbackUrl:(NSString *)callbackUrl 
            parameters:(NSMutableDictionary *)parameters {
    
    //RequestToken换取AccessToken是需要的参数
    if (token) {
        [parameters setValue:token forKey:OAuthTokenKey];
    }
    
    if (verify) {
        [parameters setValue:verify forKey:oAauthVerifier];
    }
    
    //获取AccessToken不需要CallBack参数
    if (!callbackUrl) {
        [parameters removeObjectForKey:OAuthCallbackKey];
    }
    
    [parameters setValue:AppKey forKey:OAuthConsumerKeyKey];
    [parameters setValue:callbackUrl forKey:OAuthCallbackKey];
    [parameters setValue:OAuthVersion forKey:OAuthVersionKey];
    [parameters setValue:[self generateNonce] forKey:OAuthNonceKey];
    [parameters setValue:[self generateTimeStamp] forKey:OAuthTimestampKey];
    [parameters setValue:OAuthSignatureMethod forKey:OAuthSignatureMethodKey];
    
    NSString *reqUrl = [OAuthUrl stringByAppendingString:reqMethod];
    
    NSString *baseString = [self generateSignatureBaseWithUrl:reqUrl httpMethod:httpMethod parameters:parameters];
    
    NSString *sigKey = [AppSecret stringByAppendingString:@"&"];
    
    if (token) {
        sigKey = [sigKey stringByAppendingString:[tokenSecret urlEncode]];
    }
    
    NSString *oAuthSignature = [Encryption HMAC_SHA1:baseString withKey:sigKey];
    
    [parameters setValue:oAuthSignature forKey:OAuthSignatureKey];
    
    return [NSURL URLWithString:[self normalizedRequestUrl:reqUrl parameters:parameters]];
}

#pragma mark -
#pragma mark QRequest instance methods

//OAuth同步请求认证
- (NSDictionary *) oauthRequest:(NSURL *) oauthUrl {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:oauthUrl];
    [request startSynchronous];
    NSError *error = [request error];
    NSMutableDictionary *result = [[[NSMutableDictionary alloc] init] autorelease];
        
    if (!error) {
        NSString *response = [request responseString];
        NSArray *resultArray = [response componentsSeparatedByString:@"&"];
        for (NSString *value in resultArray) {
            NSArray *tmp = [value componentsSeparatedByString:@"="];
            [result setValue:[tmp objectAtIndex:1] forKey:[tmp objectAtIndex:0]];
        }
    } else {
        return nil;
    }
    
    return result;
}

- (NSDictionary *) apiSynPostRequest:(NSString *)reqMethod
                               token:(NSString *)token 
                         tokenSecret:(NSString *)tokenSecret
                          parameters:(NSDictionary *)parameters {
    
    //请求URL
    NSURL *reqUrl = [[NSURL alloc] initWithString:[ApiUrl stringByAppendingFormat:@"%@", reqMethod]];
    ASIFormDataRequest *postRequest = [ASIFormDataRequest requestWithURL:reqUrl];
    [reqUrl release];
    
    NSArray *sortedKeys = [[parameters allKeys] sortedArrayUsingFunction:SortParameter context:parameters];
	for (NSString *key in sortedKeys) {
		NSString *value = [parameters valueForKey:key];
		[postRequest addPostValue:value forKey:key];
	}
    
    NSString *nonce = [self generateNonce];
    NSString *timeStamp = [self generateTimeStamp];
    
    
    NSString *sig = [self generateSig:reqMethod 
                           httpMethod:PostMethod 
                                token:token 
                          tokenSecret:tokenSecret 
                                nonce:nonce
                            timeStamp:timeStamp
                           parameters:parameters];

    [postRequest addPostValue:AppKey forKey:OAuthConsumerKeyKey];
    [postRequest addPostValue:OAuthVersion forKey:OAuthVersionKey];
    [postRequest addPostValue:nonce forKey:OAuthNonceKey];
    [postRequest addPostValue:timeStamp forKey:OAuthTimestampKey];
    [postRequest addPostValue:token forKey:OAuthTokenKey];
    [postRequest addPostValue:sig forKey:OAuthSignatureKey];
    [postRequest addPostValue:OAuthSignatureMethod forKey:OAuthSignatureMethodKey];    
    
    [postRequest buildPostBody];
    [postRequest startSynchronous];
    
    NSError *error = [postRequest error];

    if (!error) {
        NSString *postResponse = [postRequest responseString];
        NSLog(@"res:%@", postResponse);
        NSDictionary *returnDic = [postResponse JSONValue];
        return returnDic;
    } else {
        NSLog(@"ERROR:%@", error);
        return nil;
    }
}

- (NSDictionary *) apiSynPostImageWithRequsetMethod:(NSString *)reqMethod
                                               token:(NSString *)token 
                                         tokenSecret:(NSString *)tokenSecret
                                           imageData:(NSData *) imageData
                                          parameters:(NSDictionary *)parameters {
    //请求URL
    NSURL *reqUrl = [[NSURL alloc] initWithString:[ApiUrl stringByAppendingFormat:@"%@", reqMethod]];
    ASIFormDataRequest *postRequest = [ASIFormDataRequest requestWithURL:reqUrl];
    [reqUrl release];
    
    NSArray *sortedKeys = [[parameters allKeys] sortedArrayUsingFunction:SortParameter context:parameters];
	for (NSString *key in sortedKeys) {
		NSString *value = [parameters valueForKey:key];
		[postRequest addPostValue:value forKey:key];
	}
    
    NSString *nonce = [self generateNonce];
    NSString *timeStamp = [self generateTimeStamp];
    
    
    NSString *sig = [self generateSig:reqMethod 
                           httpMethod:PostMethod 
                                token:token 
                          tokenSecret:tokenSecret 
                                nonce:nonce
                            timeStamp:timeStamp
                           parameters:parameters];
    
    [postRequest addPostValue:AppKey forKey:OAuthConsumerKeyKey];
    [postRequest addPostValue:OAuthVersion forKey:OAuthVersionKey];
    [postRequest addPostValue:nonce forKey:OAuthNonceKey];
    [postRequest addPostValue:timeStamp forKey:OAuthTimestampKey];
    [postRequest addPostValue:token forKey:OAuthTokenKey];
    [postRequest addPostValue:sig forKey:OAuthSignatureKey];
    [postRequest addPostValue:OAuthSignatureMethod forKey:OAuthSignatureMethodKey];    
    
    [postRequest setData:imageData forKey:@"pic"];
    
    //[postRequest setDelegate:self];
    
    [postRequest buildPostBody];
    [postRequest startSynchronous];
    
    //return nil;
    
    NSError *error = [postRequest error];
    
    if (!error) {
        NSString *postResponse = [postRequest responseString];
        //NSLog(@"response:%@", postResponse);
        NSDictionary *returnDic = [postResponse JSONValue];
        return returnDic;
    } else {
        //NSLog(@"ERROR:%@", error);
        return nil;
    }
    
}

- (NSURL *) getOrdinaryGetUrl:(NSString *)reqMethod
                        token:(NSString *)token 
                  tokenSecret:(NSString *)tokenSecret
                   parameters:(NSDictionary *)parameters {
    
    [parameters setValue:AppKey forKey:OAuthConsumerKeyKey];
    [parameters setValue:OAuthVersion forKey:OAuthVersionKey];
    [parameters setValue:[self generateNonce] forKey:OAuthNonceKey];
    [parameters setValue:[self generateTimeStamp] forKey:OAuthTimestampKey];
    [parameters setValue:OAuthSignatureMethod forKey:OAuthSignatureMethodKey];
    [parameters setValue:token forKey:OAuthTokenKey];
    
    NSString *reqUrl = [ApiUrl stringByAppendingString:reqMethod];
    NSString *baseString = [self generateSignatureBaseWithUrl:reqUrl httpMethod:GetMethod parameters:parameters];
    
    NSString *sigKey = [AppSecret stringByAppendingFormat:@"%@%@", @"&", tokenSecret];
    
    NSString *oAuthSignature = [Encryption HMAC_SHA1:baseString withKey:sigKey];
    
    [parameters setValue:oAuthSignature forKey:OAuthSignatureKey];
    
    return [NSURL URLWithString:[self normalizedRequestUrl:reqUrl parameters:parameters]];
}

- (NSDictionary *) apiGetRequest:(int)reqType 
                       reqMethod:(NSString *)reqMethod
                           token:(NSString *)token 
                     tokenSecret:(NSString *)tokenSecret
                      parameters:(NSDictionary *)parameters {
    
    NSURL *apiUrl = [self getOrdinaryGetUrl:reqMethod 
                                      token:(NSString *)token 
                                tokenSecret:(NSString *)tokenSecret
                                 parameters:parameters];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:apiUrl];
    
    if (reqType == 1) { //同步请求
        [request startSynchronous];
        NSError *error = [request error];
        if (!error) {
            NSString *responseString = [request responseString];
            NSDictionary *result = [responseString JSONValue];
            return result;
        } else {
            NSLog(@"ERROR:%@", error);
            return nil;
        }
    } else { //异步请求
        [request setDelegate:self];
        [request startAsynchronous];
        return nil;
    }
}

- (NSArray *) apiGetRequestWithReqMethod:(NSString *)reqMethod
                                   token:(NSString *)token 
                             tokenSecret:(NSString *)tokenSecret
                              parameters:(NSDictionary *)parameters {
    
    NSURL *apiUrl = [self getOrdinaryGetUrl:reqMethod 
                                      token:(NSString *)token 
                                tokenSecret:(NSString *)tokenSecret
                                 parameters:parameters];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:apiUrl];
    
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *responseString = [request responseString];
        NSArray *result = [responseString JSONValue];
        return result;
    } else {
        NSLog(@"ERROR:%@", error);
        return nil;
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *responseString = [request responseString];
    NSLog(@"response:%@", responseString);
    NSDictionary *result = [responseString JSONValue];
    NSLog(@"result:%@", result);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@", error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
                                                    message:@"出错了，请稍后重试" 
                                                   delegate:self 
                                          cancelButtonTitle:@"确定" 
                                          otherButtonTitles:nil, 
                          nil];
    [alert show];
    [alert release];
}

@end
