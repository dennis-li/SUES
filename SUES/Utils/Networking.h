//
//  Networking.h
//  SUES
//
//  Created by lixu on 16/8/23.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import <Foundation/Foundation.h>

#warning - 以后更新的数据类型可以增加
typedef NS_ENUM(NSUInteger, NetworkingType) {
    RefreshGrade = 0,
    RefreshCourse
};

@interface Networking : NSObject

@property (nonatomic,assign)NetworkingType type;

//回调信息
@property (nonatomic,copy) void (^requestFinish)(NSString *requestString,NSString *error);

//登录请求
-(void)loginRequestWithUserName:(NSString *)userId password:(NSString *)userPassword;

//课表请求
-(void)requestGradeHtmlData;

@end
