//
//  UserMessageViewController.m
//  SUES
//
//  Created by lixu on 16/9/12.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "UserMessageViewController.h"
#import "Public.h"

@interface UserMessageViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *tbView;

@property (nonatomic ,strong) NSArray *dataArray;

@end

@implementation UserMessageViewController

-(NSArray *)dataArray
{
    if (!_dataArray) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
//        NSArray *dataArrayOfExam = @[@"其它考试"];
//        [array addObject:dataArrayOfExam];
        for (NSInteger i = 1; i <= NumbersOfYear; i++) {
            NSArray *arr = @[[NSString stringWithFormat:@"第%ld学期",2*i-1],[NSString stringWithFormat:@"第%ld学期",2*i]];
            [array addObject:arr];
        }
        _dataArray = array;
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tbView.sectionIndexBackgroundColor = [UIColor blackColor];
    [self createTableView];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = [self.dataArray objectAtIndex:section];
    return [arr count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSArray *arr = [self.dataArray objectAtIndex:indexPath.section];
    cell.textLabel.text = arr[indexPath.row];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataArray count];
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

@end
