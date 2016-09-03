//
//  AnswerQuestion+Flickr.m
//  SUES
//
//  Created by lixu on 16/9/1.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "AnswerQuestion+Flickr.h"
#import "User+Create.h"
#import "Public.h"

@implementation AnswerQuestion (Flickr)
+(AnswerQuestion *)answerQuestionWithFlickrInfo:(NSDictionary *)answerQuestionDictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    AnswerQuestion *answerQuestion = nil;
    User *user = [User searchUserWithId:answerQuestionDictionary[ANSWERQUESTION_WHO] inManagedObjectContext:context];
    NSString *name = answerQuestionDictionary[ANSWERQUESTION_NAME];
    NSString *semesterID = answerQuestionDictionary[ANSWERQUESTION_SEMESTERID];
    if (!answerQuestionDictionary[ANSWERQUESTION_NAME]) {
        return nil;
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AnswerQuestion"];
    request.predicate = [NSPredicate predicateWithFormat:@"whoAnswerQuestion = %@ AND name = %@ AND semesterId = %@",user,name,semesterID];
    
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || error || ([matches count] > 1)) {
        //handle error
    } else if ([matches count]){
        answerQuestion = [matches firstObject];
    } else {
        //最后返回的可能是空数组
        answerQuestion = [NSEntityDescription insertNewObjectForEntityForName:@"AnswerQuestion" inManagedObjectContext:context];
        answerQuestion.name = name;
        answerQuestion.courseCode = answerQuestionDictionary[ANSWERQUESTION_COURSE_CODE];
        answerQuestion.credit = answerQuestionDictionary[ANSWERQUESTION_CREDIT];
        answerQuestion.date = answerQuestionDictionary[ANSWERQUESTION_DATE];
        answerQuestion.semesterId = semesterID;
        answerQuestion.teacher = answerQuestionDictionary[ANSWERQUESTION_TEACHER];
        answerQuestion.time = answerQuestionDictionary[ANSWERQUESTION_TIME];
        answerQuestion.locale = answerQuestionDictionary[ANSWERQUESTION_LOCALE];
        answerQuestion.whoAnswerQuestion = user;
    }
    NSLog(@"answerQuestion.name = %@",answerQuestion.name);
    return answerQuestion;
}

//批量加载数据
+(void)loadAnswerQuestionFromFlickrArray:(NSArray *)answerQuestionData intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *answerQuestion in answerQuestionData) {
        [self answerQuestionWithFlickrInfo:answerQuestion inManagedObjectContext:context];
    }
}
@end
