//
//  CourseDetailViewController.m
//  gcdqn
//
//  Created by lixu on 16/8/2.
//  Copyright © 2016年 hardtosaygoodbye. All rights reserved.
//

#import "CourseDetailViewController.h"

@interface CourseDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *courseNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseClassroomLabel;
@property (weak, nonatomic) IBOutlet UILabel *teacherNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseTimeLabel;

@end

@implementation CourseDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter]
     addObserverForName:@"WeekViewToCourseDVC"
     object:nil
     queue:nil
     usingBlock:^(NSNotification * _Nonnull note) {
        self.model = (TimetableModel *)note.userInfo[@"model"];
         NSLog(@"model = %@",self.model);
        self.courseNameLabel.text = self.model.name;
        self.courseNameLabel.numberOfLines = 0;
        self.courseClassroomLabel.text = self.model.locale;
        self.teacherNameLabel.text = self.model.teacher;
        
        //换算出周几上课
        NSString *courseTime = [NSString stringWithFormat:@"周%@%d-%d节",[self switchWeekDay:self.model.day],[self.model.sectionstart intValue],[self.model.sectionend intValue]];
        self.courseTimeLabel.text = courseTime;
    }];
    
//    [self configCourseMessage];
    
}

-(void)configCourseMessage:(NSNotification *)sender
{
    self.model = (TimetableModel *)sender.object;
    self.courseNameLabel.text = self.model.name;
    self.courseNameLabel.numberOfLines = 0;
    self.courseClassroomLabel.text = self.model.locale;
    self.teacherNameLabel.text = self.model.teacher;
    
    //换算出周几上课
    NSString *courseTime = [NSString stringWithFormat:@"周%@%d-%d节",[self switchWeekDay:self.model.day],[self.model.sectionstart intValue],[self.model.sectionend intValue]];
    self.courseTimeLabel.text = courseTime;
}

-(NSString *)switchWeekDay:(NSNumber *)day
{
    switch ([day intValue]) {
        case 1:
            return @"一";
        case 2:
            return @"二";
        case 3:
            return @"三";
        case 4:
            return @"四";
        case 5:
            return @"五";
        case 6:
            return @"六";
        case 7:
            return @"日";
    }
    return @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    CATransition *transition = [CATransition animation];
    [transition setDuration:0.5f];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    [self.tabBarController.view.layer addAnimation:transition forKey:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
