#include <JavaScriptCore/config.h>
#include <JavaScriptCore/JavaScriptCore.h>
#include "FastJSValueRef.h"
#include "FastJSContextRef.h"

#include <API/APICast.h>
#include <API/JSCallbackObject.h>
#include <runtime/JSGlobalObject.h>
#include <runtime/JSONObject.h>
#include <runtime/JSString.h>
#include <runtime/LiteralParser.h>
#include <runtime/Operations.h>
#include <runtime/Protect.h>
#include <runtime/JSCJSValue.h>

#include <wtf/Assertions.h>
#include <wtf/text/StringHash.h>

#include <algorithm> // for std::min

#import <Foundation/Foundation.h>

#define likely(x)       __builtin_expect((x),1)
#define unlikely(x)     __builtin_expect((x),0)

using namespace JSC;

::JSType __JSValueGetType(JSContextRef ctx, JSValueRef value)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return kJSTypeUndefined;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    
    JSValue jsValue = toJS(exec, value);
    
    if (jsValue.isUndefined())
        return kJSTypeUndefined;
    if (jsValue.isNull())
        return kJSTypeNull;
    if (jsValue.isBoolean())
        return kJSTypeBoolean;
    if (jsValue.isNumber())
        return kJSTypeNumber;
    if (jsValue.isString())
        return kJSTypeString;
    ASSERT(jsValue.isObject());
    return kJSTypeObject;
}


bool __JSValueIsUndefined(JSContextRef ctx, JSValueRef value)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return false;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    
    JSValue jsValue = toJS(exec, value);
    return jsValue.isUndefined();
}

bool __JSValueIsNull(JSContextRef ctx, JSValueRef value)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return false;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    
    JSValue jsValue = toJS(exec, value);
    return jsValue.isNull();
}

bool __JSValueIsBoolean(JSContextRef ctx, JSValueRef value)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return false;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    
    JSValue jsValue = toJS(exec, value);
    return jsValue.isBoolean();
}

bool __JSValueIsNumber(JSContextRef ctx, JSValueRef value)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return false;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    
    JSValue jsValue = toJS(exec, value);
    return jsValue.isNumber();
}

bool __JSValueIsString(JSContextRef ctx, JSValueRef value)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return false;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    
    JSValue jsValue = toJS(exec, value);
    return jsValue.isString();
}

bool __JSValueIsObject(JSContextRef ctx, JSValueRef value)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return false;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    
    JSValue jsValue = toJS(exec, value);
    return jsValue.isObject();
}

bool __JSValueIsObjectOfClass(JSContextRef ctx, JSValueRef value, JSClassRef jsClass)
{
    if (!ctx || !jsClass) {
        ASSERT_NOT_REACHED();
        return false;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    
    JSValue jsValue = toJS(exec, value);
    
    if (JSObject* o = jsValue.getObject()) {
        if (o->inherits(&JSCallbackObject<JSGlobalObject>::s_info))
            return jsCast<JSCallbackObject<JSGlobalObject>*>(o)->inherits(jsClass);
        if (o->inherits(&JSCallbackObject<JSDestructibleObject>::s_info))
            return jsCast<JSCallbackObject<JSDestructibleObject>*>(o)->inherits(jsClass);
#if JSC_OBJC_API_ENABLED
        if (o->inherits(&JSCallbackObject<JSAPIWrapperObject>::s_info))
            return jsCast<JSCallbackObject<JSAPIWrapperObject>*>(o)->inherits(jsClass);
#endif
    }
    return false;
}

bool __JSValueIsEqual(JSContextRef ctx, JSValueRef a, JSValueRef b, JSValueRef* exception)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return false;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    
    JSValue jsA = toJS(exec, a);
    JSValue jsB = toJS(exec, b);
    
    bool result = JSValue::equal(exec, jsA, jsB); // false if an exception is thrown
    if (exec->hadException()) {
        if (exception)
            *exception = toRef(exec, exec->exception());
        exec->clearException();
    }
    return result;
}

bool __JSValueIsStrictEqual(JSContextRef ctx, JSValueRef a, JSValueRef b)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return false;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    
    JSValue jsA = toJS(exec, a);
    JSValue jsB = toJS(exec, b);
    
    return JSValue::strictEqual(exec, jsA, jsB);
}

bool __JSValueIsInstanceOfConstructor(JSContextRef ctx, JSValueRef value, JSObjectRef constructor, JSValueRef* exception)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return false;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    
    JSValue jsValue = toJS(exec, value);
    
    JSObject* jsConstructor = toJS(constructor);
    if (!jsConstructor->structure()->typeInfo().implementsHasInstance())
        return false;
    bool result = jsConstructor->hasInstance(exec, jsValue); // false if an exception is thrown
    if (exec->hadException()) {
        if (exception)
            *exception = toRef(exec, exec->exception());
        exec->clearException();
    }
    return result;
}

JSValueRef __JSValueMakeUndefined(JSContextRef ctx)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    
    return toRef(exec, jsUndefined());
}

JSValueRef __JSValueMakeNull(JSContextRef ctx)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    
    return toRef(exec, jsNull());
}

JSValueRef __JSValueMakeBoolean(JSContextRef ctx, bool value)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    
    return toRef(exec, jsBoolean(value));
}

JSValueRef __JSValueMakeNumber(JSContextRef ctx, double value)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    
    // Our JSValue representation relies on a standard bit pattern for NaN. NaNs
    // generated internally to JavaScriptCore naturally have that representation,
    // but an external NaN might not.
    if (std::isnan(value))
        value = QNaN;
    
    return toRef(exec, jsNumber(value));
}

JSValueRef __JSValueMakeString(JSContextRef ctx, JSStringRef string)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    
    return toRef(exec, jsString(exec, string->string()));
}

JSValueRef __JSValueMakeFromJSONString(JSContextRef ctx, JSStringRef string)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    String str = string->string();
    unsigned length = str.length();
    if (length && str.is8Bit()) {
        LiteralParser<LChar> parser(exec, str.characters8(), length, StrictJSON);
        return toRef(exec, parser.tryLiteralParse());
    }
    LiteralParser<UChar> parser(exec, str.characters(), length, StrictJSON);
    return toRef(exec, parser.tryLiteralParse());
}

JSStringRef __JSValueCreateJSONString(JSContextRef ctx, JSValueRef apiValue, unsigned indent, JSValueRef* exception)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    JSValue value = toJS(exec, apiValue);
    String result = JSONStringify(exec, value, indent);
    if (exception)
        *exception = 0;
    if (exec->hadException()) {
        if (exception)
            *exception = toRef(exec, exec->exception());
        exec->clearException();
        return 0;
    }
    return OpaqueJSString::create(result).leakRef();
}

bool __JSValueToBoolean(JSContextRef ctx, JSValueRef value)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return false;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    
    JSValue jsValue = toJS(exec, value);
    return jsValue.toBoolean(exec);
}

double __JSValueToNumber(JSContextRef ctx, JSValueRef value, JSValueRef* exception)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return QNaN;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    
    JSValue jsValue = toJS(exec, value);
    
    double number = jsValue.toNumber(exec);
    if (exec->hadException()) {
        if (exception)
            *exception = toRef(exec, exec->exception());
        exec->clearException();
        number = QNaN;
    }
    return number;
}

JSStringRef __JSValueToStringCopy(JSContextRef ctx, JSValueRef value, JSValueRef* exception)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    
    JSValue jsValue = toJS(exec, value);
    
    RefPtr<OpaqueJSString> stringRef(OpaqueJSString::create(jsValue.toString(exec)->value(exec)));
    if (exec->hadException()) {
        if (exception)
            *exception = toRef(exec, exec->exception());
        exec->clearException();
        stringRef.clear();
    }
    return stringRef.release().leakRef();
}

JSObjectRef __JSValueToObject(JSContextRef ctx, JSValueRef value, JSValueRef* exception)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    
    JSValue jsValue = toJS(exec, value);
    
    JSObjectRef objectRef = toRef(jsValue.toObject(exec));
    if (exec->hadException()) {
        if (exception)
            *exception = toRef(exec, exec->exception());
        exec->clearException();
        objectRef = 0;
    }
    return objectRef;
}

CFStringRef __JSValueToCFStringNoCopy(JSContextRef ctx, JSValueRef value, JSValueRef* exception)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx); APIEntryShim entry(exec);
        
    JSValue jsValue = toJS(exec, value);
    const String& str = jsValue.toString(exec)->value(exec);
    if (unlikely(exec->hadException())) {
        if (exception)
            *exception = toRef(exec, exec->exception());
        exec->clearException();
        return NULL;
    }
    CFAllocatorRef cfstrAllocator = __JSContextGetCFStrAllocator(ctx);
    CFStringRef cfstr = CFStringCreateWithCharactersNoCopy(cfstrAllocator,
                                                           str.characters(),
                                                           str.length(),
                                                           kCFAllocatorNull);
    WTF::StringImpl** realBuffer = (WTF::StringImpl**)__JSContextGetJustAllocatedBlock(ctx);
    WTF::StringImpl *impl = str.impl();
    impl->ref();
    realBuffer[0] = impl;
    return cfstr;
}
    
CFStringRef __JSValueToCFStringCopy(JSContextRef ctx, JSValueRef value, JSValueRef* exception)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx); APIEntryShim entry(exec);
    APIEntryShim entryShim(exec);
    
    JSValue jsValue = toJS(exec, value);
    const String& str = jsValue.toString(exec)->value(exec);
    if (exec->hadException()) {
        if (exception)
            *exception = toRef(exec, exec->exception());
        exec->clearException();
    }
    return CFStringCreateWithCharacters(NULL, str.characters(), str.length());
}