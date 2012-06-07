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

#import "xcode_FrameworkDefinition.h"
#import "xcode_Target.h"
#import "xcode_FileOperationQueue.h"
#import "xcode_XibDefinition.h"
#import "xcode_SourceFile.h"
#import "xcode_Group.h"
#import "xcode_Project.h"
#import "xcode_ClassDefinition.h"
#import "xcode_utils_KeyBuilder.h"
#import "xcode_SourceFileDefinition.h"
#import "xcode_XcodeprojDefinition.h"

#import "Logging.h"
/* ================================================================================================================== */
@interface xcode_Group ()

- (void) makeGroupMemberWithName:(NSString*)name contents:(id)contents type:(XcodeSourceFileType)type
        fileOperationStyle:(XcodeFileOperationStyle)fileOperationStyle;

- (void) makeGroupMemberWithName:(NSString*)name path:(NSString*)path type:(XcodeSourceFileType)type
              fileOperationStyle:(XcodeFileOperationStyle)fileOperationStyle;

- (NSString*) makeProductsGroup:(XcodeprojDefinition*) xcodeprojDefinition;

- (void) addProductsGroupToProject:(XcodeprojDefinition*) xcodeprojDefinition;

- (void) addMemberWithKey:(NSString*)key;

- (void) flagMembersAsDirty;

- (NSDictionary*) makeFileReferenceWithPath:(NSString*)path name:(NSString*)name type:(XcodeSourceFileType)type;

- (NSDictionary*) asDictionary;

- (XcodeMemberType) typeForKey:(NSString*)key;

- (void) addSourceFile:(SourceFile*)sourceFile toTargets:(NSArray*)targets;

@end
/* ================================================================================================================== */

@implementation xcode_Group

@synthesize pathRelativeToParent = _pathRelativeToParent;
@synthesize key = _key;
@synthesize children = _children;
@synthesize alias = _alias;



/* ================================================= Class Methods ================================================== */
+ (Group*) groupWithProject:(xcode_Project*)project key:(NSString*)key alias:(NSString*)alias path:(NSString*)path
        children:(NSArray*)children {

    return [[Group alloc] initWithProject:project key:key alias:alias path:path children:children];
}

/* ================================================== Initializers ================================================== */
- (id) initWithProject:(xcode_Project*)project key:(NSString*)key alias:(NSString*)alias path:(NSString*)path
        children:(NSArray*)children {
    self = [super init];
    if (self) {
        _project = project;
        _fileOperationQueue = [_project fileOperationQueue];
        _key = [key copy];
        _alias = [alias copy];
        _pathRelativeToParent = [path copy];

        _children = [[NSMutableArray alloc] init];
        [_children addObjectsFromArray:children];
    }
    return self;
}

/* ================================================ Interface Methods =============================================== */
#pragma mark Parent group

- (void) removeFromParentGroup {
    [self removeFromParentGroup:NO];
}


- (void) removeFromParentGroup:(BOOL)deleteChildren {
    LogDebug(@"Removing group %@", [self pathRelativeToProjectRoot]);
    if (deleteChildren) {
        LogDebug(@"Deleting children");
        for (id<XcodeGroupMember> groupMember in [self members]) {
            if ([groupMember groupMemberType] == PBXGroup) {
                Group* group = (Group*) groupMember;
                [group removeFromParentGroup:YES];
                LogDebug(@"My full path is : %@", [group pathRelativeToProjectRoot]);

            }
            else {
                [_fileOperationQueue queueDeletion:[groupMember pathRelativeToProjectRoot]];
            }
        }
    }
    [[_project objects] removeObjectForKey:_key];
    for (Target* target in [_project targets]) {
        [target removeMembersWithKeys:[self recursiveMembers]];
    }
}

- (xcode_Group*) parentGroup {
    return [_project groupForGroupMemberWithKey:_key];
}

- (BOOL) isRootGroup {
    return [self pathRelativeToParent] == nil && [self displayName] == nil;
}


/* ================================================================================================================== */
#pragma mark Adding children


- (void) addClass:(ClassDefinition*)classDefinition {


    [self makeGroupMemberWithName:[classDefinition headerFileName] contents:[classDefinition header]
            type:SourceCodeHeader fileOperationStyle:[classDefinition fileOperationStyle]];

    if ([classDefinition isObjectiveC]) {
        [self makeGroupMemberWithName:[classDefinition sourceFileName] contents:[classDefinition source]
                type:SourceCodeObjC fileOperationStyle:[classDefinition fileOperationStyle]];
    }
    else if ([classDefinition isObjectiveCPlusPlus]) {
        [self makeGroupMemberWithName:[classDefinition sourceFileName] contents:[classDefinition source]
                type:SourceCodeObjCPlusPlus fileOperationStyle:[classDefinition fileOperationStyle]];
    }

    [[_project objects] setObject:[self asDictionary] forKey:_key];
}


- (void) addClass:(ClassDefinition*)classDefinition toTargets:(NSArray*)targets {
    [self addClass:classDefinition];
    SourceFile* sourceFile = [_project fileWithName:[classDefinition sourceFileName]];
    [self addSourceFile:sourceFile toTargets:targets];
}

- (void) addFramework:(FrameworkDefinition*)frameworkDefinition {
    if (([self memberWithDisplayName:[frameworkDefinition name]]) == nil) {
        LogDebug(@"Here we go!!!!");
        NSDictionary* fileReference;
        if ([frameworkDefinition copyToDestination]) {
            LogDebug(@"Making file reference");
            fileReference = [self makeFileReferenceWithPath:[frameworkDefinition name] name:nil type:Framework];
            BOOL copyFramework = NO;
            if ([frameworkDefinition fileOperationStyle] == FileOperationStyleOverwrite) {
                copyFramework = YES;
            }
            else if ([frameworkDefinition fileOperationStyle] == FileOperationStyleAcceptExisting) {
                NSString* frameworkName = [[frameworkDefinition filePath] lastPathComponent];
                if (![_fileOperationQueue
                        fileWithName:frameworkName existsInProjectDirectory:[self pathRelativeToProjectRoot]]) {
                    copyFramework = YES;
                }

            }
            if (copyFramework) {
                [_fileOperationQueue queueFrameworkWithFilePath:[frameworkDefinition filePath]
                        inDirectory:[self pathRelativeToProjectRoot]];
            }
        }
        else {
            NSString* path = [frameworkDefinition filePath];
            NSString* name = [frameworkDefinition name];
            fileReference = [self makeFileReferenceWithPath:path name:name type:Framework];
        }
        LogDebug(@"Make framework key");
        NSString* frameworkKey = [[KeyBuilder forItemNamed:[frameworkDefinition name]] build];
        [[_project objects] setObject:fileReference forKey:frameworkKey];
        [self addMemberWithKey:frameworkKey];
    }
    [[_project objects] setObject:[self asDictionary] forKey:_key];
}


- (void) addFramework:(FrameworkDefinition*)frameworkDefinition toTargets:(NSArray*)targets {
    [self addFramework:frameworkDefinition];
    SourceFile* frameworkSourceRef = (SourceFile*) [self memberWithDisplayName:[frameworkDefinition name]];
    [self addSourceFile:frameworkSourceRef toTargets:targets];
}

- (xcode_Group*) addGroupWithPath:(NSString*)path {
    NSString* groupKey = [[KeyBuilder forItemNamed:path] build];

    NSArray* members = [self members];
    for (id<XcodeGroupMember> groupMember in members) {
        if ([groupMember groupMemberType] == PBXGroup) {

            if ([[[groupMember pathRelativeToProjectRoot] lastPathComponent] isEqualToString:path] ||
                    [[groupMember displayName] isEqualToString:path] || [[groupMember key] isEqualToString:groupKey]) {
                return nil;
            }
        }
    }

    Group* group = [[Group alloc] initWithProject:_project key:groupKey alias:nil path:path children:nil];
    NSDictionary* groupDict = [group asDictionary];

    [[_project objects] setObject:groupDict forKey:groupKey];
    [_fileOperationQueue queueDirectory:path inDirectory:[self pathRelativeToProjectRoot]];
    [self addMemberWithKey:groupKey];

    NSDictionary* dict = [self asDictionary];
    [[_project objects] setObject:dict forKey:_key];

    return group;
}

- (void) addSourceFile:(SourceFileDefinition*)sourceFileDefinition {
    [self makeGroupMemberWithName:[sourceFileDefinition sourceFileName] contents:[sourceFileDefinition data]
            type:[sourceFileDefinition type] fileOperationStyle:[sourceFileDefinition fileOperationStyle]];
    [[_project objects] setObject:[self asDictionary] forKey:_key];
}

- (void) addXib:(XibDefinition*)xibDefinition {
    [self makeGroupMemberWithName:[xibDefinition xibFileName] contents:[xibDefinition content] type:XibFile
            fileOperationStyle:[xibDefinition fileOperationStyle]];
    [[_project objects] setObject:[self asDictionary] forKey:_key];
}

- (void) addXib:(XibDefinition*)xibDefinition toTargets:(NSArray*)targets {
    [self addXib:xibDefinition];
    SourceFile* sourceFile = [_project fileWithName:[xibDefinition xibFileName]];
    [self addSourceFile:sourceFile toTargets:targets];
}

- (BOOL) addXcodeproj:(XcodeprojDefinition*)xcodeprojDefinition {
    // set xcodeproj's path relative to the project root
    xcodeprojDefinition.pathRelativeToProjectRoot = [_project makePathRelativeToProjectRoot:[xcodeprojDefinition xcodeprojFullPathName]];
    
    // create PBXFileReference for xcodeproj file and add to PBXGroup for the current group
    [self makeGroupMemberWithName:[xcodeprojDefinition xcodeprojFileName] path:[xcodeprojDefinition pathRelativeToProjectRoot] type:XcodeProject fileOperationStyle:[xcodeprojDefinition fileOperationStyle]];
    [[_project objects] setObject:[self asDictionary] forKey:_key];
    
    // create PBXContainerItemProxies and PBXReferenceProxies
    [_project addProxies:xcodeprojDefinition];
    
    // add projectReferences key to PBXProject
    [self addProductsGroupToProject:xcodeprojDefinition];
    
    return YES;
}

- (BOOL) addXcodeproj:(XcodeprojDefinition*)xcodeprojDefinition toTargets:(NSArray*)targets {
    [self addXcodeproj:xcodeprojDefinition];
    
    // add subproject's build products to targets (does not add the subproject's test bundle)
    NSArray* buildProductFiles = [_project buildProductsForTargets];
    for (SourceFile* file in buildProductFiles) {
        [self addSourceFile:file toTargets:targets];
    }
    // add main target of subproject as target dependency to main target of project
    [_project addAsTargetDependency:xcodeprojDefinition toTargets:targets];
    
    return YES;
}

- (BOOL) removeXcodeproj:(XcodeprojDefinition*)xcodeprojDefinition {
    if (xcodeprojDefinition == nil)
        return NO;
    
    // set xcodeproj's path relative to the project root
    xcodeprojDefinition.pathRelativeToProjectRoot = [_project makePathRelativeToProjectRoot:[xcodeprojDefinition xcodeprojFullPathName]];
    
    NSMutableArray* keysToDelete = [[NSMutableArray alloc] init];
    
    // get xcodeproj's PBXFileReference key
    NSString* xcodeprojKey = [_project keyForProjectFileWithName:[xcodeprojDefinition pathRelativeToProjectRoot]];
    // use the xcodeproj's PBXFileReference key to get the PBXContainerItemProxy keys
    [keysToDelete addObject:xcodeprojKey];
    NSArray* containerItemProxyKeys = [_project keysForProjectObjectsOfType:PBXContainerItemProxy withIdentifier:xcodeprojKey];
    // use the PBXContainerItemProxy keys to get the PBXReferenceProxy keys
    for (NSString* key in containerItemProxyKeys) {
        [keysToDelete addObjectsFromArray:[_project keysForProjectObjectsOfType:PBXReferenceProxy withIdentifier:key]];
        [keysToDelete addObject:key];
    }
    // use the PBXProject projectReference dictionary to get the key of of the correct PBXGroup Products
    NSMutableDictionary *PBXProjectDict = [[_project objects] valueForKey:[[_project keysForProjectObjectsOfType:PBXProject withIdentifier:nil] objectAtIndex:0]];
    NSMutableArray* projectReferences = [PBXProjectDict valueForKey:@"projectReferences"];

    // remove all objects located above
    [keysToDelete enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
        [[_project objects] removeObjectForKey:obj];
    }];
    // remove from group
    NSMutableDictionary* currentGroup = [[_project objects] valueForKey:_key];
    NSMutableArray* children = [currentGroup valueForKey:@"children"];
    [children removeObject:xcodeprojKey];
    NSString* productsGroupKey = nil;
    // remove entry from PBXProject's projectReferences, and remove it entirely if it's empty
    for (NSDictionary* projectRef in projectReferences) {
        if ([[projectRef valueForKey:@"ProjectRef"] isEqualToString:xcodeprojKey]) {
            // it's an error if we find more than one
            if (productsGroupKey != nil) {
                return NO;
            }
            productsGroupKey = [projectRef valueForKey:@"ProductGroup"];
            [projectReferences removeObject:projectRef];
        }
    }
    if ([projectReferences count] == 0) {
        [PBXProjectDict removeObjectForKey:@"projectReferences"];
    }
    // remove subproject's build products from PDXBuildFiles
    // Products/children -> PBXReferenceProxy -> fileRef of PBXBuildFile
    NSDictionary* productsGroup = [[_project objects] objectForKey:productsGroupKey];
    for (NSString* childKey in [productsGroup valueForKey:@"children"]) {
        NSArray* buildFileKeys = [_project keysForProjectObjectsOfType:PBXBuildFile withIdentifier:childKey];
        if ([buildFileKeys count] > 1) {
            return NO;
        }
         // could be zero - we didn't add the test bundle as a build product
        if ([buildFileKeys count] == 1) {
            [[_project objects] removeObjectForKey:[buildFileKeys objectAtIndex:0]];
        }
    }
    
    // remove Products groups
    [[_project objects] removeObjectForKey:productsGroupKey];
    
    return YES;
}

- (BOOL) removeXcodeproj:(XcodeprojDefinition*)xcodeprojDefinition fromTargets:(NSArray*)targets {
    if (xcodeprojDefinition == nil)
        return NO;
    
    [self removeXcodeproj:xcodeprojDefinition];
    
    // get the key for the PBXTargetDependency with name = xcodeproj file name (without extension)
    NSArray* targetDependencyKeys = [_project keysForProjectObjectsOfType:PBXTargetDependency withIdentifier:[xcodeprojDefinition sourceFileName]];
    if ([targetDependencyKeys count] > 1) {
        return NO;
    }
    // use the key for the PBXTargetDependency to get the key for the PBXNativeTarget
    NSArray* nativeTargetKeys = [_project keysForProjectObjectsOfType:PBXNativeTarget withIdentifier:[targetDependencyKeys objectAtIndex:0]];
    if ([nativeTargetKeys count] > 1) {
        return NO;
    }
    // there is an entry for libModule.a in PBXFrameworksBuildPhase files, but it's hard to track down.  Wait and see if Xcode will remove it for us.
    NSMutableDictionary* nativeTarget = [[_project objects] valueForKey:[nativeTargetKeys objectAtIndex:0]];
    NSMutableArray* dependencies = [nativeTarget valueForKey:@"dependencies"];
    [dependencies removeObject:[targetDependencyKeys objectAtIndex:0]];
    [nativeTarget setObject:dependencies forKey:@"dependencies"];
    
    return YES;
}

/* ================================================================================================================== */
#pragma mark Members

- (NSArray*) members {
    if (_members == nil) {
        _members = [[NSMutableArray alloc] init];
        for (NSString* childKey in _children) {
            XcodeMemberType type = [self typeForKey:childKey];
            if (type == PBXGroup) {
                [_members addObject:[_project groupWithKey:childKey]];
            }
            else if (type == PBXFileReference) {
                [_members addObject:[_project fileWithKey:childKey]];
            }
        }
    }
    NSSortDescriptor* sorter = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    return [_members sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
}

- (NSArray*) recursiveMembers {
    NSMutableArray* recursiveMembers = [NSMutableArray array];
    for (NSString* childKey in _children) {
        XcodeMemberType type = [self typeForKey:childKey];
        if (type == PBXGroup) {
            Group* group = [_project groupWithKey:childKey];
            NSArray* groupChildren = [group recursiveMembers];
            [recursiveMembers addObjectsFromArray:groupChildren];
        }
        else if (type == PBXFileReference) {
            [recursiveMembers addObject:childKey];
        }
    }
    return [recursiveMembers arrayByAddingObjectsFromArray:recursiveMembers];
}

- (NSArray*) buildFileKeys {

    NSMutableArray* arrayOfBuildFileKeys = [NSMutableArray array];
    for (id<XcodeGroupMember> groupMember in [self members]) {

        if ([groupMember groupMemberType] == PBXGroup) {
            Group* group = (Group*) groupMember;
            [arrayOfBuildFileKeys addObjectsFromArray:[group buildFileKeys]];
        }
        else if ([groupMember groupMemberType] == PBXFileReference) {
            [arrayOfBuildFileKeys addObject:[groupMember key]];
        }
    }
    return arrayOfBuildFileKeys;
}

- (id<XcodeGroupMember>) memberWithKey:(NSString*)key {
    id<XcodeGroupMember> groupMember = nil;

    if ([_children containsObject:key]) {
        XcodeMemberType type = [self typeForKey:key];
        if (type == PBXGroup) {
            groupMember = [_project groupWithKey:key];
        }
        else if (type == PBXFileReference) {
            groupMember = [_project fileWithKey:key];
        }
    }
    return groupMember;
}

- (id<XcodeGroupMember>) memberWithDisplayName:(NSString*)name {
    for (id<XcodeGroupMember> member in [self members]) {
        if ([[member displayName] isEqualToString:name]) {
            return member;
        }
    }
    return nil;
}

/* ================================================= Protocol Methods =============================================== */
- (XcodeMemberType) groupMemberType {
    return PBXGroup;
}

- (NSString*) displayName {
    if (_pathRelativeToParent == nil) {
        return _alias;
    }
    else {
        return [_pathRelativeToParent lastPathComponent];
    }
}

- (NSString*) pathRelativeToProjectRoot {
    if (_pathRelativeToProjectRoot == nil) {
        NSMutableArray* pathComponents = [[NSMutableArray alloc] init];
        Group* group;
        NSString* key = _key;

        while ((group = [_project groupForGroupMemberWithKey:key]) != nil && !([group pathRelativeToParent] == nil)) {
            [pathComponents addObject:[group pathRelativeToParent]];
            key = [group key];
        }

        NSMutableString* fullPath = [[NSMutableString alloc] init];
        for (int i = [pathComponents count] - 1; i >= 0; i--) {
            [fullPath appendFormat:@"%@/", [pathComponents objectAtIndex:i]];
        }
        _pathRelativeToProjectRoot = [fullPath stringByAppendingPathComponent:_pathRelativeToParent];
    }
    return _pathRelativeToProjectRoot;
}

/* ================================================== Utility Methods =============================================== */
- (NSString*) description {
    return [NSString stringWithFormat:@"Group: displayName = %@, key=%@", [self displayName], _key];
}

/* ================================================== Private Methods =============================================== */
#pragma mark Private
- (void) addMemberWithKey:(NSString*)key {

    for (NSString* childKey in _children) {
        if ([childKey isEqualToString:key]) {
            [self flagMembersAsDirty];
            return;
        }
    }
    [_children addObject:key];
    [self flagMembersAsDirty];
}

- (void) flagMembersAsDirty {
    _members = nil;
}

/* ================================================================================================================== */

- (void) makeGroupMemberWithName:(NSString*)name contents:(id)contents type:(XcodeSourceFileType)type
        fileOperationStyle:(XcodeFileOperationStyle)fileOperationStyle {

    NSString* filePath;
    SourceFile* currentSourceFile = (SourceFile*) [self memberWithDisplayName:name];
    if ((currentSourceFile) == nil) {
        NSDictionary* reference = [self makeFileReferenceWithPath:name name:nil type:type];
        NSString* fileKey = [[KeyBuilder forItemNamed:name] build];
        [[_project objects] setObject:reference forKey:fileKey];
        [self addMemberWithKey:fileKey];
        filePath = [self pathRelativeToProjectRoot];
    }
    else {
        filePath = [[currentSourceFile pathRelativeToProjectRoot] stringByDeletingLastPathComponent];
    }

    BOOL writeFile = NO;
    if (fileOperationStyle == FileOperationStyleOverwrite) {
        writeFile = YES;
        if ([_fileOperationQueue fileWithName:name existsInProjectDirectory:filePath]) {
            LogInfo(@"*** WARNING *** Group %@ already contains member with name %@. Contents will be updated", [self
                    displayName], name);
        }
    }
    else if (fileOperationStyle == FileOperationStyleAcceptExisting &&
            ![_fileOperationQueue fileWithName:name existsInProjectDirectory:filePath]) {
        writeFile = YES;
    }
    if (writeFile) {
        if ([contents isKindOfClass:[NSString class]]) {
            [_fileOperationQueue queueTextFile:name inDirectory:filePath withContents:contents];
        }
        else {
            [_fileOperationQueue queueDataFile:name inDirectory:filePath withContents:contents];
        }
    }
}

- (void) makeGroupMemberWithName:(NSString*)name path:(NSString*)path type:(XcodeSourceFileType)type
              fileOperationStyle:(XcodeFileOperationStyle)fileOperationStyle {
    SourceFile* currentSourceFile = (SourceFile*) [self memberWithDisplayName:name];
    if ((currentSourceFile) == nil) {
        NSDictionary* reference = [self makeFileReferenceWithPath:path name:name type:type];
        NSString* fileKey = [[KeyBuilder forItemNamed:name] build];
        [[_project objects] setObject:reference forKey:fileKey];
        [self addMemberWithKey:fileKey];
    }
}

- (NSString*) makeProductsGroup:(XcodeprojDefinition*) xcodeprojDefinition {
    NSMutableArray* children = [[NSMutableArray alloc] init];
    for (NSString* productName in [xcodeprojDefinition buildProducts]) {
        [children addObject:[_project referenceProxyKeyForName:productName]];
    }
    NSString* productKey = [[KeyBuilder forItemNamed:@"Products"] build];
    Group* productsGroup = [Group groupWithProject:_project key:productKey alias:@"Products" path:nil children:children];
    [[_project objects] setObject:[productsGroup asDictionary] forKey:productKey];
    return productKey;
}


- (void) addProductsGroupToProject:(XcodeprojDefinition*) xcodeprojDefinition {
    NSString* productKey = [self makeProductsGroup:xcodeprojDefinition];
    
    NSMutableDictionary* PBXProjectDict = [[_project objects] valueForKey:[[_project keysForProjectObjectsOfType:PBXProject withIdentifier:nil] objectAtIndex:0]];
    NSMutableArray* projectReferences = [NSMutableArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:productKey, @"ProductGroup", [[_project fileWithName:[xcodeprojDefinition pathRelativeToProjectRoot]] key], @"ProjectRef", nil]];
    [PBXProjectDict setObject:projectReferences forKey:@"projectReferences"];
}

/* ================================================================================================================== */

#pragma mark Dictionary Representations

- (NSDictionary*) makeFileReferenceWithPath:(NSString*)path name:(NSString*)name type:(XcodeSourceFileType)type {
    NSMutableDictionary* reference = [NSMutableDictionary dictionary];
    [reference setObject:[NSString stringFromMemberType:PBXFileReference] forKey:@"isa"];
    [reference setObject:@"4" forKey:@"FileEncoding"];
    [reference setObject:[NSString stringFromSourceFileType:type] forKey:@"lastKnownFileType"];
    if (name != nil) {
        [reference setObject:[name lastPathComponent] forKey:@"name"];
    }
    if (path != nil) {
        [reference setObject:path forKey:@"path"];
    }
    [reference setObject:@"<group>" forKey:@"sourceTree"];
    return reference;
}


- (NSDictionary*) asDictionary {
    NSMutableDictionary* groupData = [[NSMutableDictionary alloc] init];
    [groupData setObject:[NSString stringFromMemberType:PBXGroup] forKey:@"isa"];
    [groupData setObject:@"<group>" forKey:@"sourceTree"];

    if (_alias != nil) {
        [groupData setObject:_alias forKey:@"name"];
    }

    if (_pathRelativeToParent) {
        [groupData setObject:_pathRelativeToParent forKey:@"path"];
    }

    [groupData setObject:_children forKey:@"children"];
    return groupData;
}

- (XcodeMemberType) typeForKey:(NSString*)key {
    NSDictionary* obj = [[_project objects] valueForKey:key];
    return [[obj valueForKey:@"isa"] asMemberType];
}

- (void) addSourceFile:(SourceFile*)sourceFile toTargets:(NSArray*)targets {
    LogDebug(@"Adding source file %@ to targets %@", sourceFile, targets);
    for (Target* target in targets) {
        [target addMember:sourceFile];
    }
}

@end