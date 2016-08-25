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
#import "MyDownloader.h"

@interface Networking ()<MyDownloaderDelegate,UIWebViewDelegate>

@property (nonatomic,strong)MyDownloader *downloader;
@property (nonatomic,strong)UIWebView *webView;
@property (nonatomic,strong)NSString *userId;
@property (nonatomic,strong)NSString *userPassword;

@end

@implementation Networking

-(instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

-(MyDownloader *)downloader
{
    if (!_downloader) {
        _downloader = [[MyDownloader alloc] init];
    }
    return _downloader;
}

-(UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        NSURL *url = [NSURL URLWithString:COURSE_URL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_webView loadRequest:request];
    }
    return _webView;
}


-(void)loginRequestWithUserName:(NSString *)userId password:(NSString *)userPassword
{
    self.userId = userId;
    self.userPassword = userPassword;
    [self verifyUserIdAndPassword];
}

//验证用户信息
-(void)verifyUserIdAndPassword
{
    NSDictionary *parameters = @{@"Login.Token1":self.userId,
                                 @"Login.Token2":self.userPassword,
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
        if ([result containsString:@"handleLoginSuccessed"]) {
            [self requestGradeHtmlData];
            self.webView.delegate = self;
        } else if ([result containsString:@"handleLoginFailure"]) {
            self.requestFinish(nil,@"密码或用户名错误");
        } else{
            self.requestFinish(nil,@"检查网络");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.requestFinish(nil,@"检查网络");
    }];
}

//请求成绩数据
-(void)requestGradeHtmlData
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:GRADE_URL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if(LX_DEBUG)
            NSLog(@"resutl..grade = %@",result);
        [self.downloader loginAnalyzeUserWithGradeHtmlData:[result dataUsingEncoding:NSUTF8StringEncoding] userId:self.userId password:self.userPassword];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    }];
}

#pragma - mark UIWebViewDelegate
-(void)webViewDidFinishLoad:(UIWebView *)webView//加载完成，分析网页内容
{
    NSString *string = [self.webView stringByEvaluatingJavaScriptFromString: @"document.body.innerHTML"];
    NSLog(@"CourseHTML = %@",string);
    [self.downloader analyzeCoursesHtmlData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    self.requestFinish(@" ",nil);
}

#pragma - mark MydownloaderDelegate
-(void)downloadFinish:(MyDownloader *)downloader
{
    
}

-(void)downloadFail:(MyDownloader *)downloader error:(NSError *)error
{
    
}

@end
