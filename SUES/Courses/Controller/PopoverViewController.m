//
//  PopoverViewController.m
//  SUES
//
//  Created by lixu on 16/9/10.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "PopoverViewController.h"
#import "Public.h"

@interface PopoverViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)NSArray *dataArray;
@property (nonatomic,strong)UITableView *tableView;
@end

@implementation PopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.preferredContentSize = CGSizeMake(ScreenWidth/2, ScreenWidth*2/3);
    UITableView *tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth/2, ScreenWidth*2/3)];
    tbView.dataSource = self;
    tbView.delegate = self;
    tbView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView = tbView;
    [self.view addSubview:tbView];
}

-(NSArray *)dataArray
{
    if (!_dataArray) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (NSInteger i = 1; i <= NumbersOfWeek; i++) {
            [arr addObject:@(i)];
        }
        _dataArray = arr;
    }
    return _dataArray;
}

#pragma mark - UITableView代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第%@周",[self.dataArray[indexPath.row] stringValue]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //前台更新当前显示周数
    NSDictionary *userInfo = @{@"CurentItemIndex" : @(indexPath.row)};
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"sendCurentItemIndexToForeground"
     object:self
     userInfo:userInfo];
}

//重写preferredContentSize，让popover返回期望的大小
//- (CGSize)preferredContentSize {
//    if (self.presentingViewController && self.tableView != nil) {
//        CGSize tempSize = self.presentingViewController.view.bounds.size;
//        tempSize.width = ScreenWidth/2;
////        CGSize tempSize = CGSizeMake(ScreenWidth/2, ScreenWidth*2/3);
//        CGSize size = [self.tableView sizeThatFits:tempSize];  //sizeThatFits返回的是最合适的尺寸，但不会改变控件的大小
//        return size;
//    }else {
//        return [super preferredContentSize];
//    }
//}
//
//- (void)setPreferredContentSize:(CGSize)preferredContentSize{
//    super.preferredContentSize = preferredContentSize;
//}
@end
