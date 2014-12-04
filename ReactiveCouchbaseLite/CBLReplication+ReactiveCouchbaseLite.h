//
//  CBLReplication+ReactiveCouchbaseLite.h
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RCLDefinitions.h"

@interface CBLReplication (ReactiveCouchbaseLite)

/**
 Returns a dictionary of each transferred document's properties as it is transferred.
 
 @return A signal streaming transferred properties.
 */

- (RACSignal *)rcl_transferredDocuments;

@end
