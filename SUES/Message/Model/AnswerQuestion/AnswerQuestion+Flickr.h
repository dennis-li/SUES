//
//  AnswerQuestion+Flickr.h
//  SUES
//
//  Created by lixu on 16/9/1.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "AnswerQuestion.h"

@interface AnswerQuestion (Flickr)
//批量加载数据
+(void)loadAnswerQuestionFromFlickrArray:(NSArray *)answerQuestionData intoManagedObjectContext:(NSManagedObjectContext *)context;

+(AnswerQuestion *)answerQuestionWithFlickrInfo:(NSDictionary *)answerQuestionDictionary inManagedObjectContext:(NSManagedObjectContext *)context;
@end
