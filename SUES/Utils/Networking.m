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
#import "AppDelegate.h"
#import "User.h"
#import "TFHpple.h"

@interface Networking ()<MyDownloaderDelegate,UIWebViewDelegate>
@property (nonatomic,strong)MyDownloader *downloader;
@property (nonatomic,strong)UIWebView *webView;
@property (nonatomic,strong)User *user;
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

-(User *)user
{
    return [self returnApp].user;
}

-(AppDelegate *)returnApp
{
    return [[UIApplication sharedApplication] delegate];
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
        _webView.delegate = self;
    }
    return _webView;
}

//登录
-(void)loginRequestWithUserName:(NSString *)userId password:(NSString *)userPassword
{
    self.userId = userId;
    self.userPassword = userPassword;
    [self verifyUserIdAndPassword];
}

//刷新数据
-(void)refreshHtmlDataWithNetworkingType:(NetworkingType)type
{
    self.type = type;
    self.userId = self.user.userId;
    self.userPassword = self.user.password;
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
            if (self.type == RefreshCourse) {
                [self requestCoursesHtmlData];
            } else {
                [self requestGradeHtmlData];
            }
            
        } else if ([result containsString:@"handleLoginFailure"]) {
            self.requestFinish(nil,@"密码或用户名错误");
        } else{
            self.requestFinish(nil,@"检查网络");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.requestFinish(nil,@"检查网络");
    }];
}

#pragma - mark 请求成绩数据
//请求成绩
-(void)requestGradeHtmlData
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:GRADE_URL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSData *htmlData = [result dataUsingEncoding:NSUTF8StringEncoding];
        if(LX_DEBUG)
            NSLog(@"resutl..grade = %@",result);
#warning - mark 以后任务多了，可以换成switch
        if (self.type == RefreshGrade) {
            [self.downloader analyzeGradeHtmlData:htmlData];
        } else {//把成绩存到数据库
            [self returnApp].user = nil;//添加新用户
            [self.downloader loginAnalyzeUserWithGradeHtmlData:htmlData userId:self.userId password:self.userPassword];
            [self requestCoursesHtmlData];//接着下载课表数据
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.requestFinish(nil,@"服务器繁忙");
    }];
}

#pragma - mark UIWebView
-(void)requestCoursesHtmlData
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:COURSE_GET_URL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSData *htmlData=[result dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
        NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[@class='frameTable']/tr/td/iframe"];
        NSLog(@"courseURL = %@",result);
        for (TFHppleElement *element in elements) {
            if ([[element objectForKey:@"id"] isEqualToString:@"contentListFrame"]) {
                NSLog(@"url = %@",[element objectForKey:@"src"]);
                NSString *coursesURL = [element objectForKey:@"src"];
                NSURL *url = [NSURL URLWithString:[SUES_URL stringByAppendingString:coursesURL]];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [self.webView loadRequest:request];//加载UIWebView,加载结束自动调用delegate方法
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
        
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView//加载完成，分析网页内容
{
    NSString *string = [self.webView stringByEvaluatingJavaScriptFromString: @"document.body.innerHTML"];
    NSLog(@"CourseHTML = %@",string);
    //把课表存到数据库
    [self saveCourseToCoreData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    [self.webView removeFromSuperview];
    self.requestFinish(@" ",nil);
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.requestFinish(nil,@"请检查网络");
}

#pragma - mark 保存课表到数据库
-(void)saveCourseToCoreData:(NSData *)htmlData
{
    [self.downloader analyzeCoursesHtmlData:htmlData];
}

#pragma - mark MydownloaderDelegate
-(void)downloadFinish:(MyDownloader *)downloader
{
    
}

-(void)downloadFail:(MyDownloader *)downloader error:(NSError *)error
{
    
}

@end
