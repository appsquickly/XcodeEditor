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
#import "xcode_FileResource.h"
#import "xcode_Project.h"
#import "XcodeProjectNodeType.h"

@implementation xcode_Target

@synthesize project = _project;
@synthesize key = _key;
@synthesize name = _name;
@synthesize members = _members;

/* ================================================== Initializers ================================================== */
- (id) initWithProject:(xcode_Project*)project key:(NSString*)key name:(NSString*)name members:(NSArray*)members {
    self = [super init];
    if (self) {
        _project = project;
        _key = key;
        _name = [name copy];
        _members = [NSArray arrayWithArray:members];
    }
    return self;
}

/* ================================================ Interface Methods =============================================== */
- (void) addMember:(xcode_FileResource*)member {
    LogDebug(@"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
    [member becomeBuildFile];
    NSDictionary* target = [[_project objects] objectForKey:_key];
    LogDebug(@"Here's the target: %@", target);
    for (NSString* buildPhaseKey in [target objectForKey:@"buildPhases"]) {
        NSMutableDictionary* buildPhase = [[_project objects] objectForKey:buildPhaseKey];
        if ([[buildPhase valueForKey:@"isa"] asProjectNodeType] == PBXSourcesBuildPhase) {
            LogDebug(@"Here's the build phase: %@", buildPhase);
            NSMutableArray* files = [buildPhase objectForKey:@"files"];
            //LogDebug(@"Files: %@", files);

            LogDebug(@"Adding key '%@' to PBXBuildPhase: %@", [member buildFileKey], buildPhaseKey);
            [files addObject:[member buildFileKey]];
            [buildPhase setObject:files forKey:@"files"];
        }
    }
}


/* ================================================== Utility Methods =============================================== */
- (NSString*) description {
    return [NSString stringWithFormat:@"Target: name=%@, files=%@", _name, _members];
}

@end
