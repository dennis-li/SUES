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


-(void)requestGradeHtmlData
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:GRADE_URL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if(LX_DEBUG)
            NSLog(@"resutl..grade = %@",result);
        [self.delegate requestFinish:self returnString:result];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.delegate requestFail:self error:@"请求成绩失败"];
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
            [self.delegate requestFail:self error:@"检查网络"];
        } else if (![result containsString:@"handleLoginSuccessed"]) {
            [self.delegate requestFail:self error:@"密码或用户名错误"];
        } else{
            [self.delegate requestFinish:self returnString:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.delegate requestFail:self error:@"检查网络"];
    }];
}

@end
