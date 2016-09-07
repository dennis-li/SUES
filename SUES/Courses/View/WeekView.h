//
//  WeekView.h
//  gcdqn
//
//  Created by admin on 16/7/19.
//  Copyright © 2016年 hardtosaygoodbye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimetableViewController.h"
#import "User.h"

@interface WeekView : UIImageView

@property (nonatomic,strong)TimetableViewController *ctrl;
@property (nonatomic,strong) User *user;
@property (nonatomic,strong) NSString *currentWeek;
@end
