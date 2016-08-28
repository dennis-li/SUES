//
//  Networking.h
//  SUES
//password = 19940429;
//userId = 023113102;
//  Created by lixu on 16/8/23.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import <Foundation/Foundation.h>

#warning - 以后更新的数据类型可以增加
typedef NS_ENUM(NSUInteger, NetworkingType) {
    RefreshGrade = 1,
    RefreshCourse
};

@interface Networking : NSObject

@property (nonatomic,assign)NetworkingType type;

//回调信息
@property (nonatomic,copy) void (^requestFinish)(NSString *requestString,NSString *error);
@property (nonatomic,copy) void (^requestHtmlData)(NSData *coursesData,NSData *gradeData);

//登录请求
-(void)loginRequestWithUserName:(NSString *)userId password:(NSString *)userPassword;

//刷新数据
-(void)refreshHtmlDataWithNetworkingType:(NetworkingType)type;

@end
