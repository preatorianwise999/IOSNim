//
//  LTDeleteOlderFlight.h
//  LATAM
//
//  Created by Palash on 08/05/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AllDb.h"

enum deleteType{
    bydate=0,
    byflight,
    byuser
};
@interface LTDeleteOlderFlight : NSObject{
     NSManagedObjectContext *managedObjectContext;
}
-(void)deleteFlightForType:(enum deleteType)type FlightsArray:(NSArray*)flightArr;
-(void)deleteFromLegForFlight:(FlightRoaster*)flight;
-(void)deleteLegFromFlight:(Legs*)leg;
@end
