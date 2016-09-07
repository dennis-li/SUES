//
//  Networking.h
//  SUES
//password = 19940429;
//userId = 023113102;
//dq123456;
//021313106;
//19941211;
//021114126;
//  Created by lixu on 16/8/23.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import <Foundation/Foundation.h>

#warning - 以后更新的数据类型可以增加
typedef NS_ENUM(NSUInteger, NetworkingType) {
    RequestALlData,
    RefreshGrade = 1,
    RefreshCourse
};

@interface Networking : NSObject

@property (nonatomic,assign)NetworkingType type;

//回调信息
@property (nonatomic,copy) void (^requestFinish)(NSString *requestString,NSString *error);
@property (nonatomic,copy) void (^requestHtmlData)(NSData *gradeData,NSData *coursesData);

//登录请求
-(void)loginRequestWithUserName:(NSString *)userId password:(NSString *)userPassword;

//请求刷新数据(验证密码，学号，网络是否通过)
-(void)requestRefresh;

//请求个别页面数据(课表，成绩)
-(void)requestUserDataWithType:(NetworkingType)type;

@end
