//
//  FastJSContextReft.h
//  JavaScriptCore
//
//  Created by Andrey Verbin on 18.05.13.
//
//

#ifndef __JavaScriptCore__FastJSContextRef__
#define __JavaScriptCore__FastJSContextRef__

#include <JavaScriptCore/JavaScriptCore.h>
#include <CoreFoundation/CoreFoundation.h>

#ifdef __cplusplus
extern "C" {
#endif
    
JS_EXPORT void __JSContextFastAPIInit(JSContextRef ctx);
JS_EXPORT CFAllocatorRef __JSContextGetCFStrAllocator(JSContextRef ctx);
JS_EXPORT void* __JSContextGetJustAllocatedBlock(JSContextRef ctx);
JS_EXPORT JSObjectRef __JSContextGetGlobalObject(JSContextRef ctx);
    
#ifdef __cplusplus
}
#endif
        

#endif /* defined(__JavaScriptCore__FastJSContextRef__) */
