//
//  CBLModel+ReactiveCouchbaseLite.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 11/19/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "CBLModel+ReactiveCouchbaseLite.h"
#import "ReactiveCouchbaseLite.h"

@implementation CBLModel (ReactiveCouchbaseLite)

- (RACSignal *)rcl_didLoadFromDocument {
    return [[[self rac_signalForSelector:@selector(didLoadFromDocument)]
        mapReplace:self]
        setNameWithFormat:@"[%@ -rcl_didLoadFromDocument]", self];
}

@end
