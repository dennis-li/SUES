//
//  CourseView.h
//  SUES
//
//  Created by lixu on 16/9/8.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourseViewController.h"
#import "User.h"

@interface CourseView : UIImageView
@property (nonatomic,strong)CourseViewController *ctrl;
@property (nonatomic,strong) NSString *currentWeek;
@property (nonatomic,strong) NSArray *dataArray;

//删除所有课程按钮
-(void)removeAllButtons;
@end
