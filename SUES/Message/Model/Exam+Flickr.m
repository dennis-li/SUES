//
//  Exam+Flickr.m
//  SUES
//
//  Created by lixu on 16/8/30.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "Exam+Flickr.h"
#import "User+Create.h"
#import "Public.h"

@implementation Exam (Flickr)
+(Exam *)examWithFlickrInfo:(NSDictionary *)examDictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    Exam *exam = nil;
    User *user = [User searchUserWithId:examDictionary[GRADE_WHOGRADE] inManagedObjectContext:context];
    NSString *name = examDictionary[COURSE_ID];
    NSString *semesterID = examDictionary[EXAM_SEMESTERID];
    if (!examDictionary[COURSE_NAME]) {
        return nil;
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Exam"];
    request.predicate = [NSPredicate predicateWithFormat:@"examName = %@ AND whoGrade = %@ AND semesterId = %@",name,user,semesterID];
    
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || error || ([matches count] > 1)) {
        //handle error
    } else if ([matches count]){
        
    } else {
        //最后返回的可能是空数组
        exam = [NSEntityDescription insertNewObjectForEntityForName:@"Exam" inManagedObjectContext:context];
        exam.examName = name;
        exam.semesterId = semesterID;
        exam.whoExam = user;
        exam.examPlan = examDictionary[EXAM_PLAN];
        exam.examDate = examDictionary[EXAM_DATE];
        exam.examLocale = examDictionary[EXAM_LOCALE];
        exam.examCategory = examDictionary[EXAM_CATEGORY];
    }
    return exam;
}

//批量加载数据
+(void)loadExamFromFlickrArray:(NSArray *)examData intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *exam in examData) {
        [self examWithFlickrInfo:exam inManagedObjectContext:context];
    }
}
@end
