//
//  Contents+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/25/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Contents.h"

NS_ASSUME_NONNULL_BEGIN

@interface Contents (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *image;
@property (nullable, nonatomic, retain) NSNumber *isOther;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *selectedValue;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSOrderedSet<FeildValues *> *contentField;
@property (nullable, nonatomic, retain) NSOrderedSet<OtherValues *> *contentOther;

@end

@interface Contents (CoreDataGeneratedAccessors)

- (void)insertObject:(FeildValues *)value inContentFieldAtIndex:(NSUInteger)idx;
- (void)removeObjectFromContentFieldAtIndex:(NSUInteger)idx;
- (void)insertContentField:(NSArray<FeildValues *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeContentFieldAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInContentFieldAtIndex:(NSUInteger)idx withObject:(FeildValues *)value;
- (void)replaceContentFieldAtIndexes:(NSIndexSet *)indexes withContentField:(NSArray<FeildValues *> *)values;
- (void)addContentFieldObject:(FeildValues *)value;
- (void)removeContentFieldObject:(FeildValues *)value;
- (void)addContentField:(NSOrderedSet<FeildValues *> *)values;
- (void)removeContentField:(NSOrderedSet<FeildValues *> *)values;

- (void)insertObject:(OtherValues *)value inContentOtherAtIndex:(NSUInteger)idx;
- (void)removeObjectFromContentOtherAtIndex:(NSUInteger)idx;
- (void)insertContentOther:(NSArray<OtherValues *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeContentOtherAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInContentOtherAtIndex:(NSUInteger)idx withObject:(OtherValues *)value;
- (void)replaceContentOtherAtIndexes:(NSIndexSet *)indexes withContentOther:(NSArray<OtherValues *> *)values;
- (void)addContentOtherObject:(OtherValues *)value;
- (void)removeContentOtherObject:(OtherValues *)value;
- (void)addContentOther:(NSOrderedSet<OtherValues *> *)values;
- (void)removeContentOther:(NSOrderedSet<OtherValues *> *)values;

@end

NS_ASSUME_NONNULL_END
