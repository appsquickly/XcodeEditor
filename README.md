# Description

An API for manipulating Xcode project files. 

# Usage

## Adding Source Files to a Project

```objective-c
Project* project = [[Project alloc] initWithFilePath:@"MyProject.xcodeproj"];
Group* group = [project groupWithPath:@"Main"];
ClassDefinition* classDefinition = [[ClassDefinition alloc] initWithName:@"MyNewClass"];
[classDefinition setHeader:[NSString stringWithTestResource:@"<some-header-text>"]];
[classDefinition setSource:[NSString stringWithTestResource:@"<some-impl-text>"]];

[group addClass:classDefinition];
[project save];
```

## Specifying Source File Belongs to Target

```objective-c
FileResource* fileResource = [project projectFileWithPath:@"MyNewClass.m"];
Target* examples = [project targetWithName:@"Examples"];
[examples addMember:fileResource];
[project save];
```

# Docs

* <a href="https://github.com/expanz/xcode-editor/wiki">Wiki</a>
* <a href="http://expanz.github.com/xcode-editor/api/index.html">API</a>
* <a href="http://expanz.github.com/xcode-editor/coverage/Users/jblues/ExpanzProjects/xcode-editor1/Source/Main/index.html">Reports</a>

# Building 

## Just the Framework

Open the project in XCode and choose Product/Build. 

## Command-line Build with Unit Tests, Integration Tests, Code Coverge and API reports installed to Xcode. 

### Requirements (one time only)

Requires the Appledoc and lcov packages. A nice way to install these is with <a href="http://www.macports.org/install.php">MacPorts</a>

```sh
>sudo port install appledoc
>sudo port install lcov
```

### Running the build (every other time)

```sh
>ant 
```
# Feature Requests and Contributions

. . . are very welcome. 


# Authors

* Jasper Blues - jasper.blues@expanz.com
* © 2011 - 2012 expanz.com


