//
//  Exam+CoreDataProperties.h
//  
//
//  Created by lixu on 16/8/31.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Exam.h"

NS_ASSUME_NONNULL_BEGIN

@interface Exam (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *examDate;
@property (nullable, nonatomic, retain) NSString *examLocale;
@property (nullable, nonatomic, retain) NSString *examName;
@property (nullable, nonatomic, retain) NSString *examPlan;
@property (nullable, nonatomic, retain) NSString *semesterId;
@property (nullable, nonatomic, retain) NSString *examCategory;
@property (nullable, nonatomic, retain) User *whoExam;

@end

NS_ASSUME_NONNULL_END
