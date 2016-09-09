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
@property (nonatomic,strong) AppDelegate *app;
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

-(AppDelegate *)app
{
    if (!_app) {
        _app = [[UIApplication sharedApplication] delegate];
    }
    return _app;
}

//创建数据源
-(void)createData
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    self.usersArray = [self.app.managedObjectContext executeFetchRequest:request error:nil];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    User *user = [self.usersArray objectAtIndex:indexPath.row];
    
    /*
     *如果用切好的图片可以调整大小
     *
    cell.imageView.image = [UIImage imageNamed:self.imageArray[indexPath.row]];
    //调整图片大小
    CGSize itemSize = CGSizeMake(30, 30);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    */
    
    NSString *text = [user.name substringWithRange:NSMakeRange(0, 1)];//名字的第一个字
    UIImage *image = [self createImageFromColorWithRect:CGRectMake(0, 0, cell.bounds.size.height/2, cell.bounds.size.height/2)];//创建一个纯色图片
    cell.imageView.image = [self drawText:text inImage:image atPoint:CGPointMake(image.size.height/4, image.size.width/4)];//把名字第一个字写到图片上
    cell.imageView.layer.cornerRadius = image.size.height/2;
    cell.imageView.layer.masksToBounds = YES;
    
    cell.textLabel.text = user.name;
    cell.detailTextLabel.text = user.userId;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.app.user = [self.usersArray objectAtIndex:indexPath.row];
    [self sendNotificationToCourseTable];
}

//处理完数据发送通知到前台
-(void)sendNotificationToCourseTable
{
    NSDictionary *userInfo = @{@"context" : self.app.user.managedObjectContext};
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"sendContextToForeground"
     object:self
     userInfo:userInfo];
}

//添加文字到图片上
-(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    [text drawInRect:CGRectIntegral(rect) withAttributes:@{NSForegroundColorAttributeName: [UIColor grayColor], NSFontAttributeName:[UIFont systemFontOfSize:image.size.height/2 weight:image.size.width/2]}];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//获取一个纯色图片
- (UIImage *)createImageFromColorWithRect:(CGRect)rect{
    UIColor *color = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:0.7];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
