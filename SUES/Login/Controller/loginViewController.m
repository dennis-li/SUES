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
#import "Networking.h"
#import "MyUtil.h"

@interface loginViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic,strong) AppDelegate *app;
@property (nonatomic,strong) NSString *userId;
@property (nonatomic,strong) NSString *userPassWord;
@property (nonatomic,strong) MBProgressHUD *hud;
@property (nonatomic,strong)Networking *networking;
@end

@implementation loginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createBackButton];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    tap.delegate = self;
    self.passwordTF.secureTextEntry = YES;
}

-(AppDelegate *)app
{
    return [[UIApplication sharedApplication] delegate];
}

-(void)createBackButton
{
    if (self.app.user) {
        UIButton *btn = [MyUtil createBtnFrame:CGRectMake(0, 8, 30, 28) type:UIButtonTypeCustom bgImageName:@"myForum" title:nil target:self action:@selector(back)];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.leftBarButtonItem = item;
    }
}

-(void)back
{
    [self.app changeRootCtroller:YES];
}

-(Networking *)networking
{
    if (!_networking) {
        _networking = [[Networking alloc] init];
    }
    return _networking;
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
//    NSString *username = self.usernameTF.text;
//    NSString *password = self.passwordTF.text;
    
    NSString *username = @"023113141";
    NSString *password = @"lidaye1991";
    
    self.userId = username;
    self.userPassWord = password;
    
    [self downloadUserData];
}


//HUD提示框
- (void)downloadUserData {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.hud = hud;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        __weak loginViewController *weakSelf = self;
        self.networking.requestFinish = ^(NSString *requestString,NSString *error){
            [weakSelf.hud hideAnimated:YES];
            if (!error) {
                [weakSelf.app changeRootCtroller:YES];
            }else {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.navigationController.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = NSLocalizedString(error, @"HUD message title");
                hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                [hud hideAnimated:YES afterDelay:1.f];
            }
        };
        [self.networking loginRequestWithUserName:self.userId password:self.userPassWord];
    });
}

@end
