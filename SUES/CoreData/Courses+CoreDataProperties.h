//
//  Courses+CoreDataProperties.h
//  
//
//  Created by lixu on 16/8/17.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Courses.h"

NS_ASSUME_NONNULL_BEGIN

@interface Courses (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *period;
@property (nullable, nonatomic, retain) NSString *locale;
@property (nullable, nonatomic, retain) NSString *teacher;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *smartPeriod;
@property (nullable, nonatomic, retain) NSNumber *day;
@property (nullable, nonatomic, retain) NSNumber *sectionstart;
@property (nullable, nonatomic, retain) NSNumber *sectionend;
@property (nullable, nonatomic, retain) NSNumber *startSchoolYear;
@property (nullable, nonatomic, retain) NSNumber *semester;
@property (nullable, nonatomic, retain) NSString *courseId;
@property (nullable, nonatomic, retain) User *whoCourse;

@end

NS_ASSUME_NONNULL_END
