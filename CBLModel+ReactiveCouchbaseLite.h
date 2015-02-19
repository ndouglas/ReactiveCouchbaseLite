//
//  CBLModel+ReactiveCouchbaseLite.h
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 11/19/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RCLDefinitions.h"

@interface CBLModel (ReactiveCouchbaseLite)

/**
 Indicates when the model's properties were changed externally.

 @return A signal that sends references to this model object whenever it is updated externally.
 */

- (RACSignal *)rcl_didLoadFromDocument;

@end
