//
//  TimetableModel.h
//  gcdqn
//
//  Created by admin on 16/7/25.
//  Copyright © 2016年 hardtosaygoodbye. All rights reserved.
//

/*
 
 "autoEntry": false,
 "courseId": 74328942,
 "courseMark": 1,
 "courseType": 0,
 "day": 3,
 "endSchoolYear": "2016",
 "id": 74328942,
 "locale": "松1125",
 "maxCount": 14,
 "name": "操作系统",
 "period": "1-8周",
 "schoolId": 2008,
 "schoolName": "东华大学",
 "sectionend": 4,
 "sectionstart": 3,
 "semester": "2",
 "smartPeriod": "1 2 3 4 5 6 7 8",
 "startSchoolYear": "2015",
 "teacher": "白恩健",
 "verifyStatus": 1
 */
#import <Foundation/Foundation.h>
@interface TimetableModel : NSObject
@property (nonatomic,copy) NSString *period;//上课时间，第几周到第几周
@property (nonatomic,copy) NSString *locale;//上课地点
@property (nonatomic,copy) NSString *teacher;//任课老师
@property (nonatomic,copy) NSString *name;//课程名称
@property (nonatomic,copy) NSString *smartPeriod;//具体上课的周
@property (nonatomic,strong) NSNumber *day;//周几上课
@property (nonatomic,strong) NSNumber *sectionstart;//第几节开始上
@property (nonatomic,strong) NSNumber *sectionend;//上到第几节结束
@end
