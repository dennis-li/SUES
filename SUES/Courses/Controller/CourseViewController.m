//
//  CourseViewController.m
//  SUES
//
//  Created by lixu on 16/9/7.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "CourseViewController.h"
#import "Public.h"
#import "Courses+Flickr.h"
#import "AppDelegate.h"
#import "Networking.h"
#import "MenuView.h"
#import "UsersView.h"
#import "AnalyzeCourseData.h"
#import "TimetableModel.h"
#import "CourseView.h"
#import "SwipeView.h"
#import "PopoverViewController.h"

@interface CourseViewController ()<SwipeViewDelegate,SwipeViewDataSource,UIPopoverPresentationControllerDelegate>
@property (nonatomic,assign) BOOL isRefresh;//判断是否是刷新，需要hud提示框提示数据已更新
@property (nonatomic,strong) UsersView *usersView;//显示所有用户
@property (nonatomic,strong) MenuView *menu;//usersView的载体
@property (nonatomic,strong) Networking *networking;//网络活动
@property (nonatomic,strong) NSArray *dataArray;//课表数据源
@property (nonatomic,strong) SwipeView *swipeView;//存放时刻只存放三张课表，用于左右滑动。
@property (nonatomic,strong) NSMutableArray *items;//swipeView的数据源
@property (nonatomic,strong) PopoverViewController *popover;//选择第几周
@end

@implementation CourseViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createSwipeViewWithCurrentItemIndex:1];//用于左右滑动，浏览课表,默认当前为第一周
    [self observerNotification];//注册通知，数据改变时。更新UI
    [self createRefreshButton];//刷新按钮
    [self fetchDataArray];//获取数据源
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

//创建swipe视图，保证时刻只有三个courseView
-(void)createSwipeViewWithCurrentItemIndex:(NSInteger)index
{
    self.items = [NSMutableArray array];
    for (int i = 1; i <= NumbersOfWeek; i++)
    {
        [_items addObject:@(i)];
    }
    SwipeView *swipeView = [[SwipeView alloc] init];
    swipeView.delegate = self;
    swipeView.dataSource = self;
    [self.view addSubview:swipeView];
    swipeView.currentItemIndex = index;
    self.swipeView = swipeView;
    [self addNavTitle:[NSString stringWithFormat:@"第%ld周",swipeView.currentItemIndex+1]];
    
    [swipeView setBackgroundColor:[UIColor blackColor]];
    //将子view添加到父视图上
    [self.view addSubview:swipeView];
    //使用Auto Layout约束，禁止将Autoresizing Mask转换为约束
    [swipeView setTranslatesAutoresizingMaskIntoConstraints:NO];
    //layout 子view
    //子view的上边缘
    NSLayoutConstraint *contraint1 = [NSLayoutConstraint constraintWithItem:swipeView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.statusHeight+self.navHeight];
    //子view的左边缘
    NSLayoutConstraint *contraint2 = [NSLayoutConstraint constraintWithItem:swipeView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    //子view的下边缘
    NSLayoutConstraint *contraint3 = [NSLayoutConstraint constraintWithItem:swipeView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    //子view的右边缘
    NSLayoutConstraint *contraint4 = [NSLayoutConstraint constraintWithItem:swipeView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    //把约束添加到父视图上
    NSArray *array = [NSArray arrayWithObjects:contraint1, contraint2, contraint3, contraint4, nil];
    [self.view addConstraints:array];
}

//刷新成绩
-(void)createRefreshButton
{
    UIButton *btn = [MyUtil createBtnFrame:CGRectMake(0, 0, 30, 28) type:UIButtonTypeCustom bgImageName:@"arrow-down" title:nil target:self action:@selector(displayChoiceWeekPopoverView)];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
}

//选择显示第几周的课程
-(void)displayChoiceWeekPopoverView
{
    UIButton *rightBarButton = (UIButton *)self.navigationItem.rightBarButtonItem.customView;
    [rightBarButton setBackgroundImage:[UIImage imageNamed:@"arrow-up"] forState:UIControlStateNormal];
    self.popover = [[PopoverViewController alloc] init];
    self.popover.modalPresentationStyle = UIModalPresentationPopover;
    self.popover.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;  //rect参数是以view的左上角为坐标原点（0，0）
    self.popover.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUnknown; //箭头方向,如果是baritem不设置方向，会默认up，up的效果也是最理想的
//    self.popover.preferredContentSize = CGSizeMake(ScreenWidth/2, ScreenWidth*2/3);
    self.popover.popoverPresentationController.delegate = self;
    [self presentViewController:self.popover animated:YES completion:nil];
}

#pragma - mark UIPresentationControllerDelegate
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}

//popover消失
-(void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    [self settingRightBarButtonImage];
}

//更换导航栏右侧按钮图片指向
-(void)settingRightBarButtonImage
{
    UIButton *rightBarButton = (UIButton *)self.navigationItem.rightBarButtonItem.customView;
    [rightBarButton setBackgroundImage:[UIImage imageNamed:@"arrow-down"] forState:UIControlStateNormal];
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

//刷新请求成功(服务器验证帐号密码成功)，开始请求数据
-(void)requestRefreshCourseData
{
    self.networking.requestHtmlData = ^(NSData *gradeData,NSData *coursesData){
        AnalyzeCourseData *analyzeCourses = [[AnalyzeCourseData alloc] init];
        [analyzeCourses analyzeCoursesHtmlData:coursesData];
    };
    [self.networking requestUserDataWithType:RefreshCourse];
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

//左上角显示用户列表
-(void)createUsersButton
{
    UIButton *btn = [MyUtil createBtnFrame:CGRectMake(0, 8, 30, 28) type:UIButtonTypeCustom bgImageName:@"profle" title:nil target:self action:@selector(displayOrHide)];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = item;
    
    UsersView *usersView = [[UsersView alloc]initWithFrame:CGRectMake(0, self.statusHeight+self.navHeight, [[UIScreen mainScreen] bounds].size.width * 0.8, [[UIScreen mainScreen] bounds].size.height)];
    MenuView *menu = [MenuView MenuViewWithDependencyView:self.view MenuView:usersView isShowCoverView:NO];
    self.menu = menu;
}

//隐藏或显示用户表
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
     addObserverForName:@"sendCurentItemIndexToForeground"
     object:nil
     queue:nil
     usingBlock:^(NSNotification * _Nonnull note) {
         [self.popover dismissViewControllerAnimated:YES completion:^{
             [self settingRightBarButtonImage];//导航栏右侧图片，反向
         }];
         NSInteger index = [note.userInfo[@"CurentItemIndex"] integerValue];
         [self refreshSwipeViewWithCurrentItemIndex:index];//刷新swipeView
         if (self.isRefresh) {
             MBProgressHUD *hud = [self displayHud];
             hud.label.text = NSLocalizedString(@"课表已更新", @"HUD message title");
             self.isRefresh = NO;
         }
     }];
}

//更新swipeView
-(void)refreshSwipeViewWithCurrentItemIndex:(NSInteger)index
{
    [self fetchDataArray];
    [self.swipeView removeFromSuperview];
    [self createSwipeViewWithCurrentItemIndex:index];
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

//获取课表数据源
-(void)fetchDataArray
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Courses"];
    request.predicate = [NSPredicate predicateWithFormat:@"whoCourse = %@", self.user];
    NSArray *courseArray = [self.user.managedObjectContext executeFetchRequest:request error:nil];
    
    NSMutableArray *modelArray = [[NSMutableArray alloc]init];
    for(Courses *course in courseArray)
    {
        TimetableModel *model = [[TimetableModel alloc]init];
        model.name = course.name;
        model.smartPeriod = course.smartPeriod;
        model.day = course.day;
        model.sectionstart = course.sectionstart;
        model.sectionend = course.sectionend;
        model.teacher = course.teacher;
        model.locale = course.locale;
        model.period = course.period;
        [modelArray addObject:model];
    }
    self.dataArray = modelArray;
}

#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return [_items count];
}

//配置swipeView
- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    //创建一个新的courseView
    if (view == nil)
    {
        CourseView *courseView = [[CourseView alloc] initWithFrame:self.swipeView.bounds];
        courseView.currentWeek = [_items[index] stringValue];
        courseView.dataArray = self.dataArray;
        courseView.ctrl = self;
        view = courseView;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    } else{//重用
        CourseView *courseView = (CourseView *)view;
        [courseView removeAllButtons];
        courseView.currentWeek = [_items[index] stringValue];
        courseView.dataArray = self.dataArray;
        view = courseView;
    }
    return view;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return self.swipeView.bounds.size;
}

//改变导航栏标题
-(void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    [self addNavTitle:[NSString stringWithFormat:@"第%ld周",swipeView.currentItemIndex+1]];
}
@end
