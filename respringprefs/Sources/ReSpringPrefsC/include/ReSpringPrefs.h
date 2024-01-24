#import <UIKit/UIKit.h>
#import <RemoteLog.h>
#import <spawn.h>

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
