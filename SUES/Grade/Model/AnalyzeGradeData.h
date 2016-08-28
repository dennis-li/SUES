//
//  AnalyzeGradeData.h
//  SUES
//
//  Created by lixu on 16/8/28.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnalyzeGradeData : NSObject

//登录的时候下载成绩信息 
-(void)analyzeGradeHtmlData:(NSData *)htmlData userId:(NSString *)userId userPassword:(NSString *)userPassword;

//刷新成绩
-(void)analyzeGradeHtmlData:(NSData *)htmlData;
@end
