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
#define COURSE_YEARANDSEMESTER @"yearAndSemester"
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

//考试
#define EXAM_DATE @"examDate"
#define EXAM_NAME @"examName"
#define EXAM_PLAN @"examPlan"
#define EXAM_LOCALE @"examLocale"
#define EXAM_CATEGORY @"examCategory"
#define EXAM_SEMESTERID @"examSemesterID"
#define EXAM_WHOEXAM @"whoExam"

//答疑
#define ANSWERQUESTION_DATE @"answerQuestionDate"
#define ANSWERQUESTION_LOCALE @"answerQuestionLocale"
#define ANSWERQUESTION_CREDIT @"answerQuestionCredit"
#define ANSWERQUESTION_SEMESTERID @"answerQuestionSemesterId"
#define ANSWERQUESTION_COURSE_CODE @"answerQuestionCourseCode"
#define ANSWERQUESTION_NAME @"answerQuestionName"
#define ANSWERQUESTION_TEACHER @"answerQuestionTeacher"
#define ANSWERQUESTION_TIME @"answerQuestionTime"
#define ANSWERQUESTION_WHO @"whoAnswerQuestion"

//用户
#define USER_NAME @"name"
#define USER_PASSWORD @"password"
#define USER_ID @"userId"

//课表URL
#define COURSE_GET_URL @"http://jxxt.sues.edu.cn/eams/courseTableForStd.action?method=stdHome"
#define SUES_URL @"http://jxxt.sues.edu.cn/eams/"

//成绩URL
#define GRADE_URL @"http://jxxt.sues.edu.cn/eams/personGrade.action?method=historyCourseGrade"

//考试
#define EXAM_URL @"http://jxxt.sues.edu.cn/eams/stdExamTable.action?method=examTable&semester.id=%@&examType.id=%ld"
//答疑
#define ANSWER_QUESTION_PLAN @"http://jxxt.sues.edu.cn/eams/stdQandA.action?method=showQandAForStd&semester.id=%@"

#define REQUEST_EXAM_DATA @"request exam data"

//登录表单补充数据
#define FORM_CAPATCHA  @""
#define FORM_GOTOONFILI  @"http://my.sues.edu.cn/loginFailure.portal"
#define FORM_SUCCESS  @"http://my.sues.edu.cn/loginSuccess.portal"

#endif /* Public_h */
