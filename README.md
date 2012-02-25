# Description

An API for manipulating Xcode project files. 

# Usage

## Adding Source Files to a Project

Project* project = [[Project alloc] initWithFilePath:@"/tmp"];
Group* group = [project groupWithPath:@"Main"];
ClassDefinition* classDefinition = [[ClassDefinition alloc] initWithName:@"MyNewClass"];
[classDefinition setHeader:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.header"]];
[classDefinition setSource:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.impl"]];

[group addClass:classDefinition];
[project save];


## Specifying Source File Belongs to Target

FileResource* fileResource = [project projectFileWithPath:@"MyNewClass.m"];
Target* examples = [project targetWithName:@"Examples"];
[examples addMember:fileResource];
[project save];

# API Docs

<link pending> 


# Authors

Jasper Blues - jasper.blues@expanz.com


