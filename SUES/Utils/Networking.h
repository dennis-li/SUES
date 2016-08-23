//
//  Networking.h
//  SUES
//
//  Created by lixu on 16/8/23.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MyDownloaderDelegate <NSObject>

//请求失败
- (void)requestFail:(NSError  *)error;

//请求成功
- (void)requestFinish;

@end

@interface Networking : NSObject

@property (nonatomic,weak)id<MyDownloaderDelegate>delegate;

@end
