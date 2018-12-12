//
//  Manuals+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/25/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Manuals.h"

NS_ASSUME_NONNULL_BEGIN

@interface Manuals (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *downloadStatus;
@property (nullable, nonatomic, retain) NSString *filePath;
@property (nullable, nonatomic, retain) NSNumber *size;
@property (nullable, nonatomic, retain) NSString *statusMessage;
@property (nullable, nonatomic, retain) NSOrderedSet<ManualLinks *> *linkManual;

@end

@interface Manuals (CoreDataGeneratedAccessors)

- (void)insertObject:(ManualLinks *)value inLinkManualAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLinkManualAtIndex:(NSUInteger)idx;
- (void)insertLinkManual:(NSArray<ManualLinks *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLinkManualAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLinkManualAtIndex:(NSUInteger)idx withObject:(ManualLinks *)value;
- (void)replaceLinkManualAtIndexes:(NSIndexSet *)indexes withLinkManual:(NSArray<ManualLinks *> *)values;
- (void)addLinkManualObject:(ManualLinks *)value;
- (void)removeLinkManualObject:(ManualLinks *)value;
- (void)addLinkManual:(NSOrderedSet<ManualLinks *> *)values;
- (void)removeLinkManual:(NSOrderedSet<ManualLinks *> *)values;

@end

NS_ASSUME_NONNULL_END
