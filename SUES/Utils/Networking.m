//
//  Networking.m
//  SUES
//
//  Created by lixu on 16/8/23.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "Networking.h"
#import <AFNetworking.h>
#import "Public.h"

@implementation Networking

-(instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

-(void)requesHTMLData
{
    
    NSString *URLString = @"http://jxxt.sues.edu.cn/eams/personGrade.action?method=historyCourseGrade";
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if(LX_DEBUG)
            NSLog(@"resutl..grade = %@",result);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@",error);
    }];
}

-(void)loginRequestWithUserName:(NSString *)username password:(NSString *)password
{
    
    NSDictionary *parameters = @{@"Login.Token1":username,
                                 @"Login.Token2":password,
                                 @"capatcha":FORM_CAPATCHA,
                                 @"goto":FORM_SUCCESS,
                                 @"gotoOnFaili":FORM_GOTOONFILI
                                 };
    //请求的url
    NSString *urlString = @"http://my.sues.edu.cn/userPasswordValidate.portal";
    //请求的managers
    AFHTTPSessionManager *managers = [AFHTTPSessionManager manager];
    //请求的方式：POST
    managers.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    managers.responseSerializer = [AFHTTPResponseSerializer serializer];
    [managers POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功，服务器返回的信息%@",responseObject);
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSLog(@"result = %@",result);
        if (!result) {
            [self.delegate requestFail:@"检查网络"];
        } else if (![result containsString:@"handleLoginSuccessed"]) {
            [self.delegate requestFail:@"密码或用户名错误"];
        } else{
            [self.delegate requestFinish:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.delegate requestFail:@"检查网络"];
    }];
}

@end
