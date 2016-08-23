//
//  Networking.h
//  SUES
//
//  Created by lixu on 16/8/23.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetworkingDelegate <NSObject>

//请求失败
- (void)requestFail:(NSString  *)error;

//请求成功
- (void)requestFinish:(NSString *)returnString;

@end

@interface Networking : NSObject

@property (nonatomic,weak)id<NetworkingDelegate>delegate;
-(void)loginRequestWithUserName:(NSString *)username password:(NSString *)password;

@end
