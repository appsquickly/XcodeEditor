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

typedef enum {
    FileTypeNil,             // Unknown filetype 
    Framework,               // .framework 
    PropertyList,            // .plist 
    SourceCodeHeader,        // .h     
    SourceCodeObjC,          // .m     
    SourceCodeObjCPlusPlus,  // .mm    
    XibFile,                 // .xib   
    ImageResourcePNG,        // .png
    Bundle,                  // .bundle  .octet 
    Archive,                 // .a files
    HTML,                    // HTML file 
    TEXT                     // Some text file 
} XcodeSourceFileType;

@interface NSString (XCodeFileType)

+ (NSString*) stringFromSourceFileType:(XcodeSourceFileType)type;

- (XcodeSourceFileType) asSourceFileType;

@end