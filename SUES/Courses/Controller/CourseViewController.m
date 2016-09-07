//
//  CourseViewController.m
//  SUES
//
//  Created by lixu on 16/9/7.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "CourseViewController.h"
#import "WeekView.h"
#import "Public.h"
#import "Courses+Flickr.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "Networking.h"
#import "MyUtil.h"
#import "MenuView.h"
#import "UsersView.h"
#import "AnalyzeCourseData.h"

@interface CourseViewController ()
@property (nonatomic,assign) CGFloat statusHeight;
@property (nonatomic,assign) CGFloat navHeight;
@property (nonatomic,assign) CGFloat tabBarHeight;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) User *user;
@property (nonatomic,assign) BOOL isRefresh;//判断是否是刷新，需要hud提示框提示数据已更新
@property (nonatomic,strong) UsersView *usersView;//显示所有用户
@property (nonatomic,strong) MenuView *menu;//usersView的载体
@property (nonatomic,strong) Networking *networking;//网络活动
@property (nonatomic,strong) WeekView *weekView;
@property (nonatomic,strong) NSString *userPassWord;
@property (nonatomic, strong) NSString *userId;
@end

@implementation CourseViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDid");
    [self observerNotification];
    //获取当前状态栏的高度
    self.statusHeight = [[UIApplication sharedApplication]statusBarFrame].size.height;
    //获取导航栏的高度
    self.navHeight = self.navigationController.navigationBar.frame.size.height;
    //标签栏高度
    self.tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    [self createRefreshButton];
    WeekView *weekView = [[WeekView alloc]initWithFrame:CGRectMake(0, self.statusHeight+self.navHeight, self.view.frame.size.width, self.view.frame.size.height-(self.statusHeight+self.tabBarHeight))];
    self.weekView = weekView;
    
    [self refreshWeekView];
    [self createNextWeekButton];//下一周按钮
    [self createUsersButton];//显示所有用户
    
}

//网络活动
-(Networking *)networking
{
    if (!_networking) {
        _networking = [[Networking alloc] init];
    }
    return _networking;
}

-(User *)user
{
    return [self returnApp].user;
}

-(AppDelegate *)returnApp
{
    return [[UIApplication sharedApplication] delegate];
}

//刷新成绩
-(void)createRefreshButton
{
    UIButton *btn = [MyUtil createBtnFrame:CGRectMake(0, 0, 30, 28) type:UIButtonTypeCustom bgImageName:@"arrow-down" title:nil target:self action:@selector(requestNetworking)];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
}

//请求刷新
-(void)requestNetworking
{
    __weak CourseViewController *weakSelf = self;
    self.networking.requestFinish = ^(NSString *requestString,NSString *error){
        if (!error) {
            weakSelf.isRefresh = YES;
            [weakSelf requestRefreshCourseData];
        } else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.navigationController.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.offset = CGPointMake(0.f, -0.f);
            [hud hideAnimated:YES afterDelay:0.8f];
            hud.label.text = NSLocalizedString(error, @"HUD message title");
        }
    };
    [self.networking requestRefresh];
}

//刷新请求成功，开始请求数据
-(void)requestRefreshCourseData
{
    self.networking.requestHtmlData = ^(NSData *gradeData,NSData *coursesData){
        AnalyzeCourseData *analyzeCourses = [[AnalyzeCourseData alloc] init];
        [analyzeCourses analyzeCoursesHtmlData:coursesData];
    };
    [self.networking requestUserDataWithType:RefreshCourse];
}

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    self.weekView.currentWeek = @"0";
    [self refreshWeekView];
    if (self.isRefresh) {
        MBProgressHUD *hud = [self displayHud];
        hud.label.text = NSLocalizedString(@"课表已更新", @"HUD message title");
        self.isRefresh = NO;
    }
}

//切换周数，按钮
-(void)createNextWeekButton
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    [btn setTitle:@"下一周" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(refreshWeekView) forControlEvents:UIControlEventTouchUpInside];
    [btn setTintColor:[UIColor blackColor]];
    self.navigationItem.titleView = btn;
}

//更新课表
-(void)refreshWeekView
{
    CGRect rect = self.weekView.frame;
    NSString *currentWeek = [NSString stringWithFormat:@"%ld",[self.weekView.currentWeek integerValue] + 1];
    [self.weekView removeFromSuperview];
    WeekView *weekView = [[WeekView alloc] initWithFrame:rect];
    [self.view addSubview:weekView];
    self.weekView = weekView;
    weekView.ctrl = self;
    weekView.currentWeek = currentWeek;
    weekView.user = self.user;
}

//显示一个弹窗
-(MBProgressHUD *)displayHud
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.offset = CGPointMake(0.f, -0.f);
    [hud hideAnimated:YES afterDelay:0.8f];
    return hud;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated//转场动画
{
    CATransition *transition = [CATransition animation];
    [transition setDuration:0.5f];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    [self.tabBarController.view.layer addAnimation:transition forKey:nil];
}

//显示用户列表
-(void)createUsersButton
{
    UIButton *btn = [MyUtil createBtnFrame:CGRectMake(0, 8, 30, 28) type:UIButtonTypeCustom bgImageName:@"users" title:nil target:self action:@selector(displayOrHide)];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = item;
    
    UsersView *usersView = [[UsersView alloc]initWithFrame:CGRectMake(0, self.statusHeight+self.navHeight, [[UIScreen mainScreen] bounds].size.width * 0.8, [[UIScreen mainScreen] bounds].size.height)];
    MenuView *menu = [MenuView MenuViewWithDependencyView:self.view MenuView:usersView isShowCoverView:NO];
    self.menu = menu;
}

-(void)displayOrHide
{
    if (self.menu.coverView.alpha > 0) {
        [self.menu hidenWithAnimation];
    } else {
        [self.menu show];
    }
}

//注册通知
-(void)observerNotification
{
    
    [[NSNotificationCenter defaultCenter]
     addObserverForName:@"sendContextToForeground"
     object:nil
     queue:nil
     usingBlock:^(NSNotification * _Nonnull note) {
         self.managedObjectContext = note.userInfo[@"context"];
     }];
}

@end
