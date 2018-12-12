//
//  NoticeHead+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/25/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NoticeHead.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoticeHead (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *noticeHeading;
@property (nullable, nonatomic, retain) NSNumber *orderId;
@property (nullable, nonatomic, retain) NSSet<Cabin *> *headCabin;
@property (nullable, nonatomic, retain) NSOrderedSet<Notice *> *headNotice;

@end

@interface NoticeHead (CoreDataGeneratedAccessors)

- (void)addHeadCabinObject:(Cabin *)value;
- (void)removeHeadCabinObject:(Cabin *)value;
- (void)addHeadCabin:(NSSet<Cabin *> *)values;
- (void)removeHeadCabin:(NSSet<Cabin *> *)values;

- (void)insertObject:(Notice *)value inHeadNoticeAtIndex:(NSUInteger)idx;
- (void)removeObjectFromHeadNoticeAtIndex:(NSUInteger)idx;
- (void)insertHeadNotice:(NSArray<Notice *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeHeadNoticeAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInHeadNoticeAtIndex:(NSUInteger)idx withObject:(Notice *)value;
- (void)replaceHeadNoticeAtIndexes:(NSIndexSet *)indexes withHeadNotice:(NSArray<Notice *> *)values;
- (void)addHeadNoticeObject:(Notice *)value;
- (void)removeHeadNoticeObject:(Notice *)value;
- (void)addHeadNotice:(NSOrderedSet<Notice *> *)values;
- (void)removeHeadNotice:(NSOrderedSet<Notice *> *)values;

@end

NS_ASSUME_NONNULL_END
