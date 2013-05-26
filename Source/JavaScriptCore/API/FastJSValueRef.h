/*
 * Copyright (C) 2006 Apple Computer, Inc.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE COMPUTER, INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE COMPUTER, INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef FastJSValueRef_h
#define FastJSValueRef_h

#include <CoreFoundation/CoreFoundation.h>
#include <JavaScriptCore/JSBase.h>
#include <JavaScriptCore/WebKitAvailability.h>


#ifndef __cplusplus
#include <stdbool.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif
    void fastjs_api_init();
    /*!
     @function
     @abstract       Returns a JavaScript value's type.
     @param ctx  The execution context to use.
     @param value    The JSValue whose type you want to obtain.
     @result         A value of type JSType that identifies value's type.
     */
    JS_EXPORT JSType __JSValueGetType(JSContextRef ctx, JSValueRef value);
    
    /*!
     @function
     @abstract       Tests whether a JavaScript value's type is the undefined type.
     @param ctx  The execution context to use.
     @param value    The JSValue to test.
     @result         true if value's type is the undefined type, otherwise false.
     */
    JS_EXPORT bool __JSValueIsUndefined(JSContextRef ctx, JSValueRef value);
    
    /*!
     @function
     @abstract       Tests whether a JavaScript value's type is the null type.
     @param ctx  The execution context to use.
     @param value    The JSValue to test.
     @result         true if value's type is the null type, otherwise false.
     */
    JS_EXPORT bool __JSValueIsNull(JSContextRef ctx, JSValueRef value);
    
    /*!
     @function
     @abstract       Tests whether a JavaScript value's type is the boolean type.
     @param ctx  The execution context to use.
     @param value    The JSValue to test.
     @result         true if value's type is the boolean type, otherwise false.
     */
    JS_EXPORT bool __JSValueIsBoolean(JSContextRef ctx, JSValueRef value);
    
    /*!
     @function
     @abstract       Tests whether a JavaScript value's type is the number type.
     @param ctx  The execution context to use.
     @param value    The JSValue to test.
     @result         true if value's type is the number type, otherwise false.
     */
    JS_EXPORT bool __JSValueIsNumber(JSContextRef ctx, JSValueRef value);
    
    /*!
     @function
     @abstract       Tests whether a JavaScript value's type is the string type.
     @param ctx  The execution context to use.
     @param value    The JSValue to test.
     @result         true if value's type is the string type, otherwise false.
     */
    JS_EXPORT bool __JSValueIsString(JSContextRef ctx, JSValueRef value);
    
    /*!
     @function
     @abstract       Tests whether a JavaScript value's type is the object type.
     @param ctx  The execution context to use.
     @param value    The JSValue to test.
     @result         true if value's type is the object type, otherwise false.
     */
    JS_EXPORT bool __JSValueIsObject(JSContextRef ctx, JSValueRef value);
    
    /*!
     @function
     @abstract Tests whether a JavaScript value is an object with a given class in its class chain.
     @param ctx The execution context to use.
     @param value The JSValue to test.
     @param jsClass The JSClass to test against.
     @result true if value is an object and has jsClass in its class chain, otherwise false.
     */
    JS_EXPORT bool __JSValueIsObjectOfClass(JSContextRef ctx, JSValueRef value, JSClassRef jsClass);
    
    /* Comparing values */
    
    /*!
     @function
     @abstract Tests whether two JavaScript values are equal, as compared by the JS == operator.
     @param ctx The execution context to use.
     @param a The first value to test.
     @param b The second value to test.
     @param exception A pointer to a JSValueRef in which to store an exception, if any. Pass NULL if you do not care to store an exception.
     @result true if the two values are equal, false if they are not equal or an exception is thrown.
     */
    JS_EXPORT bool __JSValueIsEqual(JSContextRef ctx, JSValueRef a, JSValueRef b, JSValueRef* exception);
    
    /*!
     @function
     @abstract       Tests whether two JavaScript values are strict equal, as compared by the JS === operator.
     @param ctx  The execution context to use.
     @param a        The first value to test.
     @param b        The second value to test.
     @result         true if the two values are strict equal, otherwise false.
     */
    JS_EXPORT bool __JSValueIsStrictEqual(JSContextRef ctx, JSValueRef a, JSValueRef b);
    
    /*!
     @function
     @abstract Tests whether a JavaScript value is an object constructed by a given constructor, as compared by the JS instanceof operator.
     @param ctx The execution context to use.
     @param value The JSValue to test.
     @param constructor The constructor to test against.
     @param exception A pointer to a JSValueRef in which to store an exception, if any. Pass NULL if you do not care to store an exception.
     @result true if value is an object constructed by constructor, as compared by the JS instanceof operator, otherwise false.
     */
    JS_EXPORT bool __JSValueIsInstanceOfConstructor(JSContextRef ctx, JSValueRef value, JSObjectRef constructor, JSValueRef* exception);
    
    /* Creating values */
    
    /*!
     @function
     @abstract       Creates a JavaScript value of the undefined type.
     @param ctx  The execution context to use.
     @result         The unique undefined value.
     */
    JS_EXPORT JSValueRef __JSValueMakeUndefined(JSContextRef ctx);
    
    /*!
     @function
     @abstract       Creates a JavaScript value of the null type.
     @param ctx  The execution context to use.
     @result         The unique null value.
     */
    JS_EXPORT JSValueRef __JSValueMakeNull(JSContextRef ctx);
    
    /*!
     @function
     @abstract       Creates a JavaScript value of the boolean type.
     @param ctx  The execution context to use.
     @param boolean  The bool to assign to the newly created JSValue.
     @result         A JSValue of the boolean type, representing the value of boolean.
     */
    JS_EXPORT JSValueRef __JSValueMakeBoolean(JSContextRef ctx, bool boolean);
    
    /*!
     @function
     @abstract       Creates a JavaScript value of the number type.
     @param ctx  The execution context to use.
     @param number   The double to assign to the newly created JSValue.
     @result         A JSValue of the number type, representing the value of number.
     */
    JS_EXPORT JSValueRef __JSValueMakeNumber(JSContextRef ctx, double number);
    
    /*!
     @function
     @abstract       Creates a JavaScript value of the string type.
     @param ctx  The execution context to use.
     @param string   The JSString to assign to the newly created JSValue. The
     newly created JSValue retains string, and releases it upon garbage collection.
     @result         A JSValue of the string type, representing the value of string.
     */
    JS_EXPORT JSValueRef __JSValueMakeString(JSContextRef ctx, JSStringRef string);
    
    /* Converting to and from JSON formatted strings */
    
    /*!
     @function
     @abstract       Creates a JavaScript value from a JSON formatted string.
     @param ctx      The execution context to use.
     @param string   The JSString containing the JSON string to be parsed.
     @result         A JSValue containing the parsed value, or NULL if the input is invalid.
     */
    JS_EXPORT JSValueRef __JSValueMakeFromJSONString(JSContextRef ctx, JSStringRef string) AVAILABLE_AFTER_WEBKIT_VERSION_4_0;
    
    /*!
     @function
     @abstract       Creates a JavaScript string containing the JSON serialized representation of a JS value.
     @param ctx      The execution context to use.
     @param value    The value to serialize.
     @param indent   The number of spaces to indent when nesting.  If 0, the resulting JSON will not contains newlines.  The size of the indent is clamped to 10 spaces.
     @param exception A pointer to a JSValueRef in which to store an exception, if any. Pass NULL if you do not care to store an exception.
     @result         A JSString with the result of serialization, or NULL if an exception is thrown.
     */
    JS_EXPORT JSStringRef __JSValueCreateJSONString(JSContextRef ctx, JSValueRef value, unsigned indent, JSValueRef* exception) AVAILABLE_AFTER_WEBKIT_VERSION_4_0;
    
    /* Converting to primitive values */
    
    /*!
     @function
     @abstract       Converts a JavaScript value to boolean and returns the resulting boolean.
     @param ctx  The execution context to use.
     @param value    The JSValue to convert.
     @result         The boolean result of conversion.
     */
    JS_EXPORT bool __JSValueToBoolean(JSContextRef ctx, JSValueRef value);
    
    /*!
     @function
     @abstract       Converts a JavaScript value to number and returns the resulting number.
     @param ctx  The execution context to use.
     @param value    The JSValue to convert.
     @param exception A pointer to a JSValueRef in which to store an exception, if any. Pass NULL if you do not care to store an exception.
     @result         The numeric result of conversion, or NaN if an exception is thrown.
     */
    JS_EXPORT double __JSValueToNumber(JSContextRef ctx, JSValueRef value, JSValueRef* exception);
    
    /*!
     @function
     @abstract       Converts a JavaScript value to string and copies the result into a JavaScript string.
     @param ctx  The execution context to use.
     @param value    The JSValue to convert.
     @param exception A pointer to a JSValueRef in which to store an exception, if any. Pass NULL if you do not care to store an exception.
     @result         A JSString with the result of conversion, or NULL if an exception is thrown. Ownership follows the Create Rule.
     */
    JS_EXPORT JSStringRef __JSValueToStringCopy(JSContextRef ctx, JSValueRef value, JSValueRef* exception);
    
    JS_EXPORT CFStringRef __JSValueToCFStringCopy(JSContextRef ctx, JSValueRef value, JSValueRef* exception);
    JS_EXPORT CFStringRef __JSValueToCFStringNoCopy(JSContextRef ctx, JSValueRef value, JSValueRef* exception);
    
    /*!
     @function
     @abstract Converts a JavaScript value to object and returns the resulting object.
     @param ctx  The execution context to use.
     @param value    The JSValue to convert.
     @param exception A pointer to a JSValueRef in which to store an exception, if any. Pass NULL if you do not care to store an exception.
     @result         The JSObject result of conversion, or NULL if an exception is thrown.
     */
    JS_EXPORT JSObjectRef __JSValueToObject(JSContextRef ctx, JSValueRef value, JSValueRef* exception);
    
#ifdef __cplusplus
}
#endif

#endif /* FastJSValueRef_h */
