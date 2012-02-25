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
#import "XcodeProjectNodeType.h"
#import "XcodeProjectFileType.h"
#import "xcode_Group.h"
#import "xcode_FileWriteQueue.h"
#import "xcode_Target.h"
#import "xcode_FileResource.h"


@interface xcode_Project (private)

- (NSArray*) projectFilesOfType:(XcodeProjectFileType)fileReferenceType;

- (FileResource*) buildFileWithKey:(NSString*)key;

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

- (id) initWithString:(NSString*)string {
    return nil;
    //To change the template use AppCode | Preferences | File Templates.

}


/* ================================================ Interface Methods =============================================== */
- (NSMutableDictionary*) objects {
    return [_project objectForKey:@"objects"];
}

- (NSArray*) files {
    NSMutableArray* results = [[NSMutableArray alloc] init];
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
        if ([[obj valueForKey:@"isa"] asProjectNodeType] == PBXFileReference) {
            XcodeProjectFileType fileType = [[obj valueForKey:@"lastKnownFileType"] asProjectFileType];
            NSString* path = [obj valueForKey:@"path"];
            [results addObject:[[FileResource alloc] initWithProject:self key:key type:fileType path:path]];
        }
    }];
    NSSortDescriptor* sorter = [NSSortDescriptor sortDescriptorWithKey:@"path" ascending:YES];
    return [results sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
}

- (xcode_FileResource*) projectFileWithKey:(NSString*)key {
    NSDictionary* obj = [[self objects] valueForKey:key];
    if (obj) {
        XcodeProjectFileType fileType = [[obj valueForKey:@"lastKnownFileType"] asProjectFileType];
        NSString* path = [obj valueForKey:@"path"];
        return [[FileResource alloc] initWithProject:self key:key type:fileType path:path];
    }
    return nil;
}

- (xcode_FileResource*) projectFileWithPath:(NSString*)path {
    for (FileResource* projectFile in [self files]) {
        if ([[projectFile path] isEqualToString:path]) {
            return projectFile;
        }
    }
    return nil;
}


- (NSArray*) headerFiles {
    return [self projectFilesOfType:SourceCodeHeader];
}

- (NSArray*) implementationFiles {
    return [self projectFilesOfType:SourceCodeObjC];
}

- (NSArray*) groups {

    NSMutableArray* results = [[NSMutableArray alloc] init];
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {

        if ([[obj valueForKey:@"isa"] asProjectNodeType] == PBXGroup) {
            NSString* name = [obj valueForKey:@"name"];
            NSString* path = [obj valueForKey:@"path"];
            NSArray* children = [obj valueForKey:@"children"];

            Group* group = [[Group alloc] initWithProject:self key:key name:name path:path children:children];
            [results addObject:group];
        }
    }];

    return results;
}

- (NSArray*) targets {

    NSMutableArray* results = [[NSMutableArray alloc] init];
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {

        if ([[obj valueForKey:@"isa"] asProjectNodeType] == PBXNativeTarget) {

            NSMutableArray* buildFiles = [[NSMutableArray alloc] init];
            for (NSString* buildPhaseKey in [obj objectForKey:@"buildPhases"]) {
                NSDictionary* buildPhase = [[self objects] objectForKey:buildPhaseKey];
                if ([[buildPhase valueForKey:@"isa"] asProjectNodeType] == PBXSourcesBuildPhase) {
                    for (NSString* buildFileKey in [buildPhase objectForKey:@"files"]) {
                        FileResource* targetMember = [self buildFileWithKey:buildFileKey];
                        if (targetMember) {
                            [buildFiles addObject:[self buildFileWithKey:buildFileKey]];
                        }
                    }
                }
            }
            Target* target =
                [[Target alloc] initWithProject:self key:key name:[obj valueForKey:@"name"] members:buildFiles];
            [results addObject:target];
        }
    }];
    return results;
}

- (Target*) targetWithName:(NSString*)name {
    for (Target* target in [self targets]) {
        if ([[target name] isEqualToString:name]) {
            return target;
        }
    }
    return nil;
}


- (xcode_Group*) groupWithPath:(NSString*)path {
    for (Group* group in [self groups]) {
        if ([group.path isEqualToString:path]) {
            return group;
        }
    }
    return nil;
}


- (void) save {
    [_fileWriteQueue writePendingFilesToDisk];
    [_project writeToFile:[_filePath stringByAppendingPathComponent:@"project.pbxproj"] atomically:NO];
}

/* ================================================== Private Methods =============================================== */
- (NSArray*) projectFilesOfType:(XcodeProjectFileType)projectFileType {
    NSMutableArray* results = [[NSMutableArray alloc] init];
    for (FileResource* file in [self files]) {
        if ([file type] == projectFileType) {
            [results addObject:file];
        }
    }
    NSSortDescriptor* sorter = [NSSortDescriptor sortDescriptorWithKey:@"path" ascending:YES];
    return [results sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
}


- (FileResource*) buildFileWithKey:(NSString*)theKey {
    NSDictionary* obj = [[self objects] valueForKey:theKey];
    if (obj) {
        if ([[obj valueForKey:@"isa"] asProjectNodeType] == PBXBuildFile) {
            return [self projectFileWithKey:[obj valueForKey:@"fileRef"]];
        }
    }
    return nil;
}


@end