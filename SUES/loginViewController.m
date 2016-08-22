//
//  loginViewController.m
//  Login
//
//  Created by menuz on 14-2-23.
//  Copyright (c) 2014年 menuz's lab. All rights reserved.
//

#import "loginViewController.h"
#import "AppDelegate.h"
#import <AFNetworking.h>
#import "MBProgressHUD.h"

@interface loginViewController ()<UIGestureRecognizerDelegate,UIWebViewDelegate>
@property (nonatomic,strong)UIWebView *webView;
@property (nonatomic,strong) NSString *userId;
@property (nonatomic,strong) NSString *userPassWord;
@property (nonatomic,strong) MBProgressHUD *hud;
@end

@implementation loginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    HUD = [[MBProgressHUD alloc] initWithView:self.view];
//	[self.view addSubview:HUD];
//	
//    //	HUD.delegate = self;
//	HUD.labelText = @"登录中...";
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 567, 375,100)];
    self.webView = webView;//获取完整的网页源码
    self.webView.delegate = self;
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    tap.delegate = self;
}

//隐藏键盘
-(void)dismissKeyboard {
    [self.view endEditing:YES];
    [self.passwordTF resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)Login:(id)sender {
    
    //检查完数据之后，提交数据到服务器
    [self loginWithUser];
}

// 服务器交互进行用户名，密码认证
-(BOOL)loginWithUser {
    
    NSString *username = @"022115212";
    NSString *password = @"015117";
//    NSString *username = self.usernameTF.text;
//    NSString *password = self.passwordTF.text;
    
    NSString *capatcha = @"";
    NSString *gotoOnFaili = @"http://my.sues.edu.cn/loginFailure.portal";
    NSString *gotoSuccess = @"http://my.sues.edu.cn/loginSuccess.portal";
    
    NSDictionary *parameters = @{@"Login.Token1":username,
                                 @"Login.Token2":password,
                                 @"capatcha":capatcha,
                                 @"goto":gotoSuccess,
                                 @"gotoOnFaili":gotoOnFaili
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
        if (![result containsString:@"handleLoginSuccessed"]) {
            NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"RET = %@",result);
            NSLog(@"密码或用户名错误");
        } else{
            self.userId = username;
            self.userPassWord = password;
            [self barDeterminateExample];
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"需要链接学校的无线网error = %@",error);
    }];
    return true;
}

//给webView的URL
-(void)setUrlString:(NSString *)urlString
{
    NSLog(@"setUrlString = %@",urlString);
    //请求数据
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

//HUD提示框
- (void)barDeterminateExample {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.hud = hud;
    // Set the bar determinate mode to show task progress.
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        // Do something useful in the background and update the HUD periodically.
        NSString *URLString = @"http://jxxt.sues.edu.cn/eams/courseTableForStd.action?method=courseTable&setting.forSemester=0&setting.kind=std&semester.id=402&ids=72123730&ignoreHead=1";
        self.urlString = URLString;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [hud hideAnimated:YES];
//        });
    });
}

//webView加载完成之后,把数据传到AppDelegate
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *string = [self.webView stringByEvaluatingJavaScriptFromString: @"document.body.innerHTML"];
    NSLog(@"webViewHTML = %@",string);
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    [app startUserDataWithUserDetail:string userId:self.userId userPassWord:self.userPassWord];
    [self.hud hideAnimated:YES];
    self.hud = nil;
    [app changeRootCtroller];
}


@end
