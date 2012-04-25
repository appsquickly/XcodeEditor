# Description

An API for manipulating Xcode project files. 

# Usage

### Adding Source Files to a Project


```objective-c
Project* project = [[Project alloc] initWithFilePath:@"MyProject.xcodeproj"];
Group* group = [project groupWithPath:@"Main"];
ClassDefinition* classDefinition = [[ClassDefinition alloc] initWithName:@"MyNewClass"];
[classDefinition setHeader:@"<some-header-text>"];
[classDefinition setSource:@"<some-impl-text>"];

[group addClass:classDefinition];
[project save];
```


### Specifying Source File Belongs to Target

```objective-c
File* sourceFile = [project fileWithName:@"MyNewClass.m"];
Target* examples = [project targetWithName:@"Examples"];
[examples addMember:sourceFile];
[project save];
```


### Adding a Xib File

This time, we'll use a convenience method on xcode_Group to specify the targets at the same time:

```objective-c
XibDefinition* xibDefinition = [[XibDefinition alloc] initWithName:@"MyXibFile" content:@"<xibXml>"];
[group addXib:xibDefinition toTargets:[project targets]];
[project save];
```


### Adding a Framework

```objective-c
FrameworkDefinition* frameworkDefinition = 
    [[FrameworkDefinition alloc] initWithFilePath:@"<framework path>" copyToDestination:NO];
[group addFramework:frameworkDefinition toTargets:[project targets]];
[project save];
```
Setting copyToDestination to YES, will cause the framework to be first copied to the group's directory within the 
project, and subsequently linked from there. 

# Docs

The Source/Tests folder contains further usasge examples. A good starting point is to run the test target in Xcode.
This will extract a test project to the /tmp directory, where you'll be able to see the outcome for yourself. 

* <a href="https://github.com/expanz/xcode-editor/wiki">Wiki</a>
* <a href="http://expanz.github.com/xcode-editor/api/index.html">API</a>
* <a href="http://expanz.github.com/xcode-editor/coverage/index.html">Coverage Reports</a>

# Building 

## Just the Framework

Open the project in XCode and choose Product/Build. 

## Command-line Build

Includes Unit Tests, Integration Tests, Code Coverge and API reports installed to Xcode. 

### Requirements (one time only)

In addition to Xcode, requires the Appledoc and lcov packages. A nice way to install these is with <a href="http://www.macports.org/install.php">MacPorts</a>.

```sh
git clone https://github.com/tomaz/appledoc.git
sudo install-appledoc.sh
sudo port install lcov
```

NB: Xcode 4.3+ requires command-line tools to be installed separately. 

### Running the build (every other time)

```sh
ant 
```
# Feature Requests and Contributions

. . . are very welcome. 

If you're using the API shoot me an email and tell me what you're doing with it. 

# Compatibility 

* Xcode-editor has been tested on Xcode 4+. It should also work on earlier versions of Xcode. The AppCode IDE from
JetBrains is not yet supported. 
* No longer uses ARC because one of my users needed to support 32 bit OSX. If you want to use it in an ARC project, you can safely a) Use the framework or b) Set the appropriate compiler flags (-fno-objc-arc)

# Who's using it? 

* <a href="http://www.expanz.com">expanz</a>: A RAD framework that enables .NET developers in producing cross-platform and cloud apps. 
* <a href="http://www.lesspainful.com">Less Painful</a>: Automated functional testing for mobile applications. 
* <a href="http://www.levelhelper.org">Level Helper</a>: A RAD framework for developing 2D games on iOS & Android. 

# Authors

* <a href="http://ph.linkedin.com/pub/jasper-blues/8/163/778">Jasper Blues</a> - <a href="mailto:jasper.blues@expanz.com?Subject=xcode-editor">jasper.blues@expanz.com</a>
         
### With contributions from: 

* Chris Ross of Hidden Memory (http://www.hiddenmemory.co.uk/)
* Vladislav Alekseev 

Thanks! 

# LICENSE

Apache License, Version 2.0, January 2004, http://www.apache.org/licenses/

* © 2011 - 2012 expanz.com

  