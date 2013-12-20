////////////////////////////////////////////////////////////////////////////////
//
//  JASPER BLUES
//  Copyright 2013 Jasper Blues
//  All Rights Reserved.
//
//  NOTICE: Jasper Blues permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////


#import <SenTestingKit/SenTestingKit.h>

@interface VATestObserver : SenTestLog
@end

@implementation VATestObserver

extern void __gcov_flush(void);


+ (void)testSuiteDidStop:(NSNotification*)aNotification
{
    __gcov_flush();
    [super testSuiteDidStop:aNotification];
}



@end