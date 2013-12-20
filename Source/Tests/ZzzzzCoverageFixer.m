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

#import <SenTestingKit/SenTestingKit.h>

@interface ZzzzzCoverageFixer : SenTestCase
@end

extern void __gcov_flush(void);

@implementation ZzzzzCoverageFixer

- (void)test_will_run_last_to_flush_coverage
{
    __gcov_flush();
}



@end




