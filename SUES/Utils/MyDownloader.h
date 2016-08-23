//
//  MyDownloader.h
//  SohuByObject_C
//
//  Created by lixu on 16/4/25.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DownloadType) {
    All = 0,
    DownloadCourses,
    DownloadGrade
};

@class MyDownloader;
@protocol MyDownloaderDelegate <NSObject>

//下载失败
- (void)downloadFail:(MyDownloader *)downloader error:(NSError  *)error;

//下载成功
- (void)downloadFinish:(MyDownloader *)downloader;

@end

@interface MyDownloader : NSObject<NSURLConnectionDataDelegate>

//代理属性
@property (nonatomic,weak)id<MyDownloaderDelegate>delegate;
//类型
@property (nonatomic,strong)NSString *type;

//下载
-(void)downloadWithUrlString:(NSString *)urlString downloadType:(DownloadType)type
                    userId:(NSString *)userId userPassWord:(NSString *)userPassWord;
@end
