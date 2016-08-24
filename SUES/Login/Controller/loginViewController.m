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
#import "Networking.h"

@interface loginViewController ()<UIGestureRecognizerDelegate,MyDownloaderDelegate,NetworkingDelegate>
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
    self.passwordTF.secureTextEntry = YES;
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
    NSString *username = self.usernameTF.text;
    NSString *password = self.passwordTF.text;
    
//    NSString *username = @"023113141";
//    NSString *password = @"lidaye1991";
    
    self.userId = username;
    self.userPassWord = password;
    
    //检查完数据之后，提交数据到服务器
    Networking *networking = [[Networking alloc ] init];
    networking.delegate = self;
    [networking loginRequestWithUserName:username password:password];
}


//HUD提示框
- (void)downloadUserData {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.hud = hud;
    MyDownloader *downloader = [[MyDownloader alloc] init];
    downloader.delegate = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        
        [downloader downloadWithUserId:self.userId userPassWord:self.userPassWord];
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

#pragma - NetworkingDelegaate

-(void)requestFinish:(Networking *)networking returnString:(NSString *)returnString
{
    [self downloadUserData];
}

-(void)requestFail:(Networking *)networking error:(NSString *)error
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = NSLocalizedString(error, @"HUD message title");
    hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
    [hud hideAnimated:YES afterDelay:1.f];
}

@end
