//
//  AnswerQeustionViewController.m
//  SUES
//
//  Created by lixu on 16/9/2.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "AnswerQeustionViewController.h"
#import "MyUtil.h"
#import "Public.h"

@interface AnswerQeustionViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,assign) CGFloat statusHeight;
@property (nonatomic,assign) CGFloat navHeight;
@property (nonatomic,assign) CGFloat tabBarHeight;
//图片
@property (nonatomic,strong)NSArray *imageArray;

//标题
@property (nonatomic,strong)NSArray *titleArray;

@end

@implementation AnswerQeustionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //获取当前状态栏的高度
    self.statusHeight = [[UIApplication sharedApplication]statusBarFrame].size.height;
    //获取导航栏的高度
    self.navHeight = self.navigationController.navigationBar.frame.size.height;
    //标签栏高度
    self.tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    
    [self addNavTitle:@"答疑安排"];

    
    //表格
    [self createData];
    [self createTableView];
}

-(void)createData
{
    self.imageArray = @[@"myFavo",@"myForum",@"myOrder",@"myNews",@"drawlots",@"myOrder"];
    self.titleArray = @[@"课程名称",@"课程学分",@"教师",@"日期",@"时间",@"地点"];
}

-(void)createTableView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UITableView *tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.statusHeight+self.navHeight, ScreenWidth, ScreenHeight)];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    cell.imageView.image = [UIImage imageNamed:self.imageArray[indexPath.row]];
    cell.textLabel.text = self.titleArray[indexPath.row];
    cell.detailTextLabel.text = [self getSubtitleFromAnswerQuestionWithIndexPathRow:indexPath.row];
    return cell;
}

-(NSString *)getSubtitleFromAnswerQuestionWithIndexPathRow:(NSInteger)row
{
    NSString *subTitle = nil;
    switch (row) {
        case 0:
            subTitle = self.answerQuestion.name;
            break;
        case 1:
            subTitle = self.answerQuestion.credit;
            break;
        case 2:
            subTitle = self.answerQuestion.teacher;
            break;
        case 3:
            subTitle = self.answerQuestion.date;
            break;
        case 4:
            subTitle = self.answerQuestion.time;
            break;
        case 5:
            subTitle = self.answerQuestion.locale;
            break;
            
        default:
            break;
    }
    return subTitle;
}

@end
