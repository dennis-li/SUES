//
//  Grade+CoreDataProperties.h
//  
//
//  Created by lixu on 16/8/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Grade.h"

NS_ASSUME_NONNULL_BEGIN

@interface Grade (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *courseId;
@property (nullable, nonatomic, retain) NSString *courseCode;//课程代码
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *category;
@property (nullable, nonatomic, retain) NSString *credit;
@property (nullable, nonatomic, retain) NSString *midTermGrade;
@property (nullable, nonatomic, retain) NSString *finalLevel;
@property (nullable, nonatomic, retain) NSString *makeupExamGrade;
@property (nullable, nonatomic, retain) NSString *finalGrade;
@property (nullable, nonatomic, retain) NSString *gradePoint;
@property (nullable, nonatomic, retain) NSNumber *startSchoolYear;
@property (nullable, nonatomic, retain) NSNumber *semester;
@property (nullable, nonatomic, retain) User *whoGrade;

@end

NS_ASSUME_NONNULL_END
