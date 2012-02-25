# Description

An API for manipulating Xcode project files. 

# Usage

## Adding Source Files to a Project

```objective-c
Project* project = [[Project alloc] initWithFilePath:@"/tmp"];
Group* group = [project groupWithPath:@"Main"];
ClassDefinition* classDefinition = [[ClassDefinition alloc] initWithName:@"MyNewClass"];
[classDefinition setHeader:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.header"]];
[classDefinition setSource:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.impl"]];

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

* Wiki:
* Api: http://expanz.github.com/xcode-editor/api/index.html
* Reports: http://expanz.github.com/xcode-editor/coverage/index.html

<link pending> 

# Feature Requests and Contributions

. . . are very welcome. 


# Authors

* Jasper Blues - jasper.blues@expanz.com
* © 2011 - 2012 expanz.com


