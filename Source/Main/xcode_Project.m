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


#import "xcode_Project.h"
#import "XcodeSourceFileType.h"
#import "xcode_Group.h"
#import "xcode_FileWriteQueue.h"
#import "xcode_Target.h"
#import "xcode_SourceFile.h"


@interface xcode_Project (private)

- (NSArray*) projectFilesOfType:(XcodeSourceFileType)fileReferenceType;

@end


@implementation xcode_Project


@synthesize fileWriteQueue = _fileWriteQueue;

/* ================================================== Initializers ================================================== */
- (id) initWithFilePath:(NSString*)filePath {
    if (self) {
        _filePath = [filePath copy];
        _project = [[NSMutableDictionary alloc]
                initWithContentsOfFile:[_filePath stringByAppendingPathComponent:@"project.pbxproj"]];
        if (!_project) {
            [NSException raise:NSInvalidArgumentException format:@"Project file not found at file path %@", _filePath];
        }
        _fileWriteQueue = [[FileWriteQueue alloc] initWithBaseDirectory:[_filePath stringByDeletingLastPathComponent]];
    }
    return self;
}


/* ================================================ Interface Methods =============================================== */
#pragma mark Files

- (NSArray*) files {
    NSMutableArray* results = [[NSMutableArray alloc] init];
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
        if ([[obj valueForKey:@"isa"] asMemberType] == PBXFileReference) {
            XcodeSourceFileType fileType = [[obj valueForKey:@"lastKnownFileType"] asSourceFileType];
            NSString* path = [obj valueForKey:@"path"];
            [results addObject:[[SourceFile alloc] initWithProject:self key:key type:fileType name:path]];
        }
    }];
    NSSortDescriptor* sorter = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    return [results sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
}

- (xcode_SourceFile*) fileWithKey:(NSString*)key {
    NSDictionary* obj = [[self objects] valueForKey:key];
    if (obj && [[obj valueForKey:@"isa"] asMemberType] == PBXFileReference) {
        XcodeSourceFileType fileType = [[obj valueForKey:@"lastKnownFileType"] asSourceFileType];

        NSString* name = [obj valueForKey:@"name"];
        if (name == nil) {
            name = [obj valueForKey:@"path"];
        }
        return [[SourceFile alloc] initWithProject:self key:key type:fileType name:name];
    }
    return nil;
}

- (xcode_SourceFile*) fileWithName:(NSString*)name {
    for (SourceFile* projectFile in [self files]) {
        if ([[projectFile name] isEqualToString:name]) {
            return projectFile;
        }
    }
    return nil;
}


- (NSArray*) headerFiles {
    return [self projectFilesOfType:SourceCodeHeader];
}

- (NSArray*) objectiveCFiles {
    return [self projectFilesOfType:SourceCodeObjC];
}

- (NSArray*) objectiveCPlusPlusFiles {
    return [self projectFilesOfType:SourceCodeObjCPlusPlus];
}


- (NSArray*) xibFiles {
    return [self projectFilesOfType:XibFile];

}


/* ================================================================================================================== */
#pragma mark Groups

- (NSArray*) groups {

    NSMutableArray* results = [[NSMutableArray alloc] init];
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {

        if ([[obj valueForKey:@"isa"] asMemberType] == PBXGroup) {
            [results addObject:[self groupWithKey:key]];
        }
    }];

    return results;
}

- (Group*) groupWithKey:(NSString*)key {
    NSDictionary* obj = [[self objects] valueForKey:key];
    if (obj && [[obj valueForKey:@"isa"] asMemberType] == PBXGroup) {

        NSString* name = [obj valueForKey:@"name"];
        NSString* path = [obj valueForKey:@"path"];
        NSArray* children = [obj valueForKey:@"children"];

        return [[Group alloc] initWithProject:self key:key alias:name path:path children:children];
    }
    return nil;
}

- (xcode_Group*) groupForGroupMemberWithKey:(NSString*)key {
    for (Group* group in [self groups]) {
        if ([group memberWithKey:key]) {
            return group;
        }
    }
    return nil;
}


/* ================================================================================================================== */
#pragma mark Targets

- (NSArray*) targets {
    if (_targets == nil) {
        _targets = [[NSMutableArray alloc] init];
        [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
            if ([[obj valueForKey:@"isa"] asMemberType] == PBXNativeTarget) {
                Target* target = [[Target alloc] initWithProject:self key:key name:[obj valueForKey:@"name"]];
                [_targets addObject:target];
            }
        }];
    }
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    return [_targets sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (Target*) targetWithName:(NSString*)name {
    for (Target* target in [self targets]) {
        if ([[target name] isEqualToString:name]) {
            return target;
        }
    }
    return nil;
}


- (xcode_Group*) groupWithPathRelativeToParent:(NSString*)path {
    for (Group* group in [self groups]) {
        if ([group.pathRelativeToParent isEqualToString:path]) {
            return group;
        }
    }
    return nil;
}


- (void) save {
    [_fileWriteQueue writePendingFilesToDisk];
    [_project writeToFile:[_filePath stringByAppendingPathComponent:@"project.pbxproj"] atomically:NO];
}

- (NSMutableDictionary*) objects {
    return [_project objectForKey:@"objects"];
}

/* ================================================== Private Methods =============================================== */
#pragma mark Private

- (NSArray*) projectFilesOfType:(XcodeSourceFileType)projectFileType {
    NSMutableArray* results = [[NSMutableArray alloc] init];
    for (SourceFile* file in [self files]) {
        if ([file type] == projectFileType) {
            [results addObject:file];
        }
    }
    NSSortDescriptor* sorter = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    return [results sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
}


@end