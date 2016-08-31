//
//  AnalyzeExamData.h
//  SUES
//
//  Created by lixu on 16/8/31.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface AnalyzeExamData : NSObject

@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

//解析考试安排
-(void)analyzeExamHtmlData:(NSData *)htmlData userId:(NSString *)userId examType:(NSString *)type semesterId:(NSString *)semesterId;
@end
