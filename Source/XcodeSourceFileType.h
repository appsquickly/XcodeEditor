////////////////////////////////////////////////////////////////////////////////
//
//  JASPER BLUES
//  Copyright 2012 Jasper Blues
//  All Rights Reserved.
//
//  NOTICE: Jasper Blues permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, XcodeSourceFileType)
{
    FileTypeNil = 0,             // Unknown filetype
    Framework = 1,               // .framework
    PropertyList = 2,            // .plist
    SourceCodeHeader = 3,        // .h
    SourceCodeObjC = 4,          // .m
    SourceCodeObjCPlusPlus = 5,  // .mm
    SourceCodeCPlusPlus = 6,     // .cpp
    XibFile = 7,                 // .xib
    ImageResourcePNG = 8,        // .png
    Bundle = 9,                  // .bundle  .octet
    Archive = 10,                // .a files
    HTML = 11,                   // HTML file
    TEXT = 12,                   // Some text file
    XcodeProject = 13,           // .xcodeproj
    Folder = 14,                 // a Folder reference
    AssetCatalog = 15,           // Assets
    SourceCodeSwift = 16,        // .swift
    Application = 17,            // .app (wrapper.application)
    Playground = 18,             // .playground (file.playground)
    ShellScript = 19,            // no suffix Xcode seems to detect (text.script.sh)
    Markdown = 20,               // .md (net.daringfileball.markdown)
    XMLPropertyList = 21,        // .plist (text.plist.xml)
    Storyboard = 22,             // .storyboard (file.storyboard)
    XCConfig = 23,               // .xcconfig
    XCDataModel = 24,            // .xcdatamodel
    LocalizableStrings = 25      // .strings
};

NSString* NSStringFromXCSourceFileType(XcodeSourceFileType type);

XcodeSourceFileType XCSourceFileTypeFromStringRepresentation(NSString* string);

XcodeSourceFileType XCSourceFileTypeFromFileName(NSString* fileName);

