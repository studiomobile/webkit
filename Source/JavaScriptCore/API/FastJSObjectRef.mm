//
//  FastJSObjectRef.cpp
//  JavaScriptCore
//
//  Created by Andrey Verbin on 16.05.13.
//
//

#include <JavaScriptCore/config.h>
#include <JavaScriptCore/JavaScriptCore.h>
#include "FastJSObjectRef.h"

#include <API/JSObjectRef.h>
#include <API/JSObjectRefPrivate.h>
#include <API/APICast.h>

#include <wtf/text/TextPosition.h>
#include <runtime/DateConstructor.h>
#include <runtime/ErrorConstructor.h>
#include <runtime/FunctionConstructor.h>
#include <runtime/ObjectConstructor.h>
#include <runtime/Identifier.h>
#include <runtime/InitializeThreading.h>
#include <runtime/JSArray.h>
#include <API/JSCallbackConstructor.h>
#include <API/JSCallbackFunction.h>
#include <API/JSCallbackObject.h>
#include <runtime/JSFunction.h>
#include <runtime/JSGlobalObject.h>
#include <runtime/JSObject.h>
#include <API/JSRetainPtr.h>
#include <runtime/JSString.h>
#include <runtime/ObjectPrototype.h>
#include <runtime/PropertyNameArray.h>
#include <runtime/RegExpConstructor.h>
#import <Foundation/Foundation.h>
#define likely(x)       __builtin_expect((x),1)
#define unlikely(x)     __builtin_expect((x),0)

using namespace JSC;

JSObjectRef __JSObjectMake(JSContextRef ctx, JSClassRef jsClass, void* data)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx); APIEntryShim entry(exec);
    if (!jsClass)
        return toRef(constructEmptyObject(exec));
    
    JSCallbackObject<JSDestructibleObject>* object = JSCallbackObject<JSDestructibleObject>::create(exec, exec->lexicalGlobalObject(), exec->lexicalGlobalObject()->callbackObjectStructure(), jsClass, data);
    if (JSObject* prototype = jsClass->prototype(exec))
        object->setPrototype(exec->vm(), prototype);
    
    return toRef(object);

}

JSObjectRef __JSObjectMakeFunctionWithCallback(JSContextRef ctx, JSStringRef name, JSObjectCallAsFunctionCallback callAsFunction)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx); APIEntryShim entry(exec);
    return toRef(JSCallbackFunction::create(exec, exec->lexicalGlobalObject(), callAsFunction, name ? name->string() : ASCIILiteral("anonymous")));
}

JSObjectRef __JSObjectMakeConstructor(JSContextRef ctx, JSClassRef jsClass, JSObjectCallAsConstructorCallback callAsConstructor)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx); APIEntryShim entry(exec);    
    JSValue jsPrototype = jsClass ? jsClass->prototype(exec) : 0;
    if (!jsPrototype)
        jsPrototype = exec->lexicalGlobalObject()->objectPrototype();
    
    JSCallbackConstructor* constructor = JSCallbackConstructor::create(exec, exec->lexicalGlobalObject(), exec->lexicalGlobalObject()->callbackConstructorStructure(), jsClass, callAsConstructor);
    constructor->putDirect(exec->vm(), exec->propertyNames().prototype, jsPrototype, DontEnum | DontDelete | ReadOnly);
    return toRef(constructor);
}

JSObjectRef __JSObjectMakeFunction(JSContextRef ctx, JSStringRef name, unsigned parameterCount, const JSStringRef parameterNames[], JSStringRef body, JSStringRef sourceURL, int startingLineNumber, JSValueRef* exception)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx); APIEntryShim entry(exec);

    Identifier nameID = name ? name->identifier(&exec->vm()) : Identifier(exec, "anonymous");
    
    MarkedArgumentBuffer args;
    for (unsigned i = 0; i < parameterCount; i++)
        args.append(jsString(exec, parameterNames[i]->string()));
    args.append(jsString(exec, body->string()));
    
    JSObject* result = constructFunction(exec, exec->lexicalGlobalObject(), args, nameID, sourceURL->string(), TextPosition(OrdinalNumber::fromOneBasedInt(startingLineNumber), OrdinalNumber::first()));
    if (exec->hadException()) {
        if (exception)
            *exception = toRef(exec, exec->exception());
        exec->clearException();
        result = 0;
    }
    return toRef(result);
}

JSObjectRef __JSObjectMakeArray(JSContextRef ctx, size_t argumentCount, const JSValueRef arguments[],  JSValueRef* exception)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx); APIEntryShim entry(exec);
    
    JSObject* result;
    if (argumentCount) {
        MarkedArgumentBuffer argList;
        for (size_t i = 0; i < argumentCount; ++i)
            argList.append(toJS(exec, arguments[i]));
        
        result = constructArray(exec, static_cast<ArrayAllocationProfile*>(0), argList);
    } else
        result = constructEmptyArray(exec, 0);
    
    if (exec->hadException()) {
        if (exception)
            *exception = toRef(exec, exec->exception());
        exec->clearException();
        result = 0;
    }
    
    return toRef(result);
}

JSObjectRef __JSObjectMakeDate(JSContextRef ctx, size_t argumentCount, const JSValueRef arguments[],  JSValueRef* exception)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx); APIEntryShim entry(exec);
    
    MarkedArgumentBuffer argList;
    for (size_t i = 0; i < argumentCount; ++i)
        argList.append(toJS(exec, arguments[i]));
    
    JSObject* result = constructDate(exec, exec->lexicalGlobalObject(), argList);
    if (exec->hadException()) {
        if (exception)
            *exception = toRef(exec, exec->exception());
        exec->clearException();
        result = 0;
    }
    
    return toRef(result);
}

JSObjectRef __JSObjectMakeError(JSContextRef ctx, size_t argumentCount, const JSValueRef arguments[],  JSValueRef* exception)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx);
    APIEntryShim entryShim(exec);
    
    JSValue message = argumentCount ? toJS(exec, arguments[0]) : jsUndefined();
    Structure* errorStructure = exec->lexicalGlobalObject()->errorStructure();
    JSObject* result = ErrorInstance::create(exec, errorStructure, message);
    
    if (exec->hadException()) {
        if (exception)
            *exception = toRef(exec, exec->exception());
        exec->clearException();
        result = 0;
    }
    
    return toRef(result);
}

JSObjectRef __JSObjectMakeRegExp(JSContextRef ctx, size_t argumentCount, const JSValueRef arguments[],  JSValueRef* exception)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx); APIEntryShim entryShim(exec);
    
    MarkedArgumentBuffer argList;
    for (size_t i = 0; i < argumentCount; ++i)
        argList.append(toJS(exec, arguments[i]));
    
    JSObject* result = constructRegExp(exec, exec->lexicalGlobalObject(),  argList);
    if (exec->hadException()) {
        if (exception)
            *exception = toRef(exec, exec->exception());
        exec->clearException();
        result = 0;
    }
    
    return toRef(result);
}

JSValueRef __JSObjectGetPrototype(JSContextRef ctx, JSObjectRef object)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx); APIEntryShim entryShim(exec);
    
    JSObject* jsObject = toJS(object);
    return toRef(exec, jsObject->prototype());
}

void __JSObjectSetPrototype(JSContextRef ctx, JSObjectRef object, JSValueRef value)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return;
    }
    ExecState* exec = toJS(ctx); APIEntryShim entry(exec);
    
    JSObject* jsObject = toJS(object);
    JSValue jsValue = toJS(exec, value);
    
    jsObject->setPrototypeWithCycleCheck(exec->vm(), jsValue.isObject() ? jsValue : jsNull());
}

bool __JSObjectHasProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return false;
    }
    ExecState* exec = toJS(ctx); APIEntryShim entry(exec);
    
    JSObject* jsObject = toJS(object);
    
    return jsObject->hasProperty(exec, propertyName->identifier(&exec->vm()));
}

JSValueRef __JSObjectGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx); APIEntryShim entry(exec);
    
    JSObject* jsObject = toJS(object);
    
    JSValue jsValue = jsObject->get(exec, propertyName->identifier(&exec->vm()));
    if (exec->hadException()) {
        if (exception)
            *exception = toRef(exec, exec->exception());
        exec->clearException();
    }
    return toRef(exec, jsValue);
}

void __JSObjectSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSPropertyAttributes attributes, JSValueRef* exception)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return;
    }
    ExecState* exec = toJS(ctx); APIEntryShim entry(exec);
    
    JSObject* jsObject = toJS(object);
    Identifier name(propertyName->identifier(&exec->vm()));
    JSValue jsValue = toJS(exec, value);
    
    if (attributes && !jsObject->hasProperty(exec, name))
        jsObject->methodTable()->putDirectVirtual(jsObject, exec, name, jsValue, attributes);
    else {
        PutPropertySlot slot;
        jsObject->methodTable()->put(jsObject, exec, name, jsValue, slot);
    }
    
    if (exec->hadException()) {
        if (exception)
            *exception = toRef(exec, exec->exception());
        exec->clearException();
    }
}

JSValueRef __JSObjectGetPropertyAtIndex(JSContextRef ctx, JSObjectRef object, unsigned propertyIndex, JSValueRef* exception)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    ExecState* exec = toJS(ctx); APIEntryShim entryShim(exec);
    
    JSObject* jsObject = toJS(object);
    
    JSValue jsValue = jsObject->get(exec, propertyIndex);
    if (exec->hadException()) {
        if (exception)
            *exception = toRef(exec, exec->exception());
        exec->clearException();
    }
    return toRef(exec, jsValue);
}


void __JSObjectSetPropertyAtIndex(JSContextRef ctx, JSObjectRef object, unsigned propertyIndex, JSValueRef value, JSValueRef* exception)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return;
    }
    ExecState* exec = toJS(ctx); APIEntryShim entryShim(exec);
    
    JSObject* jsObject = toJS(object);
    JSValue jsValue = toJS(exec, value);
    
    jsObject->methodTable()->putByIndex(jsObject, exec, propertyIndex, jsValue, false);
    if (exec->hadException()) {
        if (exception)
            *exception = toRef(exec, exec->exception());
        exec->clearException();
    }
}

bool __JSObjectDeleteProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return false;
    }
    ExecState* exec = toJS(ctx); APIEntryShim entry(exec);
    
    JSObject* jsObject = toJS(object);
    
    bool result = jsObject->methodTable()->deleteProperty(jsObject, exec, propertyName->identifier(&exec->vm()));
    if (exec->hadException()) {
        if (exception)
            *exception = toRef(exec, exec->exception());
        exec->clearException();
    }
    return result;
}

JSValueRef __JSObjectGetPrivateProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName)
{
    ExecState* exec = toJS(ctx); APIEntryShim entry(exec);
    JSObject* jsObject = toJS(object);
    JSValue result;
    Identifier name(propertyName->identifier(&exec->vm()));
    if (jsObject->inherits(&JSCallbackObject<JSGlobalObject>::s_info))
        result = jsCast<JSCallbackObject<JSGlobalObject>*>(jsObject)->getPrivateProperty(name);
    else if (jsObject->inherits(&JSCallbackObject<JSDestructibleObject>::s_info))
        result = jsCast<JSCallbackObject<JSDestructibleObject>*>(jsObject)->getPrivateProperty(name);
#if JSC_OBJC_API_ENABLED
    else if (jsObject->inherits(&JSCallbackObject<JSAPIWrapperObject>::s_info))
        result = jsCast<JSCallbackObject<JSAPIWrapperObject>*>(jsObject)->getPrivateProperty(name);
#endif
    return toRef(exec, result);
}

bool __JSObjectSetPrivateProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value)
{
    ExecState* exec = toJS(ctx); APIEntryShim entry(exec);
    JSObject* jsObject = toJS(object);
    JSValue jsValue = value ? toJS(exec, value) : JSValue();
    Identifier name(propertyName->identifier(&exec->vm()));
    if (jsObject->inherits(&JSCallbackObject<JSGlobalObject>::s_info)) {
        jsCast<JSCallbackObject<JSGlobalObject>*>(jsObject)->setPrivateProperty(exec->vm(), name, jsValue);
        return true;
    }
    if (jsObject->inherits(&JSCallbackObject<JSDestructibleObject>::s_info)) {
        jsCast<JSCallbackObject<JSDestructibleObject>*>(jsObject)->setPrivateProperty(exec->vm(), name, jsValue);
        return true;
    }
#if JSC_OBJC_API_ENABLED
    if (jsObject->inherits(&JSCallbackObject<JSAPIWrapperObject>::s_info)) {
        jsCast<JSCallbackObject<JSAPIWrapperObject>*>(jsObject)->setPrivateProperty(exec->vm(), name, jsValue);
        return true;
    }
#endif
    return false;
}

bool __JSObjectDeletePrivateProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName)
{
    ExecState* exec = toJS(ctx); APIEntryShim entry(exec);
    JSObject* jsObject = toJS(object);
    Identifier name(propertyName->identifier(&exec->vm()));
    if (jsObject->inherits(&JSCallbackObject<JSGlobalObject>::s_info)) {
        jsCast<JSCallbackObject<JSGlobalObject>*>(jsObject)->deletePrivateProperty(name);
        return true;
    }
    if (jsObject->inherits(&JSCallbackObject<JSDestructibleObject>::s_info)) {
        jsCast<JSCallbackObject<JSDestructibleObject>*>(jsObject)->deletePrivateProperty(name);
        return true;
    }
#if JSC_OBJC_API_ENABLED
    if (jsObject->inherits(&JSCallbackObject<JSAPIWrapperObject>::s_info)) {
        jsCast<JSCallbackObject<JSAPIWrapperObject>*>(jsObject)->deletePrivateProperty(name);
        return true;
    }
#endif
    return false;
}

JSValueRef __JSObjectCallAsFunction(JSContextRef ctx, JSObjectRef object, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception)
{
    ExecState* exec = toJS(ctx); APIEntryShim entryShim(exec);
    
    if (!object)
        return 0;
    
    JSObject* jsObject = toJS(object);
    JSObject* jsThisObject = toJS(thisObject);
    
    if (!jsThisObject)
        jsThisObject = exec->globalThisValue();
    
    jsThisObject = jsThisObject->methodTable()->toThisObject(jsThisObject, exec);
    
    MarkedArgumentBuffer argList;
    for (size_t i = 0; i < argumentCount; i++)
        argList.append(toJS(exec, arguments[i]));
    
    CallData callData;
    CallType callType = jsObject->methodTable()->getCallData(jsObject, callData);
    if (callType == CallTypeNone)
        return 0;
    
    JSValueRef result = toRef(exec, call(exec, jsObject, callType, callData, jsThisObject, argList));
    if (exec->hadException()) {
        if (exception)
            *exception = toRef(exec, exec->exception());
        exec->clearException();
        result = 0;
    }
    return result;
}

JSObjectRef __JSObjectCallAsConstructor(JSContextRef ctx, JSObjectRef object, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception)
{
    ExecState* exec = toJS(ctx); APIEntryShim entryShim(exec);
    
    if (!object)
        return 0;
    
    JSObject* jsObject = toJS(object);
    
    ConstructData constructData;
    ConstructType constructType = jsObject->methodTable()->getConstructData(jsObject, constructData);
    if (constructType == ConstructTypeNone)
        return 0;
    
    MarkedArgumentBuffer argList;
    for (size_t i = 0; i < argumentCount; i++)
        argList.append(toJS(exec, arguments[i]));
    JSObjectRef result = toRef(construct(exec, jsObject, constructType, constructData, argList));
    if (exec->hadException()) {
        if (exception)
            *exception = toRef(exec, exec->exception());
        exec->clearException();
        result = 0;
    }
    return result;
}

struct OpaqueJSPropertyNameArray {
    WTF_MAKE_FAST_ALLOCATED;
public:
    OpaqueJSPropertyNameArray(VM* vm)
    : refCount(0)
    , vm(vm)
    {
    }
    
    unsigned refCount;
    VM* vm;
    Vector<JSRetainPtr<JSStringRef> > array;
};

JSPropertyNameArrayRef __JSObjectCopyPropertyNames(JSContextRef ctx, JSObjectRef object)
{
    if (!ctx) {
        ASSERT_NOT_REACHED();
        return 0;
    }
    JSObject* jsObject = toJS(object);
    ExecState* exec = toJS(ctx); APIEntryShim entry(exec);
    
    VM* vm = &exec->vm();
    
    JSPropertyNameArrayRef propertyNames = new OpaqueJSPropertyNameArray(vm);
    PropertyNameArray array(vm);
    jsObject->methodTable()->getPropertyNames(jsObject, exec, array, ExcludeDontEnumProperties);
    
    size_t size = array.size();
    propertyNames->array.reserveInitialCapacity(size);
    for (size_t i = 0; i < size; ++i)
        propertyNames->array.uncheckedAppend(JSRetainPtr<JSStringRef>(Adopt, OpaqueJSString::create(array[i].string()).leakRef()));
    
    return JSPropertyNameArrayRetain(propertyNames);
}

JSPropertyNameArrayRef __JSPropertyNameArrayRetain(JSPropertyNameArrayRef array)
{
    ++array->refCount;
    return array;
}

void __JSPropertyNameArrayRelease(JSPropertyNameArrayRef array)
{
    if (--array->refCount == 0) {
        APIEntryShim entryShim(array->vm, false);
        delete array;
    }
}

void __JSPropertyNameAccumulatorAddName(JSPropertyNameAccumulatorRef array, JSStringRef propertyName)
{
    PropertyNameArray* propertyNames = toJS(array);
    APIEntryShim entryShim(propertyNames->vm());
    propertyNames->add(propertyName->identifier(propertyNames->vm()));
}