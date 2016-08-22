//
//  UpdateUserView.h
//  SUES
//
//  Created by lixu on 16/8/20.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UpdateUserViewDelegate <NSObject>

-(void)signFinish:(NSString *)userName pass:(NSString *)password;

@end

@interface UpdateUserView : UIView
@property (nonatomic ,assign) id<UpdateUserViewDelegate>delegate;
@end
