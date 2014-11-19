//
//  RACSignal+ReactiveCouchbaseLite.h
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 11/19/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <CouchbaseLite/CouchbaseLite.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RCLDefinitions.h"

/**
 Adds useful methods to RACSignal.
 */

@interface RACSignal (ReactiveCouchbaseLite)

/**
 For a signal returning CBLQuery objects, return a copy of the query with the changed 
 index update mode.
 
 @param mode The index update mode to use.
 @return A signal passing an updated query object.
 @discussion If the index update mode isn't different, the original object is returned.
 */

- (RACSignal *)rcl_updateQueryIndexUpdateMode:(CBLIndexUpdateMode)mode;

@end
