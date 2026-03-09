#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import "HAAutoLayout.h"

/// Developer toggle: intercept Auto Layout operations that originate from
/// our app code (not UIKit internals) when HAForceDisableAutoLayout is on.
///
/// Strategy: check the caller's return address. If it's in our app binary,
/// suppress the operation. If it's in a system framework, let it through.
/// This preserves UIKit's own internal Auto Layout (nav bars, keyboards, etc.)
/// while disabling our app's constraint setup.

static void *sAppTextStart = NULL;
static void *sAppTextEnd = NULL;

static void HAFindAppTextRange(void) {
    Dl_info info;
    // Use our own function to find our binary's load address
    if (dladdr((void *)HAFindAppTextRange, &info)) {
        // The app binary's __TEXT segment starts at dli_fbase
        sAppTextStart = info.dli_fbase;
        // Estimate end — 20MB should cover any app binary
        sAppTextEnd = (void *)((uintptr_t)sAppTextStart + 20 * 1024 * 1024);
    }
}

static BOOL HACallerIsApp(void) {
    // Walk up the call stack: our swizzle (0) -> objc_msgSend (1) -> caller (2)
    void *ret = __builtin_return_address(1);
    return (ret >= sAppTextStart && ret < sAppTextEnd);
}

static void (*sOrigSetTranslates)(id, SEL, BOOL);
static void (*sOrigAddConstraint)(id, SEL, id);
static void (*sOrigAddConstraints)(id, SEL, id);
static void (*sOrigRemoveConstraint)(id, SEL, id);
static void (*sOrigRemoveConstraints)(id, SEL, id);
static void (*sOrigSetActive)(id, SEL, BOOL);
static void (*sOrigActivate)(id, SEL, id);
static void (*sOrigDeactivate)(id, SEL, id);

static void HASwizzledSetTranslates(id self, SEL _cmd, BOOL val) {
    if (!val && HACallerIsApp()) return;
    sOrigSetTranslates(self, _cmd, val);
}

static void HASwizzledAddConstraint(id self, SEL _cmd, id c) {
    if (HACallerIsApp()) return;
    sOrigAddConstraint(self, _cmd, c);
}

static void HASwizzledAddConstraints(id self, SEL _cmd, id c) {
    if (HACallerIsApp()) return;
    sOrigAddConstraints(self, _cmd, c);
}

static void HASwizzledRemoveConstraint(id self, SEL _cmd, id c) {
    if (HACallerIsApp()) return;
    sOrigRemoveConstraint(self, _cmd, c);
}

static void HASwizzledRemoveConstraints(id self, SEL _cmd, id c) {
    if (HACallerIsApp()) return;
    sOrigRemoveConstraints(self, _cmd, c);
}

static void HASwizzledSetActive(id self, SEL _cmd, BOOL active) {
    if (HACallerIsApp()) return;
    sOrigSetActive(self, _cmd, active);
}

static void HASwizzledActivate(id self, SEL _cmd, id c) {
    if (HACallerIsApp()) return;
    sOrigActivate(self, _cmd, c);
}

static void HASwizzledDeactivate(id self, SEL _cmd, id c) {
    if (HACallerIsApp()) return;
    sOrigDeactivate(self, _cmd, c);
}

static void HASwizzleInstance(Class cls, SEL sel, IMP newImp, IMP *origOut) {
    Method m = class_getInstanceMethod(cls, sel);
    if (!m) return;
    *origOut = method_getImplementation(m);
    method_setImplementation(m, newImp);
}

static void HASwizzleClass(Class cls, SEL sel, IMP newImp, IMP *origOut) {
    Method m = class_getClassMethod(cls, sel);
    if (!m) return;
    *origOut = method_getImplementation(m);
    method_setImplementation(m, newImp);
}

__attribute__((constructor))
static void HAAutoLayoutSwizzleInstall(void) {
    if (!HAForceDisableAutoLayout()) return;

    HAFindAppTextRange();
    if (!sAppTextStart) return;

    Class uiview = [UIView class];
    HASwizzleInstance(uiview, @selector(setTranslatesAutoresizingMaskIntoConstraints:),
                      (IMP)HASwizzledSetTranslates, (IMP *)&sOrigSetTranslates);
    HASwizzleInstance(uiview, @selector(addConstraint:),
                      (IMP)HASwizzledAddConstraint, (IMP *)&sOrigAddConstraint);
    HASwizzleInstance(uiview, @selector(addConstraints:),
                      (IMP)HASwizzledAddConstraints, (IMP *)&sOrigAddConstraints);
    HASwizzleInstance(uiview, @selector(removeConstraint:),
                      (IMP)HASwizzledRemoveConstraint, (IMP *)&sOrigRemoveConstraint);
    HASwizzleInstance(uiview, @selector(removeConstraints:),
                      (IMP)HASwizzledRemoveConstraints, (IMP *)&sOrigRemoveConstraints);

    Class nslc = NSClassFromString(@"NSLayoutConstraint");
    if (nslc) {
        HASwizzleInstance(nslc, @selector(setActive:),
                          (IMP)HASwizzledSetActive, (IMP *)&sOrigSetActive);
        HASwizzleClass(nslc, @selector(activateConstraints:),
                       (IMP)HASwizzledActivate, (IMP *)&sOrigActivate);
        HASwizzleClass(nslc, @selector(deactivateConstraints:),
                       (IMP)HASwizzledDeactivate, (IMP *)&sOrigDeactivate);
    }
}
