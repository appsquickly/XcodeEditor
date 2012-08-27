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

#if !defined(__has_feature) || !__has_feature(objc_arc)
	#define XCAutorelease(__var) [__var autorelease];
	#define XCRetain(__var) [__var retain];
	#define XCRetainAutorelease(__var) [[__var retain] autorelease];
	#define XCRelease(__var) [__var release];
	#define XCSuperDealloc [super dealloc];
#else
	#define XCAutorelease(__var) (__var);
	#define XCRetain(__var) (__var);
	#define XCRetainAutorelease(__var) (__var);
	#define XCRelease(__var) (void)(__var);
	#define XCSuperDealloc
#endif
