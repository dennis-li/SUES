//
//  BaseViewController.h
//  SohuByObject_C
//
//  Created by lixu on 16/4/8.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

-(void)addNavTitle:(NSString *)title;
-(UIButton *)addNavBtn:(NSString *)imageName target:(id)target action:(SEL)action isLeft:(BOOL)isLeft;
-(void)addBackBtn:(NSString *)imageName target:(id)target action:(SEL)action;
@end
