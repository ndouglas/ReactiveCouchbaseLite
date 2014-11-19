//
//  CBLManager+ReactiveCouchbaseLite.h
//  Sync
//
//  Created by Nathan Douglas on 11/19/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <CouchbaseLite/CouchbaseLite.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface CBLManager (ReactiveCouchbaseLite)

/**
 Returns a copy of the shared instance of CBLManager, suitable for using off the normal thread.
 
 @return A signal containing a copy of the shared instance of CBLManager.
 */

+ (RACSignal *)rcl_sharedInstance;

@end
