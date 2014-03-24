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



typedef enum
{
    FileTypeNil,             // Unknown filetype 
    Framework,               // .framework 
    PropertyList,            // .plist 
    SourceCodeHeader,        // .h     
    SourceCodeObjC,          // .m     
    SourceCodeObjCPlusPlus,  // .mm
    SourceCodeCPlusPlus,     // .cpp
    XibFile,                 // .xib   
    ImageResourcePNG,        // .png
    Bundle,                  // .bundle  .octet 
    Archive,                 // .a files
    HTML,                    // HTML file 
    TEXT,                    // Some text file 
    XcodeProject             // .xcodeproj
} XcodeSourceFileType;

NSString* NSStringFromXCSourceFileType(XcodeSourceFileType type);

XcodeSourceFileType XCSourceFileTypeFromStringRepresentation(NSString* string);

XcodeSourceFileType XCSourceFileTypeFromFileName(NSString* fileName);

