//
//  AnalyzeAnswerQuestionData.h
//  SUES
//
//  Created by lixu on 16/9/1.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface AnalyzeAnswerQuestionData : NSObject
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

//解析考试安排
-(void)analyzeAnswerQuestionHtmlData:(NSData *)htmlData userId:(NSString *)userId semesterId:(NSString *)semesterId;
@end
