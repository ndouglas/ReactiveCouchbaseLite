//
//  RACSignal+ReactiveCouchbaseLite.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/17/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RACSignal+ReactiveCouchbaseLite.h"
#import "CBLDatabase+ReactiveCouchbaseLite.h"

@implementation RACSignal (ReactiveCouchbaseLite)

#pragma mark - CBLDatabase

- (RACSignal *)rcl_cbldatabase_documentWithID:(NSString *)documentID {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_documentWithID:documentID];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_documentWithID: %@", result.name, documentID];
}

- (RACSignal *)rcl_cbldatabase_existingDocumentWithID:(NSString *)documentID {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_existingDocumentWithID:documentID];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_existingDocumentWithID: %@", result.name, documentID];
}

- (RACSignal *)rcl_cbldatabase_existingDocumentWithID:(NSString *)documentID defaultProperties:(NSDictionary *)defaultProperties {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_existingDocumentWithID:documentID defaultProperties:defaultProperties];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_existingDocumentWithID: %@ defaultProperties: %@", result.name, documentID, defaultProperties];
}

- (RACSignal *)rcl_cbldatabase_createDocument  {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_createDocument];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_createDocument", result.name];
}

- (RACSignal *)rcl_cbldatabase_existingLocalDocumentWithID:(NSString *)documentID {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_existingLocalDocumentWithID:documentID];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_existingLocalDocumentWithID: %@", result.name, documentID];
}

- (RACSignal *)rcl_cbldatabase_putLocalDocumentWithProperties:(NSDictionary *)properties ID:(NSString *)documentID {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_putLocalDocumentWithProperties:properties ID:documentID];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_putLocalDocumentWithProperties: %@ ID: %@", result.name, properties, documentID];
}

- (RACSignal *)rcl_cbldatabase_deleteLocalDocumentWithID:(NSString *)documentID {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_deleteLocalDocumentWithID:documentID];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_deleteLocalDocumentWithID: %@", result.name, documentID];
}

- (RACSignal *)rcl_cbldatabase_allDocumentsQuery {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_allDocumentsQuery];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_allDocumentsQuery", result.name];
}

- (RACSignal *)rcl_cbldatabase_allDocumentsQueryWithMode:(CBLAllDocsMode)mode {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_allDocumentsQueryWithMode:mode];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_allDocumentsQueryWithMode: %@", result.name, @(mode)];
}

- (RACSignal *)rcl_cbldatabase_allDocumentsQueryWithMode:(CBLAllDocsMode)mode indexUpdateMode:(CBLIndexUpdateMode)indexUpdateMode {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_allDocumentsQueryWithMode:mode indexUpdateMode:indexUpdateMode];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_allDocumentsQueryWithMode: %@ indexUpdateMode: %@", result.name, @(mode), @(indexUpdateMode)];
}

- (RACSignal *)rcl_cbldatabase_allIncludingDeletedDocumentsQuery {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_allIncludingDeletedDocumentsQuery];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_allIncludingDeletedDocumentsQuery", result.name];
}

- (RACSignal *)rcl_cbldatabase_viewNamed:(NSString *)name {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_viewNamed:name];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_viewNamed: %@", result.name, name];
}

- (RACSignal *)rcl_cbldatabase_existingViewNamed:(NSString *)name {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_existingViewNamed:name];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_existingViewNamed: %@", result.name, name];
}

- (RACSignal *)rcl_cbldatabase_viewNamed:(NSString *)name mapBlock:(CBLMapBlock)mapBlock version:(NSString *)version {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_viewNamed:name mapBlock:mapBlock version:version];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_viewNamed: %@ mapBlock: %@ version: %@", result.name, name, mapBlock, version];
}

- (RACSignal *)rcl_cbldatabase_viewNamed:(NSString *)name mapBlock:(CBLMapBlock)mapBlock reduceBlock:(CBLReduceBlock)reduceBlock version:(NSString *)version {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_viewNamed:name mapBlock:mapBlock reduceBlock:reduceBlock version:version];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_viewNamed: %@ mapBlock: %@ reduceBlock: %@ version: %@", result.name, name, mapBlock, reduceBlock, version];
}

- (RACSignal *)rcl_cbldatabase_setValidationNamed:(NSString *)name asBlock:(CBLValidationBlock)block {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_setValidationNamed:name asBlock:block];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_setValidationNamed: %@ asBlock: %@", result.name, name, block];
}

- (RACSignal *)rcl_cbldatabase_validationNamed:(NSString *)name {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_validationNamed:name];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_validationNamed: %@", result.name, name];
}

- (RACSignal *)rcl_cbldatabase_setFilterNamed:(NSString *)name asBlock:(CBLFilterBlock)block {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_setFilterNamed:name asBlock:block];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_setFilterNamed: %@ asBlock: %@", result.name, name, block];
}

- (RACSignal *)rcl_cbldatabase_filterNamed:(NSString *)name {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_filterNamed:name];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_filterNamed: %@", result.name, name];
}

- (RACSignal *)rcl_cbldatabase_inTransaction:(BOOL (^)(CBLDatabase *database))block {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_inTransaction:block];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_inTransaction: %@", result.name, block];
}

- (RACSignal *)rcl_cbldatabase_doAsync:(void (^)(void))block {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_doAsync:block];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_doAsync: %@", result.name, block];
}

- (RACSignal *)rcl_cbldatabase_allReplications {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_allReplications];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_allReplications", result.name];
}

- (RACSignal *)rcl_cbldatabase_createPushReplication:(NSURL *)URL {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_createPushReplication:URL];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_createPushReplication: %@", result.name, URL];
}

- (RACSignal *)rcl_cbldatabase_createPullReplication:(NSURL *)URL {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_createPullReplication:URL];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_createPullReplication: %@", result.name, URL];
}

- (RACSignal *)rcl_cbldatabase_databaseChangeNotifications {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_databaseChangeNotifications];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_databaseChangeNotifications", result.name];
}

- (RACSignal *)rcl_cbldatabase_deleteDocumentWithID:(NSString *)documentID {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_deleteDocumentWithID:documentID];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_deleteDocumentWithID: %@", result.name, documentID];
}

- (RACSignal *)rcl_cbldatabase_onDocumentWithID:(NSString *)documentID performBlock:(void (^)(CBLDocument *document))block {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_onDocumentWithID:documentID performBlock:block];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_onDocumentWithID: %@ performBlock: %@", result.name, documentID, block];
}

- (RACSignal *)rcl_cbldatabase_updateDocumentWithID:(NSString *)documentID block:(BOOL(^)(CBLUnsavedRevision *unsavedRevision))block {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_updateDocumentWithID:documentID block:block];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_updateDocumentWithID: %@ block: %@", result.name, documentID, block];
}

- (RACSignal *)rcl_cbldatabase_updateLocalDocumentWithID:(NSString *)documentID block:(NSDictionary *(^)(NSMutableDictionary *localDocument))block {
    RACSignal *result = [self
    flattenMap:^RACSignal *(CBLDatabase *database) {
        NSAssert([database isKindOfClass:[CBLDatabase class]], @"This method should only be called on signals of instances of CBLDatabase.");
        return [database rcl_updateLocalDocumentWithID:documentID block:block];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_cbldatabase_updateLocalDocumentWithID: %@ block: %@", result.name, documentID, block];
}

@end
