# Description

An API for manipulating Xcode project files. 

# Usage

### Adding Source Files to a Project


```objective-c
XCProject* project = [[XCProject alloc] initWithFilePath:@"MyProject.xcodeproj"];
XCGroup* group = [project groupWithPathFromRoot:@"Main"];
XCClassDefinition* classDefinition = [[XCClassDefinition alloc] initWithName:@"MyNewClass"];
[classDefinition setHeader:@"<some-header-text>"];
[classDefinition setSource:@"<some-impl-text>"];

[group addClass:classDefinition];
[project save];
```

### Duplicating Targets

It will be added to project as well.

```objective-c
XCTarget* target = [project targetWithName:@"SomeTarget"];
XCTarget* duplicated = [target duplicateWithTargetName:@"DuplicatedTarget" productName:@"NewProduct"];
```


### Specifying Source File Belongs to Target

```objective-c
XCSourceFile* sourceFile = [project fileWithName:@"MyNewClass.m"];
XCTarget* examples = [project targetWithName:@"Examples"];
[examples addMember:sourceFile];
[project save];
```


### Adding a Xib File

This time, we'll use a convenience method on XCGroup to specify the targets at the same time:

```objective-c
XCXibDefinition* xibDefinition = [[XCXibDefinition alloc] initWithName:@"MyXibFile" content:@"<xibXml>"];
[group addXib:xibDefinition toTargets:[project targets]];
[project save];
```


### Adding a Framework

```objective-c
XCFrameworkDefinition* frameworkDefinition =
    [[XCFrameworkDefinition alloc] initWithFilePath:@"<framework path>" copyToDestination:NO];
[group addFramework:frameworkDefinition toTargets:[project targets]];
[project save];
```
Setting copyToDestination to YES, will cause the framework to be first copied to the group's directory within the
project, and subsequently linked from there. 

### Adding an Image Resource

```objective-c

XCSourceFileDefinition* sourceFileDefinition = [[XCSourceFileDefinition alloc]
    initWithName:@"MyImageFile.png" data:[NSData dataWithContentsOfFile:<your image file name>]
    type:ImageResourcePNG];

[group addSourceFile:sourceFileDefinition];
[project save];
```

### Adding Asset Catalog (ImageSet)

```objective-c

XCSourceFileDefinition* sourceFileDefinition = [XCSourceFileDefinition sourceDefinitionWithAssetCatalogName:<path to asset catalog>];

[group addSourceFile:sourceFileDefinition];
[project save];
```

### Adding a Header

```objective-c
XCSourceFileDefinition* header = [[XCSourceFileDefinition alloc]
    initWithName:@"SomeHeader.h" text:<your header text> type:SourceCodeHeader];

[group addSourceFile:header];
[project save];
```

### Adding a sub-project

```objective-c
subProjectDefinition = [XCSubProjectDefinition withName:@"mySubproject" projPath=@"/Path/To/Subproject" type:XcodeProject];
[group addSubProject:subProjectDefinition toTargets:[project targets]];
```

### Removing a sub-project
```objective-c
[group removeSubProject:subProjectDefinition];  //TODO: project should be able to remove itself from parent.
```

### Configuring targets

We can add/update linker flags, header search paths, C-flags, etc to a target.  Here we'll add header search paths: 

```objective-c
XCTarget* target = [_project targetWithName:_projectName];
for (NSString* configName in [target configurations])
{
    XCBuildConfiguration* configuration = [target configurationWithName:configName];
    NSMutableArray* headerPaths = [[NSMutableArray alloc] init];
    [headerPaths addObject:@"$(inherited)"];
    [headerPaths addObject:@"$(SRCROOT)/include"];        
    [configuration addOrReplaceSetting:headerPaths forKey:@"HEADER_SEARCH_PATHS"];
}
```

. . . these settings are added by key, as they would appear in a make file. (Xcode provides more human friendly descriptions). To find the key for a given build setting, consult the compiler docs. Common settings are: 

* HEADER_SEARCH_PATHS
* OTHER_LD_FLAGS
* CLANG_CXX_LANGUAGE_STANDARD
* CODE_SIGN_IDENTITY
* GCC_C_LANGUAGE_STANDARD
* INFOPLIST_FILE 
* LIBRARY_SEARCH_PATHS
* PRODUCT_NAME
* PROVISIONING_PROFILE

###Adding a Library

```objc
XCSourceFile * libSourceFile = [project fileWithName:@"libAmazing.a"];

XCTarget* target = [project targetWithName:self.mProject.projectName];
[target addMember:libSourceFile];

for (NSString* configName in [target configurations]) {
    XCProjectBuildConfig* configuration = [target configurationWithName:configName];
    NSMutableArray* headerPaths = [[NSMutableArray alloc] init];
    [headerPaths addObject:@"$(inherited)"];
    [headerPaths addObject:@"$(PROJECT_DIR)/Amazing"];
    [configuration addOrReplaceSetting:headerPaths forKey:@"LIBRARY_SEARCH_PATHS"];
}
```

### File write behavior

```objective-c
//Creates the reference in the project and writes the contents to disk. If a file already exists at the 
//specified location, its contents will be updated.
[definition setFileOperationStyle:FileOperationStyleOverwrite]; 
```

```objective-c
//Creates the reference in the project. If a file already exists at the specified location, the contents will 
//not be updated.
[definition setFileOperationStyle:FileOperationStyleAcceptExisting]; 
```

    
```objective-c
//Creates the reference in the project, but does not write to disk. The filesystem is expected to be updated 
//through some other means.
[definition setFileOperationStyle:FileOperationStyleReferenceOnly]; 
```


# Building 

Open the project in XCode and choose Product/Build. Alternatively install with CocoaPods. 

# Feature Requests and Contributions

. . . are very welcome. 

If you're using the API shoot me an email and tell me what you're doing with it. 

# Compatibility 

* Xcode-editor has been tested on Xcode 4+. It should also work on earlier versions of Xcode. 
* The AppCode IDE from JetBrains is now supported too! 
* Supports both ARC and MRR modes of memory management.

# Who's using it? 

* <a href="http://www.apportable.com">Apportable</a> : Develop Android applications using Xcode, Objective-C and Cocoa APIs
* <a href="https://github.com/calabash/calabash-ios">Xamarin</a>: The Calabash automated functional testing for mobile applications. 
* <a href="https://github.com/markohlebar/Peckham">Peckham</a> : A great plugin for managing Xcode imports
* <a href="http://www.levelhelper.org">Level Helper</a>: A RAD framework for developing 2D games on iOS & Android. 
* <a href="http://macromates.com/">Text Mate</a>: The missing Text Editor for OSX.



# Authors

* <a href="http://ph.linkedin.com/pub/jasper-blues/8/163/778">Jasper Blues</a> - <a href="mailto:jasper@appsquick.ly?Subject=xcode-editor">jasper@appsquick.ly</a>
         
### With contributions from: 

* <a href="https://github.com/cncool">Connor Duggan</a> - lots of bug fixes, maintenance and enhancements. 
* <a href="https://github.com/smirn0v">Alexander Smirnov</a> - Cleaned up, generalized and contributed back the changes from the Calabash fork. 
* Zach Drayer - lots of fixes and features to support TextMate. 
* Janine Ohmer - support adding and removing sub-projects (http://www.synapticats.com).
* Bogdan Vladu - support adding and removing groups (www.levelhelper.org).
* Chris Ross of Hidden Memory (http://www.hiddenmemory.co.uk/)
* Paul Taykalo
* Vladislav Alekseev 
* Felix Schneider - bug fixes. 
* Isak Sky - mutable XCSourceFiles. 
* <a href="https://github.com/hartman">Derk-Jan Hartman</a> : Adding folder references, by-file compiler flags. 
* <a href="https://github.com/StoneSpb">StoneSpb</a> : Speed improvements
* <a href="https://github.com/cezheng">Ce Zheng</a> : Fixes relating to Xcode 7, xcconfig support and others. 

Thanks! 

# LICENSE

Apache License, Version 2.0, January 2004, http://www.apache.org/licenses/

* © 2011 - 2012 Jasper Blues and contributors.




