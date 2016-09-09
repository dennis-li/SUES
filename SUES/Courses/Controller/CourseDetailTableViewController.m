//
//  CourseDetailTableViewController.m
//  SUES
//
//  Created by lixu on 16/9/9.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "CourseDetailTableViewController.h"
#import "Public.h"

@interface CourseDetailTableViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tbView;
//图片
@property (nonatomic,strong)NSArray *imageArray;

//标题
@property (nonatomic,strong)NSArray *titleArray;

//详情数据
@property (nonatomic,strong)NSArray *dataArray;

@end

@implementation CourseDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addNavTitle:@"详情"];
        
    //表格
    [self createData];
    [self createTableView];//创建表格
}

//注册通知
-(void)addNotification
{
    [[NSNotificationCenter defaultCenter]
     addObserverForName:@"WeekViewToCourseDVC"
     object:nil
     queue:nil
     usingBlock:^(NSNotification * _Nonnull note) {
         if (LX_DEBUG) {
             NSLog(@"notification.success");
         }
         self.model = (TimetableModel *)note.userInfo[@"model"];
         //换算出周几上课
         NSString *courseTime = [NSString stringWithFormat:@"周%@%d-%d节",[self switchWeekDay:self.model.day],[self.model.sectionstart intValue],[self.model.sectionend intValue]];
         self.dataArray = @[self.model.name,self.model.locale,self.model.teacher,courseTime];
         [self.tbView reloadData];
     }];
}

-(NSString *)switchWeekDay:(NSNumber *)day
{
    switch ([day intValue]) {
        case 1:
            return @"一";
        case 2:
            return @"二";
        case 3:
            return @"三";
        case 4:
            return @"四";
        case 5:
            return @"五";
        case 6:
            return @"六";
        case 7:
            return @"日";
    }
    return @"";
}


-(void)createData
{
    self.imageArray = @[@"booklet",@"room",@"teacher",@"clipboard"];
    self.titleArray = @[@"名称",@"教室",@"老师",@"节数"];
}

-(void)createTableView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UITableView *tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.statusHeight+self.navHeight, ScreenWidth, ScreenHeight-self.statusHeight-self.navHeight-self.tabBarHeight) style:UITableViewStylePlain];
    tbView.delegate = self;
    tbView.dataSource = self;
    self.tbView = tbView;
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
    
    //调整图片大小
    CGSize itemSize = CGSizeMake(cell.bounds.size.height*2/3, cell.bounds.size.height*2/3);//图片半径尺寸为cell高度2/3
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cell.textLabel.text = self.titleArray[indexPath.row];
    cell.detailTextLabel.text = self.dataArray[indexPath.row];
    return cell;
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
