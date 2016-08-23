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
#import "MyDownloader.h"

@interface loginViewController ()<UIGestureRecognizerDelegate,MyDownloaderDelegate>
@property (nonatomic,strong) NSString *userId;
@property (nonatomic,strong) NSString *userPassWord;
@property (nonatomic,strong) MBProgressHUD *hud;
@end

@implementation loginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    NSString *username = @"023113141";
    NSString *password = @"lidaye1991";
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


//HUD提示框
- (void)barDeterminateExample {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.hud = hud;
    // Set the bar determinate mode to show task progress.
    MyDownloader *downloader = [[MyDownloader alloc] init];
    downloader.delegate = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        // Do something useful in the background and update the HUD periodically.courseTableForStd.action?method=stdHome
        NSString *URLString = @"http://jxxt.sues.edu.cn/eams/courseTableForStd.action?method=courseTable&setting.forSemester=0&setting.kind=std&semester.id=402&ids=72123730&ignoreHead=1";
//        NSString *URLString = @"http://jxxt.sues.edu.cn/eams/courseTableForStd.action?method=stdHome";
#warning 暂时用DownloadCourses
        [downloader downloadWithUrlString:URLString downloadType:DownloadCourses userId:self.userId userPassWord:self.userPassWord];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [hud hideAnimated:YES];
//        });
    });
}

#pragma - mark MyDownloaderDelegate

-(void)downloadFinish:(MyDownloader *)downloader
{
    [self.hud hideAnimated:YES];
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    [app changeRootCtroller];
}

-(void)downloadFail:(MyDownloader *)downloader error:(NSError *)error
{
    NSLog(@"加载数据失败");
}


@end
