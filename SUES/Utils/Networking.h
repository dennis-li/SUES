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

@class Networking;
@protocol NetworkingDelegate <NSObject>

//请求失败
- (void)requestFail:(Networking *)networking error:(NSString  *)error;

//请求成功
- (void)requestFinish:(Networking *)networking returnString:(NSString *)returnString;

@end

@interface Networking : NSObject

@property (nonatomic,weak)id<NetworkingDelegate>delegate;
@property (nonatomic,assign)NetworkingType type;

-(void)loginRequestWithUserName:(NSString *)userId password:(NSString *)userPassword;
-(void)requestGradeHtmlData;

@end
