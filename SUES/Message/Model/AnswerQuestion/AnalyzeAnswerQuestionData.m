//
//  AnalyzeAnswerQuestionData.m
//  SUES
//
//  Created by lixu on 16/9/1.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "AnalyzeAnswerQuestionData.h"
#import "TFHpple.h"
#import "Public.h"
#import "AnswerQuestion+Flickr.h"
@implementation AnalyzeAnswerQuestionData
-(NSMutableArray *)createAnswerQuestionArray
{
    return [[NSMutableArray alloc] init];
}

//创建一个字典，存储考试详情
-(NSMutableDictionary *)createAnswerQuestionDictionary
{
    return [[NSMutableDictionary alloc] init];
}

//解析答疑安排
-(void)analyzeAnswerQuestionHtmlData:(NSData *)htmlData userId:(NSString *)userId semesterId:(NSString *)semesterId
{
    NSLog(@"start.answerQuestion");
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[@id='listTable']/tbody/tr/td"];
    NSMutableDictionary *answerQuestionDictionary = nil;
    NSMutableArray *answerQuestionArray = [self createAnswerQuestionArray];
    NSInteger key = 0;
    for (TFHppleElement *element in elements) {
        NSLog(@"element.content = %@",[element content]);
        if (!(key % 8)) {
            answerQuestionDictionary = [self createAnswerQuestionDictionary];
            [answerQuestionArray addObject:answerQuestionDictionary];
            [answerQuestionDictionary setValue:semesterId forKey:ANSWERQUESTION_SEMESTERID];//学期号
            [answerQuestionDictionary setValue:userId forKey:ANSWERQUESTION_WHO];//user
        }
        switch (key % 8) {
            case 1:
                [answerQuestionDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:ANSWERQUESTION_COURSE_CODE];
                break;
            case 2:
                [answerQuestionDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:ANSWERQUESTION_NAME];
                break;
            case 3:
                [answerQuestionDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:ANSWERQUESTION_CREDIT];
                break;
            case 4:
                [answerQuestionDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:ANSWERQUESTION_TEACHER];
                break;
            case 5:
                [answerQuestionDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:ANSWERQUESTION_DATE];
                break;
            case 6:
                [answerQuestionDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:ANSWERQUESTION_TIME];
                break;
            case 7:
                [answerQuestionDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:ANSWERQUESTION_LOCALE];
                break;
                
            default:
                break;
        }
        key++;
    }
    if ([answerQuestionArray count]) {
        [self.managedObjectContext performBlock:^{
            [AnswerQuestion loadAnswerQuestionFromFlickrArray:answerQuestionArray intoManagedObjectContext:self.managedObjectContext];
            [self.managedObjectContext save:NULL];
        }];
    }
}

/*
 <table class="listTable" id="listTable" sortable="true" width="100%">
 <tbody><tr align="center" class="darkColumn">   <td class="select"><input type="checkBox" id="qandAIdBox" class="box" onclick="toggleCheckBox(document.getElementsByName('qandAId'),event);"></td>
 <td width="6%">课程代码</td>
 <td width="15%">课程名称</td>
 <td width="8%">学分</td>
 <td width="8%">教师</td>
 <td width="8%">日期</td>
 <td width="10%">时间</td>
 <td width="10%">地点</td>
 </tr>
 </tbody><tbody>
 <tr class="brightStyle" align="center" onmouseover="swapOverTR(this,this.className)" onmouseout="swapOutTR(this)" onclick="onRowChange(event)">   <td class="select"><input class="box" name="qandAId" value="9808" type="checkbox"></td>
 <td>020218</td>
 <td>检测与转换技术</td>
 <td>3</td>
 <td>张莉萍</td>
 <td>2016-02-25</td>
 <td>09:30-11:00</td>
 <td>行政楼,905</td>
 </tr>
 <tr class="grayStyle" align="center" onmouseover="swapOverTR(this,this.className)" onmouseout="swapOutTR(this)" onclick="onRowChange(event)">   <td class="select"><input class="box" name="qandAId" value="9266" type="checkbox"></td>
 <td>020319</td>
 <td>单片机原理A</td>
 <td>2</td>
 <td>单鸿涛</td>
 <td>2016-01-29</td>
 <td>09:30-11:00</td>
 <td>行政楼,919</td>
 </tr>

 */
@end
