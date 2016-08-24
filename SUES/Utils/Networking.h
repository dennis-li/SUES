//
//  Networking.h
//  SUES
//
//  Created by lixu on 16/8/23.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Networking;
@protocol NetworkingDelegate <NSObject>

//请求失败
- (void)requestFail:(Networking *)networking error:(NSString  *)error;

//请求成功
- (void)requestFinish:(Networking *)networking returnString:(NSString *)returnString;

@end

@interface Networking : NSObject

@property (nonatomic,weak)id<NetworkingDelegate>delegate;
@property (nonatomic,strong)NSString *type;

-(void)loginRequestWithUserName:(NSString *)username password:(NSString *)password;
-(void)requestGradeHtmlData;

@end
