////////////////////////////////////////////////////////////////////////////////
//
//  EXPANZ
//  Copyright 2008-2011 EXPANZ
//  All Rights Reserved.
//
//  NOTICE: Expanz permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

#import "xcode_Group.h"
#import "xcode_Project.h"
#import "xcode_ClassDefinition.h"
#import "XcodeProjectFileType.h"
#import "xcode_KeyBuilder.h"
#import "xcode_FileWriteQueue.h"
#import "xcode_FileResource.h"
#import "XcodeProjectNodeType.h"

@interface xcode_Group (private)

- (void) addChildWithKey:(NSString*)key;

- (NSDictionary*) makeFileReference:(NSString*)name type:(XcodeProjectFileType)type;

- (NSDictionary*) asDictionary;

@end

@implementation xcode_Group

@synthesize project = _project;
@synthesize name = _name;
@synthesize path = _path;
@synthesize key = _key;
@synthesize children = _children;


/* ================================================== Initializers ================================================== */
- (id) initWithProject:(xcode_Project*)project key:(NSString*)key name:(NSString*)name path:(NSString*)path
              children:(NSArray*)children {
    self = [super init];
    if (self) {
        _project = project;
        _key = [key copy];
        _name = [name copy];
        _path = [path copy];
        _children = [[NSMutableArray alloc] init];
        [_children addObjectsFromArray:children];
    }
    return self;
}

/* ================================================ Interface Methods =============================================== */
- (void) addClass:(ClassDefinition*)classDefinition {
    NSDictionary* header = [self makeFileReference:[classDefinition headerFileName] type:SourceCodeHeader];
    NSString* headerKey = [[KeyBuilder forItemNamed:[classDefinition headerFileName]] build];
    [[_project objects] setObject:header forKey:headerKey];

    NSDictionary* source = [self makeFileReference:[classDefinition sourceFileName] type:SourceCodeObjC];
    NSString* sourceKey = [[KeyBuilder forItemNamed:[classDefinition sourceFileName]] build];
    [[_project objects] setObject:source forKey:sourceKey];

    [self addChildWithKey:headerKey];
    [self addChildWithKey:sourceKey];

    [[_project objects] setObject:[self asDictionary] forKey:_key];

    [_project.fileWriteQueue
        queueFile:[classDefinition headerFileName] inDirectory:_path withContents:[classDefinition header]];
    [_project.fileWriteQueue
        queueFile:[classDefinition sourceFileName] inDirectory:_path withContents:[classDefinition source]];
}

/* ================================================== Utility Methods =============================================== */
- (NSString*) description {
    return [NSString stringWithFormat:@"Group: name = %@, key=%@, path=%@", _name, _key, _path];
}

/* ================================================== Private Methods =============================================== */
- (void) addChildWithKey:(NSString*)key {
    if (![_children containsObject:key]) {
        [_children addObject:key];
    }
}

- (NSDictionary*) makeFileReference:(NSString*)name type:(XcodeProjectFileType)type {
    NSMutableDictionary* reference = [[NSMutableDictionary alloc] init];
    [reference setObject:[NSString stringFromProjectNodeType:PBXFileReference] forKey:@"isa"];
    [reference setObject:@"4" forKey:@"FileEncoding"];
    [reference setObject:[NSString stringFromProjectFileType:type] forKey:@"lastKnownFileType"];
    [reference setObject:name forKey:@"path"];
    [reference setObject:@"<group>" forKey:@"sourceTree"];
    return reference;
}

- (NSDictionary*) asDictionary {
    NSMutableDictionary* groupData = [[NSMutableDictionary alloc] init];
    [groupData setObject:[NSString stringFromProjectNodeType:PBXGroup] forKey:@"isa"];
    [groupData setObject:@"<group>" forKey:@"sourceTree"];
    if (_name != nil) {
        [groupData setObject:_name forKey:@"name"];
    }
    [groupData setObject:_path forKey:@"path"];
    [groupData setObject:_children forKey:@"children"];
    return groupData;
}


@end