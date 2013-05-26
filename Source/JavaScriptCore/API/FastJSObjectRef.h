#ifndef FastJSObjectRef_h
#define FastJSObjectRef_h

#include <JavaScriptCore/JSBase.h>
#include <JavaScriptCore/JSValueRef.h>
#include <JavaScriptCore/WebKitAvailability.h>

#ifndef __cplusplus
#include <stdbool.h>
#endif
#include <stddef.h> /* for size_t */

#ifdef __cplusplus
extern "C" {
#endif

    JSObjectRef __JSObjectMake(JSContextRef ctx, JSClassRef jsClass, void* data);
    
    JSObjectRef __JSObjectMakeFunctionWithCallback(JSContextRef ctx, JSStringRef name, JSObjectCallAsFunctionCallback callAsFunction);
    
    JSObjectRef __JSObjectMakeConstructor(JSContextRef ctx, JSClassRef jsClass, JSObjectCallAsConstructorCallback callAsConstructor);
    
    JSObjectRef __JSObjectMakeFunction(JSContextRef ctx, JSStringRef name, unsigned parameterCount, const JSStringRef parameterNames[], JSStringRef body, JSStringRef sourceURL, int startingLineNumber, JSValueRef* exception);
    
    JSObjectRef __JSObjectMakeArray(JSContextRef ctx, size_t argumentCount, const JSValueRef arguments[],  JSValueRef* exception);
    
    JSObjectRef __JSObjectMakeDate(JSContextRef ctx, size_t argumentCount, const JSValueRef arguments[],  JSValueRef* exception);
    
    JSObjectRef __JSObjectMakeError(JSContextRef ctx, size_t argumentCount, const JSValueRef arguments[],  JSValueRef* exception);
    
    JSObjectRef __JSObjectMakeRegExp(JSContextRef ctx, size_t argumentCount, const JSValueRef arguments[],  JSValueRef* exception);
    
    JSValueRef __JSObjectGetPrototype(JSContextRef ctx, JSObjectRef object);
    
    void __JSObjectSetPrototype(JSContextRef ctx, JSObjectRef object, JSValueRef value);
    
    bool __JSObjectHasProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName);
    
    JSValueRef __JSObjectGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception);
    
    void __JSObjectSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSPropertyAttributes attributes, JSValueRef* exception);
    
    JSValueRef __JSObjectGetPropertyAtIndex(JSContextRef ctx, JSObjectRef object, unsigned propertyIndex, JSValueRef* exception);
    
    void __JSObjectSetPropertyAtIndex(JSContextRef ctx, JSObjectRef object, unsigned propertyIndex, JSValueRef value, JSValueRef* exception);
    
    bool __JSObjectDeleteProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception);
    
    JSValueRef __JSObjectGetPrivateProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName);
    
    bool __JSObjectSetPrivateProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value);
    
    bool __JSObjectDeletePrivateProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName);
    
    JSValueRef __JSObjectCallAsFunction(JSContextRef ctx, JSObjectRef object, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception);
    
    JSObjectRef __JSObjectCallAsConstructor(JSContextRef ctx, JSObjectRef object, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception);
    
    JSPropertyNameArrayRef __JSObjectCopyPropertyNames(JSContextRef ctx, JSObjectRef object);
    
    JSPropertyNameArrayRef __JSPropertyNameArrayRetain(JSPropertyNameArrayRef array);
    
    void __JSPropertyNameArrayRelease(JSPropertyNameArrayRef array);
    
    void __JSPropertyNameAccumulatorAddName(JSPropertyNameAccumulatorRef array, JSStringRef propertyName);
    
#ifdef __cplusplus
}
#endif

#endif /* FastJSObjectRef_h */
