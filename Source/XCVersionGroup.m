//
//  XCCoreDataModelVersioned.m
//  xcode-editor
//
//  Created by joel on 04/09/15.
//
//

#import "XCVersionGroup.h"
#import "XCTarget.h"
#import "XCFileOperationQueue.h"
#import "XCSourceFile.h"
#import "XCProject.h"
#import "Utils/XCKeyBuilder.h"
#import "XCSourceFileDefinition.h"
#import "XCProject+SubProject.h"

@implementation XCVersionGroup

//-------------------------------------------------------------------------------------------
#pragma mark - Class Methods
//-------------------------------------------------------------------------------------------

+ (XCVersionGroup*)versionGroupWithProject:(XCProject*)project key:(NSString*)key path:(NSString*)path children:(NSArray*)children currentVersion:(NSString*)currentVersion
{
    return [[XCVersionGroup alloc] initWithProject:project key:key path:path children:children currentVersion:currentVersion];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Initialization & Destruction
//-------------------------------------------------------------------------------------------

- (id)initWithProject:(XCProject*)project key:(NSString*)key path:(NSString*)path children:(NSArray*)children currentVersion:(NSString*)currentVersion
{
    self = [super init];
    if (self)
    {
        _project = project;
        _fileOperationQueue = [_project fileOperationQueue];
        _key = [key copy];
        _currentVersion = [currentVersion copy];
        _pathRelativeToParent = [path copy];
        
        _children = [children mutableCopy];
        if (!_children)
        {
            _children = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Interface Methods
//-------------------------------------------------------------------------------------------

#pragma mark Parent group

- (void)removeFromParentGroup
{
    [self removeFromParentDeletingChildren:NO];
}


- (void)removeFromParentDeletingChildren:(BOOL)deleteChildren
{
    if (deleteChildren)
    {
        [_fileOperationQueue queueDeletion:[self pathRelativeToProjectRoot]];
    }
    NSDictionary* dictionary = [_project objects][_key];
    NSLog(@"Here's the dictionary: %@", dictionary);
    
    [[_project objects] removeObjectForKey:_key];
    
    dictionary = [_project objects][_key];
    NSLog(@"Here's the dictionary: %@", dictionary);
    
    for (XCTarget* target in [_project targets])
    {
        for (XCSourceFile *source in [self members]) {
            [target removeMemberWithKey:source.key];
        }
    }
    NSLog(@"Done!!!");
}

- (XCGroup*)parentGroup
{
    return [_project groupForGroupMemberWithKey:_key];
}

- (BOOL)isRootGroup
{
    return [self pathRelativeToParent] == nil && [self displayName] == nil;
}


//-------------------------------------------------------------------------------------------
#pragma mark Adding children

- (void)addDataModelSource:(XCSourceFileDefinition*)sourceFileDefinition
{
    if([sourceFileDefinition type] == XCDataModel)
    {
        [self makeGroupMemberWithName:[sourceFileDefinition sourceFileName]
                                                 contents:[sourceFileDefinition data]
                                                     type:[sourceFileDefinition type]
                                       fileOperationStyle:[sourceFileDefinition fileOperationType]];
        
        [_project objects][_key] = [self asDictionary];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Project file of type %@ can't be a child of a %@",
         _versionGroupType, NSStringFromXCSourceFileType([sourceFileDefinition type])];
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark Members

- (NSArray*)members
{
    if (_members == nil)
    {
        _members = [[NSMutableArray alloc] init];
        for (NSString* childKey in _children)
        {
            XcodeMemberType type = [self typeForKey:childKey];
            
            @autoreleasepool
            {
                if (type == PBXFileReferenceType)
                {
                    [_members addObject:[_project fileWithKey:childKey]];
                }
            }
        }
    }
    return _members;
}

- (NSArray*)buildFileKeys
{
    NSMutableArray* arrayOfBuildFileKeys = [NSMutableArray array];
    for (id <XcodeGroupMember> groupMember in [self members])
    {
        
        if ([groupMember groupMemberType] == PBXGroupType || [groupMember groupMemberType] == PBXVariantGroupType)
        {
            XCGroup* group = (XCGroup*) groupMember;
            [arrayOfBuildFileKeys addObjectsFromArray:[group buildFileKeys]];
        }
        else if ([groupMember groupMemberType] == PBXFileReferenceType)
        {
            [arrayOfBuildFileKeys addObject:[groupMember key]];
        }
    }
    return arrayOfBuildFileKeys;
}

- (XCSourceFile*)memberWithKey:(NSString*)key
{
    XCSourceFile* groupMember = nil;
    
    if ([_children containsObject:key])
    {
        XcodeMemberType type = [self typeForKey:key];
        if (type == PBXFileReferenceType)
        {
            groupMember = [_project fileWithKey:key];
        }
    }
    return groupMember;
}

- (id <XcodeGroupMember>)memberWithDisplayName:(NSString*)name
{
    for (id <XcodeGroupMember> member in [self members])
    {
        if ([[member displayName] isEqualToString:name])
        {
            return member;
        }
    }
    return nil;
}

#pragma Current version

- (void)setCurrentVersion:(NSString *)currentVersion
{
    [self willChangeValueForKey:@"currentVersion"];
    _currentVersion = currentVersion;
    [self didChangeValueForKey:@"currentVersion"];
    
    [_project objects][_key] = [self asDictionary];
}
//-------------------------------------------------------------------------------------------
#pragma mark - Protocol Methods

- (XcodeMemberType)groupMemberType
{
    return [self typeForKey:self.key];
}

- (NSString*)displayName
{
    if (_alias)
    {
        return _alias;
    }
    return [_pathRelativeToParent lastPathComponent];
}

- (NSString*)pathRelativeToProjectRoot
{
    if (_pathRelativeToProjectRoot == nil)
    {
        NSMutableArray* pathComponents = [[NSMutableArray alloc] init];
        XCGroup* group = nil;
        NSString* key = [_key copy];
        
        while ((group = [_project groupForGroupMemberWithKey:key]) != nil && [group pathRelativeToParent] != nil)
        {
            [pathComponents addObject:[group pathRelativeToParent]];
            key = [[group key] copy];
        }
        
        NSMutableString* fullPath = [[NSMutableString alloc] init];
        for (NSInteger i = (NSInteger) [pathComponents count] - 1; i >= 0; i--)
        {
            [fullPath appendFormat:@"%@/", pathComponents[i]];
        }
        _pathRelativeToProjectRoot = [[fullPath stringByAppendingPathComponent:_pathRelativeToParent] copy];
    }
    return _pathRelativeToProjectRoot;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Build file Methods
- (XcodeMemberType)buildPhase
{
    return PBXSourcesBuildPhaseType;
}

- (NSString *)buildFileKey
{
    if (_buildFileKey == nil) {
        [[_project objects] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *obj, BOOL *stop) {
            if ([[obj valueForKey:@"isa"] xce_hasBuildFileType]) {
                if ([[obj valueForKey:@"fileRef"] isEqualToString:_key]) {
                    _buildFileKey = [key copy];
                }
            }
        }];
    }
    return [_buildFileKey copy];
    
}


- (void)becomeBuildFile
{
    if (![self isBuildFile]) {
        NSMutableDictionary *sourceBuildFile = [NSMutableDictionary dictionary];
        sourceBuildFile[@"isa"] = [NSString xce_stringFromMemberType:PBXBuildFileType];
        sourceBuildFile[@"fileRef"] = _key;
        NSString *buildFileKey = [[XCKeyBuilder forItemNamed:[self.displayName stringByAppendingString:@".buildFile"]] build];
        [_project objects][buildFileKey] = sourceBuildFile;
    }
}

- (BOOL)isBuildFile
{
    if (_isBuildFile == nil) {
        _isBuildFile = @NO;
        [[_project objects] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *obj, BOOL *stop) {
            if ([[obj valueForKey:@"isa"] xce_hasBuildFileType]) {
                if ([[obj valueForKey:@"fileRef"] isEqualToString:_key]) {
                    _isBuildFile = nil;
                    
                    _isBuildFile = @YES;
                }
            }
        }];
    }
    return [_isBuildFile boolValue];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Utility Methods

- (NSString*)description
{
    return [NSString stringWithFormat:@"Group: displayName = %@, key=%@", [self displayName], _key];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Private Methods
//-------------------------------------------------------------------------------------------

- (void)addMemberWithKey:(NSString*)key
{
    for (NSString* childKey in _children)
    {
        if ([childKey isEqualToString:key])
        {
            [self flagMembersAsDirty];
            return;
        }
    }
    [_children addObject:key];
    [self flagMembersAsDirty];
}

- (void)flagMembersAsDirty
{
    _members = nil;
}

//-------------------------------------------------------------------------------------------

- (NSString*)makeGroupMemberWithName:(NSString*)name contents:(id)contents type:(XcodeSourceFileType)type
                  fileOperationStyle:(XCFileOperationType)fileOperationStyle
{
    NSString*fileKey;
    NSString* filePath;
    XCSourceFile* currentSourceFile = (XCSourceFile*) [self memberWithDisplayName:name];
    if ((currentSourceFile) == nil)
    {
        NSString *refName = nil;
        if (type == AssetCatalog) {
            refName = [name lastPathComponent];
        }
        NSDictionary* reference = [self makeFileReferenceWithPath:name name:refName type:type];
        fileKey = [[XCKeyBuilder forItemNamed:name] build];
        [_project objects][fileKey] = reference;
        [self addMemberWithKey:fileKey];
        
        filePath = [self pathRelativeToProjectRoot];
    }
    else
    {
        filePath = [[currentSourceFile pathRelativeToProjectRoot] stringByDeletingLastPathComponent];
        fileKey = currentSourceFile.key;
    }
    
    BOOL writeFile = NO;
    if (fileOperationStyle == XCFileOperationTypeOverwrite)
    {
        writeFile = YES;
        [_fileOperationQueue fileWithName:name existsInProjectDirectory:filePath];
    }
    else if (fileOperationStyle == XCFileOperationTypeAcceptExisting &&
             ![_fileOperationQueue fileWithName:name existsInProjectDirectory:filePath])
    {
        writeFile = YES;
    }
    if (writeFile)
    {
        [_fileOperationQueue queueDirectory:name inDirectory:filePath];
        [_fileOperationQueue commitFileOperations];
        filePath  = [filePath stringByAppendingPathComponent:name];
        name = @"contents";
        if ([contents isKindOfClass:[NSString class]])
        {
            [_fileOperationQueue queueTextFile:name inDirectory:filePath withContents:contents];
        }
        else
        {
            [_fileOperationQueue queueDataFile:name inDirectory:filePath withContents:contents];
        }
    }
    
    return fileKey;
}

//-------------------------------------------------------------------------------------------

#pragma mark Xcodeproj methods

// creates PBXFileReference and adds to group if not already there;  returns key for file reference.  Locates
// member via path rather than name, because that is how subprojects are stored by Xcode
- (void)makeGroupMemberWithName:(NSString*)name path:(NSString*)path type:(XcodeSourceFileType)type
             fileOperationStyle:(XCFileOperationType)fileOperationStyle
{
    XCSourceFile* currentSourceFile = (XCSourceFile*) [self memberWithDisplayName:name];
    if ((currentSourceFile) == nil)
    {
        NSDictionary* reference = [self makeFileReferenceWithPath:path name:name type:type];
        NSString* fileKey = [[XCKeyBuilder forItemNamed:name] build];
        [_project objects][fileKey] = reference;
        [self addMemberWithKey:fileKey];
    }
}


// removes PBXFileReference from group and project
- (void)removeGroupMemberWithKey:(NSString*)key
{
    NSMutableArray* children = [self valueForKey:@"children"];
    [children removeObject:key];
    _project.objects[_key] = [self asDictionary];
    // remove PBXFileReference
    [_project.objects removeObjectForKey:key];
}

// removes the given key from the files arrays of the given section, if found (intended to be used with
// PBXFrameworksBuildPhase and PBXResourcesBuildPhase)
// they are not required because we are currently not adding these entries;  Xcode is doing it for us. The existing
// code for adding to a target doesn't do it, and I didn't add it since Xcode will take care of it for me and I was
// avoiding modifying existing code as much as possible)
- (void)removeBuildPhaseFileKey:(NSString*)key forType:(XcodeMemberType)memberType
{
    NSArray* buildPhases = [_project keysForProjectObjectsOfType:memberType withIdentifier:nil singleton:NO required:NO];
    for (NSString* buildPhaseKey in buildPhases)
    {
        NSDictionary* buildPhaseDict = [[_project objects] valueForKey:buildPhaseKey];
        NSMutableArray* fileKeys = [buildPhaseDict valueForKey:@"files"];
        for (NSString* fileKey in fileKeys)
        {
            if ([fileKey isEqualToString:key])
            {
                [fileKeys removeObject:fileKey];
            }
        }
    }
}

// removes entries from PBXBuildFiles, PBXFrameworksBuildPhase and PBXResourcesBuildPhase
- (void)removeProductsGroupFromProject:(NSString*)key
{
    // remove product group's build products from PDXBuildFiles
    NSDictionary* productsGroup = _project.objects[key];
    for (NSString* childKey in [productsGroup valueForKey:@"children"])
    {
        NSArray* buildFileKeys = [_project keysForProjectObjectsOfType:PBXBuildFileType withIdentifier:childKey singleton:NO required:NO];
        // could be zero - we didn't add the test bundle as a build product
        if ([buildFileKeys count] == 1)
        {
            NSString* buildFileKey = buildFileKeys[0];
            [[_project objects] removeObjectForKey:buildFileKey];
            [self removeBuildPhaseFileKey:buildFileKey forType:PBXFrameworksBuildPhaseType];
            [self removeBuildPhaseFileKey:buildFileKey forType:PBXResourcesBuildPhaseType];
        }
    }
}

//-------------------------------------------------------------------------------------------

#pragma mark Dictionary Representations

- (NSDictionary*)makeFileReferenceWithPath:(NSString*)path name:(NSString*)name type:(XcodeSourceFileType)type
{
    NSMutableDictionary* reference = [NSMutableDictionary dictionary];
    reference[@"isa"] = [NSString xce_stringFromMemberType:PBXFileReferenceType];
    reference[@"fileEncoding"] = @"4";
    reference[@"lastKnownFileType"] = NSStringFromXCSourceFileType(type);
    if (name != nil)
    {
        reference[@"name"] = [name lastPathComponent];
    }
    if (path != nil)
    {
        reference[@"path"] = path;
    }
    reference[@"sourceTree"] = @"<group>";
    return reference;
}


- (NSDictionary*)asDictionary
{
    NSMutableDictionary* groupData = [NSMutableDictionary dictionary];
    groupData[@"isa"] = [NSString xce_stringFromMemberType:XCVersionGroupType];
    groupData[@"sourceTree"] = @"<group>";
    groupData[@"versionGroupType"] = @"wrapper.xcdatamodel";
    
    if (_alias != nil)
    {
        groupData[@"name"] = _alias;
    }
    
    if (_pathRelativeToParent)
    {
        groupData[@"path"] = _pathRelativeToParent;
    }
    
    if (_children)
    {
        groupData[@"children"] = _children;
    }
    
    if(_currentVersion)
    {
        groupData[@"currentVersion"]=_currentVersion;
    }
    
    return groupData;
}

- (XcodeMemberType)typeForKey:(NSString*)key
{
    NSDictionary* obj = [[_project objects] valueForKey:key];
    return [[obj valueForKey:@"isa"] xce_asMemberType];
}

- (void)addSourceFile:(XCSourceFile*)sourceFile toTargets:(NSArray*)targets
{
    for (XCTarget* target in targets)
    {
        [target addMember:sourceFile];
    }
}

@end
