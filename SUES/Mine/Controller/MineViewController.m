//
//  MineViewController.m
//  SohuByObject_C
//
//  Created by lixu on 16/4/8.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "MineViewController.h"
#import "MyUtil.h"
#import "Public.h"
#import "AppDelegate.h"
#import "loginViewController.h"

@interface MineViewController ()<UITableViewDataSource,UITableViewDelegate>
//图片
@property (nonatomic,strong)NSArray *imageArray;

//标题
@property (nonatomic,strong)NSArray *titleArray;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addNavTitle:@"我的"];
    
    //登陆的图片
    [self createLoginView];
    
    //表格
    [self createData];
    [self createTableView];
}

//创建登录视图
-(void)createLoginView
{
    UIImageView *imageView = [MyUtil createImageViewFrame:CGRectMake(0, self.statusHeight+self.navHeight, ScreenWidth, ScreenHeight*0.3) imageName:@"mySpaceBkgnd"];
    [self.view addSubview:imageView];
    UIButton *loginBtn = [MyUtil createBtnFrame:CGRectMake(ScreenWidth/2, 60, 40, 40) type:UIButtonTypeCustom bgImageName:@"loginPic" title:nil target:self action:@selector(loginAction:)];
    imageView.userInteractionEnabled = YES;
    [imageView addSubview:loginBtn];
}

-(void)createData
{
    self.imageArray = @[@"myFavo",@"myForum",@"myOrder",@"myNews",@"drawlots"];
    self.titleArray = @[@"添加帐号",@"更新成绩",@"更新课表",@"更新考试安排",@"xxx"];
}

-(void)createTableView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UITableView *tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.statusHeight+self.navHeight+ScreenHeight*0.3, ScreenWidth, ScreenHeight-self.statusHeight-self.navHeight-self.tabBarHeight-ScreenHeight*0.3) style:UITableViewStylePlain];
    tbView.delegate = self;
    tbView.dataSource = self;
    [self.view addSubview:tbView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.imageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    cell.imageView.image = [UIImage imageNamed:self.imageArray[indexPath.row]];
    cell.textLabel.text = self.titleArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        loginViewController *courseDVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginVC"];
        [self.navigationController pushViewController:courseDVC animated:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    CATransition *transition = [CATransition animation];
    [transition setDuration:0.5f];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromLeft;
    [self.tabBarController.view.layer addAnimation:transition forKey:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
