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

#import "xcode_Target.h"
#import "xcode_SourceFile.h"
#import "xcode_Project.h"
#import "XcodeMemberType.h"

@interface xcode_Target (private)

- (SourceFile*) buildFileWithKey:(NSString*)key;

- (void) flagMembersAsDirty;

- (XcodeMemberType) buildPhaseFor:(SourceFile*)sourceFile;

@end


@implementation xcode_Target

@synthesize project = _project;
@synthesize key = _key;
@synthesize name = _name;


/* ================================================== Initializers ================================================== */
- (id) initWithProject:(xcode_Project*)project key:(NSString*)key name:(NSString*)name {
    self = [super init];
    if (self) {
        _project = project;
        _key = key;
        _name = [name copy];
    }
    return self;
}

/* ================================================ Interface Methods =============================================== */
- (NSArray*) members {
    if (_members == nil) {
        _members = [[NSMutableArray alloc] init];
        for (NSString* buildPhaseKey in [[[_project objects] objectForKey:_key] objectForKey:@"buildPhases"]) {
            NSDictionary* buildPhase = [[_project objects] objectForKey:buildPhaseKey];
            if ([[buildPhase valueForKey:@"isa"] asMemberType] == PBXSourcesBuildPhase ||
                    [[buildPhase valueForKey:@"isa"] asMemberType] == PBXFrameworksBuildPhase) {
                for (NSString* buildFileKey in [buildPhase objectForKey:@"files"]) {
                    SourceFile* targetMember = [self buildFileWithKey:buildFileKey];
                    if (targetMember) {
                        [_members addObject:[self buildFileWithKey:buildFileKey]];
                    }
                }
            }
        }
    }
    NSSortDescriptor* sorter = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    return [_members sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
}

- (void) addMember:(xcode_SourceFile*)member {
    LogDebug(@"$$$$$$$$$$$$$$$$$$$$$$$$ start adding member: %@", member);
    [member becomeBuildFile];
    NSDictionary* target = [[_project objects] objectForKey:_key];

    for (NSString* buildPhaseKey in [target objectForKey:@"buildPhases"]) {
        NSMutableDictionary* buildPhase = [[_project objects] objectForKey:buildPhaseKey];
        if ([[buildPhase valueForKey:@"isa"] asMemberType] == [self buildPhaseFor:member]) {

            NSMutableArray* files = [buildPhase objectForKey:@"files"];
            if (![files containsObject:[member buildFileKey]]) {
                [files addObject:[member buildFileKey]];
            }
            else {
                LogInfo(@"***WARNING*** Target %@ already includes %@", [self name], [member name]);
            }

            [buildPhase setObject:files forKey:@"files"];
        }
    }
    [self flagMembersAsDirty];
}

/* ================================================== Utility Methods =============================================== */
- (NSString*) description {
    return [NSString stringWithFormat:@"Target: name=%@, files=%@", _name, _members];
}

/* ================================================== Private Methods =============================================== */
- (SourceFile*) buildFileWithKey:(NSString*)theKey {
    NSDictionary* obj = [[_project objects] valueForKey:theKey];
    if (obj) {
        if ([[obj valueForKey:@"isa"] asMemberType] == PBXBuildFile) {
            return [_project fileWithKey:[obj valueForKey:@"fileRef"]];
        }
    }
    return nil;
}

- (void) flagMembersAsDirty {
    _members = nil;
}


- (XcodeMemberType) buildPhaseFor:(SourceFile*)sourceFile {
    if (sourceFile.type == SourceCodeObjC || sourceFile.type == SourceCodeObjCPlusPlus || sourceFile.type == XibFile) {
        return PBXSourcesBuildPhase;
    }
    else if (sourceFile.type == Framework) {
        return PBXFrameworksBuildPhase;
    }
    else {
        NSString* type = [NSString stringFromSourceFileType:[sourceFile type]];
        [NSException raise:NSInternalInconsistencyException format:@"Type %@ cannot be added to a target.", type];
    }
    return 0;
}

@end
