//
//  Public.h
//  gcdqn
//
//  Created by admin on 16/7/19.
//  Copyright © 2016年 hardtosaygoodbye. All rights reserved.
//

#ifndef Public_h
#define Public_h

//系统的版本号
#define SystemVersion ([[[UIDevice currentDevice]systemVersion]floatValue])

//获取设备的物理高度
#define ScreenHeight ([UIScreen mainScreen].bounds.size.height)

//获取设备的物理宽度
#define ScreenWidth ([UIScreen mainScreen].bounds.size.width)

//快捷rgb颜色
#define RGBColor(r,g,b,a) ([UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a])

//李旭调试代码
#define LX_DEBUG 1

//公共部分
#define COURSE_SEMESTER @"semester"
#define COURSE_STARTSCHOOLYEAR @"startSchoolYear"
#define COURSE_NAME @"name"
#define COURSE_ID @"courseId"

//课表
#define COURSE_DAY @"day"
#define COURSE_LOCALE @"locale"
#define COURSE_PERIOD @"period"
#define COURSE_SECTIONEND @"sectionend"
#define COURSE_SECTIONSTART @"sectionstart"
#define COURSE_SMARTPERIOD @"smartPeriod"
#define COURSE_TEACHER @"teacher"
#define COURSE_WHOCOURSE @"whoCourse"



//成绩
#define COURSE_CODE @"courseCode"
#define GRADE_CATEGORY @"category"
#define GRADE_CREDIT @"credit"
#define GRADE_MIDTERMGRADE @"midTermGrade"
#define GRADE_FINALLEVEL @"finalLevel"
#define GRADE_MAKEUPEXAMGRADE @"makeupExamGrade"
#define GRADE_FINALGRADE @"finalGrade"
#define GRADE_GRADEPOINT @"gradePoint"
#define GRADE_WHOGRADE @"whoGrade"

//用户
#define USER_NAME @"name"
#define USER_PASSWORD @"password"
#define USER_ID @"userId"

#endif /* Public_h */
