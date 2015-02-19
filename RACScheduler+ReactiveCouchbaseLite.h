//
//  RACScheduler+ReactiveCouchbaseLite.h
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 1/22/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RCLDefinitions.h"

@interface RACScheduler (ReactiveCouchbaseLite)

/**
 Schedules a block or runs it, if it is the current scheduler.
 
 @param _block A block to run or schedule for running.
 */

- (void)rcl_runOrScheduleBlock:(void (^)(void))_block;

@end
