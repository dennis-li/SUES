//
//  AnalyzeExamData.m
//  SUES
//
//  Created by lixu on 16/8/31.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "AnalyzeExamData.h"
#import "TFHpple.h"
#import "Public.h"
#import "Exam+Flickr.h"

@interface AnalyzeExamData ()
@property (nonatomic, strong) dispatch_queue_t concurrentPhotoQueue;//自定义并发队列,解决读写者问题
@end
@implementation AnalyzeExamData

-(NSMutableArray *)createExamArray
{
    return [[NSMutableArray alloc] init];
}

//创建一个字典，存储考试详情
-(NSMutableDictionary *)createExamDictionary
{
    return [[NSMutableDictionary alloc] init];
}

//解析考试安排
-(void)analyzeExamHtmlData:(NSData *)htmlData userId:(NSString *)userId examType:(NSString *)type semesterId:(NSString *)semesterId
{
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[@id='listTable']/tr[position()>1]/td"];
    NSMutableDictionary *examDictionary = nil;
    NSMutableArray *examArray = [self createExamArray];
    NSInteger key = 0;
    for (TFHppleElement *element in elements) {
        NSLog(@"element.content = %@",[element content]);
        if (!(key % 4)) {
            examDictionary = [self createExamDictionary];
            [examArray addObject:examDictionary];
            [examDictionary setValue:type forKey:EXAM_CATEGORY];//考试类型
            [examDictionary setValue:semesterId forKey:EXAM_SEMESTERID];//学期号
            [examDictionary setValue:userId forKey:EXAM_WHOEXAM];
        }
        switch (key % 4) {
            case 0:
                [examDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:EXAM_NAME];//考试科目
                break;
            case 1:
                [examDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:EXAM_DATE];//考试时间
                break;
            case 2:
                [examDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:EXAM_PLAN];//考试安排
                break;
            case 3:
                [examDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:EXAM_LOCALE];//考试地点
                break;
                
            default:
                break;
        }
        key++;
    }
    if ([examArray count]) {
        [self.managedObjectContext performBlock:^{
            [Exam loadExamFromFlickrArray:examArray intoManagedObjectContext:self.managedObjectContext];
            [self.managedObjectContext save:NULL];
        }];
    }
}
/*
 <table width="100%" class="listTable" id="listTable">
 <tr align="center" class="darkColumn">
 <td width="15%">Course Name</td>
 <td width="10%">Examination Date</td>
 <td width="25%">Examination Arrange</td>
 <td width="8%">Examination Address</td>
 </tr>
 <tr class="brightStyle" align="center"
 onmouseover="swapOverTR(this,this.className)" onmouseout="swapOutTR(this)" >
 <td>电机及其拖动基础</td>
 <td>
 
 2016-09-08
 </td>
 <td>星期四  10:30</td>
 <td>F206多</td>
 </tr>
	</table>
	
	<tr>
 */

@end
