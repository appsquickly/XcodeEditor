//
//  XCBuildFile.h
//  XcodeEditor
//
//  Created by joel on 01/02/16.
//  Copyright © 2016 appsquickly. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XCBuildFile <NSObject>

- (void)becomeBuildFile;
- (XcodeMemberType)buildPhase;
- (NSString *)buildFileKey;
- (BOOL)isBuildFile;
@end
