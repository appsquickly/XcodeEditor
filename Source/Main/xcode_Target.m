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

@interface xcode_Target (Private)

- (SourceFile*) buildFileWithKey:(NSString*)key;

- (void) targetMembersAreDirty;

- (void) calculateTargetMembers;

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
        [self calculateTargetMembers];
    }
    NSSortDescriptor* sorter = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    return [_members sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
}

- (void) addMember:(xcode_SourceFile*)member {
    [member becomeBuildFile];
    NSDictionary* target = [[_project objects] objectForKey:_key];
    LogDebug(@"Here's the target: %@", target);
    for (NSString* buildPhaseKey in [target objectForKey:@"buildPhases"]) {
        NSMutableDictionary* buildPhase = [[_project objects] objectForKey:buildPhaseKey];
        if ([[buildPhase valueForKey:@"isa"] asMemberType] == PBXSourcesBuildPhase) {
            LogDebug(@"Here's the build phase: %@", buildPhase);
            NSMutableArray* files = [buildPhase objectForKey:@"files"];

            LogDebug(@"Adding key '%@' to PBXBuildPhase: %@", [member buildFileKey], buildPhaseKey);
            [files addObject:[member buildFileKey]];
            [buildPhase setObject:files forKey:@"files"];
        }
    }
    [self targetMembersAreDirty];
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

- (void) targetMembersAreDirty {
    _members = nil;
}

- (void) calculateTargetMembers {
    _members = [[NSMutableArray alloc] init];
    for (NSString* buildPhaseKey in [[[_project objects] objectForKey:_key] objectForKey:@"buildPhases"]) {
        NSDictionary* buildPhase = [[_project objects] objectForKey:buildPhaseKey];
        if ([[buildPhase valueForKey:@"isa"] asMemberType] == PBXSourcesBuildPhase) {
            for (NSString* buildFileKey in [buildPhase objectForKey:@"files"]) {
                SourceFile* targetMember = [self buildFileWithKey:buildFileKey];
                if (targetMember) {
                    [_members addObject:[self buildFileWithKey:buildFileKey]];
                }
            }
        }
    }
}


@end
