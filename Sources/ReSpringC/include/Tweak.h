#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import <RemoteLog.h>
#import <spawn.h>

//MARK: - Hooking Classes
@interface SBBacklightController : NSObject
-(BOOL)screenIsOn;
@end

@interface CSCoverSheetViewController : UIViewController
@end

@interface _UIStatusBar : UIView
-(id)initWithStyle:(long long)arg1;
@end

@interface SBStatusBarStateAggregator : NSObject
-(void)_updateLocationItem;
@end

@interface _UIStatusBarItem : NSObject
@end

@interface _UIStatusBarStringView : UILabel
@end

@interface _UIStatusBarCellularItem : _UIStatusBarItem
-(_UIStatusBarStringView *)serviceNameView;
@end

@interface _UIStatusBarTimeItem : _UIStatusBarItem
-(_UIStatusBarStringView *)shortTimeView;
@end

@interface _UIStatusBarPillView : UIView
-(void)layoutSubviews;
@end

// Creates a Secure Window which is able to show on Lockscreen (if Passcode is set)
@interface UIWindow (RespringWindow)
-(BOOL)_shouldCreateContextAsSecure;
@end

// Shows the Secure Created Window also on Lockscreen (thanks to: @ichitaso)
@interface UIViewController (TapToRespringViewController)
-(BOOL)_canShowWhileLocked;
@end

//MARK: - Functions
// Changed from NSTask to posix_spawn
// Thanks to @Nightwind for his respring method (changed from "sbreload" to "killall SpringBoard")
void respringDevice() {
    extern char **environ;
    const char *args[] = {"killall", "SpringBoard", NULL};
    pid_t pid;

    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:@"/var/Liy/.procursus_strapped"] || [fileManager fileExistsAtPath:@"/var/jb/.procursus_strapped"]) {
        posix_spawn(&pid, "/var/jb/usr/bin/killall", NULL, NULL, (char *const *)args, environ);
        return;
    }

    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char *const *)args, environ);
}
