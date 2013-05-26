//
//  FastJSContextRef.cpp
//  JavaScriptCore
//
//  Created by Andrey Verbin on 18.05.13.
//
//

#include "config.h"
#include "FastJSContextRef.h"
#include "JSContextRefPrivate.h"

#include "APICast.h"
#include "InitializeThreading.h"
#include <interpreter/CallFrame.h>
#include <interpreter/Interpreter.h>
#include "JSCallbackObject.h"
#include "JSClassRef.h"
#include "JSGlobalObject.h"
#include "JSObject.h"
#include "Operations.h"
#include "SourceProvider.h"
#include <wtf/text/StringBuilder.h>
#include <wtf/text/StringHash.h>

using namespace JSC;

static const void* retain(const void* info) {
    return info;
}
    
NO_RETURN_DUE_TO_ASSERT
static void release(const void*) {
    ASSERT_NOT_REACHED();
}
    
static CFStringRef copyDescription(const void* value) {
    return (CFStringRef)value;
}
    
static void* allocate(CFIndex size, CFOptionFlags, void* info) {
    WTF::StringImpl** realBuffer = (WTF::StringImpl**)fastMalloc(size + sizeof(StringImpl*));
    //shift pointer forward to leave space for asociated StringImpl pointer
    //this space will be filled later with pointer to associated StringImpl in __JSValueMakeCFStringNoCopy
    realBuffer[0] = NULL;
    *(WTF::StringImpl***)info = realBuffer; //store reference to beginning of allocated memory
    return realBuffer + 1;
}
    
static void* reallocate(void* pointer, CFIndex newSize, CFOptionFlags, void* info) {
    if (pointer == NULL || newSize <= 0) return NULL;
    size_t newAllocationSize = newSize + sizeof(StringImpl*);
    //shift pointer back, to get real memory buffer beginning
    WTF::StringImpl** realBuffer = (StringImpl**)pointer - 1;
    realBuffer = (WTF::StringImpl**)fastRealloc(realBuffer, newAllocationSize);
    *(WTF::StringImpl***)info = realBuffer; //store reference to beginning on allocated memory
    return (StringImpl**)realBuffer + 1;
}
    
static void deallocate(void* pointer, void*) {
    WTF::StringImpl **realBuffer = (WTF::StringImpl**)pointer - 1;
    WTF::StringImpl *stringImpl = realBuffer[0];
    stringImpl->deref();
    WTF::fastFree(realBuffer);
}
    
static CFIndex preferredSize(CFIndex size, CFOptionFlags, void*) {
    // FIXME: If FastMalloc provided a "good size" callback, we'd want to use it here.
    // Note that this optimization would help performance for strings created with the
    // allocator that are mutable, and those typically are only created by callers who
    // make a new string using the old string's allocator, such as some of the call
    // sites in CFURL.
    return size;
}
    
struct FastAPIClientData : public VM::ClientData {
    CFAllocatorRef cfstrAllocator;
    void *justAllocatedBlock;
    FastAPIClientData() : cfstrAllocator(0), justAllocatedBlock(NULL){
        CFAllocatorContext context = { 0, &this->justAllocatedBlock, retain, release, copyDescription, allocate, reallocate, deallocate, preferredSize };
        this->cfstrAllocator = CFAllocatorCreate(0, &context);
    }
    ~FastAPIClientData() {
        if (cfstrAllocator) {
            CFRelease(cfstrAllocator);
        }
    }
};

    
void __JSContextFastAPIInit(JSContextRef ctx) {
    ExecState* exec = toJS(ctx); APIEntryShim entry(exec);
    VM &vm = exec->vm();
    FastAPIClientData * fastAPIClientData = (FastAPIClientData*)vm.clientData;
    ASSERT(!fastAPIClientData);
    vm.clientData = fastAPIClientData = new FastAPIClientData();
}
    
CFAllocatorRef __JSContextGetCFStrAllocator(JSContextRef ctx) {
    ExecState* exec = toJS(ctx); APIEntryShim entry(exec);
    VM &vm = exec->vm();
    FastAPIClientData * fastAPIClientData = (FastAPIClientData*)vm.clientData;
    ASSERT(fastAPIClientData);
    return fastAPIClientData->cfstrAllocator;
    return NULL;
}

void* __JSContextGetJustAllocatedBlock(JSContextRef ctx) {
    ExecState* exec = toJS(ctx); APIEntryShim entry(exec);
    VM &vm = exec->vm();
    FastAPIClientData * fastAPIClientData = (FastAPIClientData*)vm.clientData;
    ASSERT(fastAPIClientData);
    return fastAPIClientData->justAllocatedBlock;
    return NULL;
}
    
JSObjectRef __JSContextGetGlobalObject(JSContextRef ctx)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    
    // It is necessary to call toThisObject to get the wrapper object when used with WebCore.
    return toRef(exec->lexicalGlobalObject()->methodTable()->toThisObject(exec->lexicalGlobalObject(), exec));
}