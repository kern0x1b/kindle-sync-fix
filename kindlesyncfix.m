#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static IMP orig_setValue;

static void fixed_setValue(id self, SEL _cmd, NSString *value, NSString *field) {
    if ([field caseInsensitiveCompare:@"Expect"] == NSOrderedSame
        && (value == nil || [value length] == 0))
        return;
    ((void (*)(id, SEL, NSString *, NSString *))orig_setValue)(self, _cmd, value, field);
}

__attribute__((constructor))
static void kindlesyncfix_init(void) {
    Method m = class_getInstanceMethod(objc_getClass("NSMutableURLRequest"),
                                       @selector(setValue:forHTTPHeaderField:));
    if (!m)
        return;
    orig_setValue = method_getImplementation(m);
    method_setImplementation(m, (IMP)fixed_setValue);
}
