//
//  CourseDetailTableViewController.h
//  SUES
//
//  Created by lixu on 16/9/9.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TimetableModel.h"

@interface CourseDetailTableViewController : BaseViewController
@property (nonatomic ,strong) TimetableModel *model;
-(void)addNotification;//注册通知
@end
