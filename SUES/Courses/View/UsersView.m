//
//  UsersView.m
//  SUES
//
//  Created by lixu on 16/8/26.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "UsersView.h"
#import "Public.h"
#import "AppDelegate.h"
#import "User.h"

@interface UsersView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSArray *imageArray;
@property (nonatomic,strong) NSArray *usersArray;
@end

@implementation UsersView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor orangeColor];
        [self createData];
        [self createTableView];
    }
    return self;
}

-(void)createData
{
    self.imageArray = @[@"myFavo",@"myForum",@"myOrder",@"myNews",@"drawlots"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    self.usersArray = [app.managedObjectContext executeFetchRequest:request error:nil];
}

-(void)createTableView
{
    UITableView *tbView = [[UITableView alloc] initWithFrame:self.bounds];
    tbView.delegate = self;
    tbView.dataSource = self;
    [self addSubview:tbView];
}


#pragma mark - UITableView代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.usersArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    User *user = [self.usersArray objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:self.imageArray[indexPath.row]];
    cell.textLabel.text = user.name;
    cell.detailTextLabel.text = user.userId;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
