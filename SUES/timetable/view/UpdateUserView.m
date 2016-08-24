//
//  UpdateUserView.m
//  SUES
//
//  Created by lixu on 16/8/20.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "UpdateUserView.h"
#import <AFNetworking.h>


@interface UpdateUserView ()
@property (nonatomic,strong) UILabel *userIdLabel;
@property (nonatomic,strong) UILabel *userPassWordLabel;
@property (nonatomic,strong) UITextField *userId;
@property (nonatomic,strong) UITextField *userPass;
@property (nonatomic,strong) UIButton *submitButton;

@end

@implementation UpdateUserView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        //初始化当前周数
        [self createFrom];
        [self addView];
    }
    return self;
}

-(void)createFrom
{
    self.userIdLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, self.frame.size.height/4, 50, 50)];
    self.userIdLabel.text = @"学号";
    self.userPassWordLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, self.frame.size.height/3, 50, 50)];
    self.userPassWordLabel.text = @"学号";
    
    self.userId = [[UITextField alloc] initWithFrame:CGRectMake(100, self.frame.size.height/4, self.frame.size.width-200, 30)];
    self.userPass = [[UITextField alloc] initWithFrame:CGRectMake(100, self.frame.size.height/3, self.frame.size.width-200, 30)];
    self.userPass.secureTextEntry = YES;
    self.userPass.borderStyle = UITextBorderStyleLine;
    self.userId.borderStyle = UITextBorderStyleLine;
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    submitButton.frame =  CGRectMake(self.frame.size.width/2-25, self.frame.size.height/3+50, 50, 50);
    
    [submitButton setTitle:@"登录" forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    submitButton.backgroundColor = [UIColor redColor];
    self.submitButton = submitButton;
}

-(void)submit
{
    NSString *username = @"023113141";
    NSString *password = @"lidaye1991";
//    NSString *username = self.userId.text;
//    NSString *password = self.userPass.text;
    
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
        NSString *ret = @"<script type=\"text/javascript\">(opener || parent).handleLoginSuccessed();</script>";
        NSLog(@"result = %@",result);
        if (![result containsString:@"handleLoginSuccessed"]) {
            NSLog(@"密码或用户名错误");
        } else{
            [self.delegate signFinish:username pass:password];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"需要链接学校的无线网error = %@",error);
    }];
     //<script type="text/javascript">(opener || parent).handleLoginSuccessed();</script>
}

-(void)addView
{
    [self addSubview:self.userPass];
    [self addSubview:self.userPassWordLabel];
    [self addSubview:self.userId];
    [self addSubview:self.userIdLabel];
    [self addSubview:self.submitButton];
}

@end
