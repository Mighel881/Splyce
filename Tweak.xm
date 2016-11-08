#import "Interfaces.h"

@interface Splyce : NSObject <LAListener>
@end

@implementation Splyce

+ (void)load{
	@autoreleasepool{
		if (LASharedActivator.runningInsideSpringBoard) {
			Splyce *listener = [[self alloc] init];
			[LASharedActivator registerListener:listener forName:@"com.shade.splyce"];
		}
		Boolean exists = false;
		CFPreferencesGetAppBooleanValue(CFSTR("SCAppEnabled-com.apple.mobilemail"), CFSTR("com.shade.splyce"), &exists);
		if (!exists) {
			CFPreferencesSetAppValue(CFSTR("SCAppEnabled-com.apple.mobilemail"), kCFBooleanTrue, CFSTR("com.shade.splyce"));
			CFPreferencesAppSynchronize(CFSTR("com.shade.splyce"));
		}
	}
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event{
	event.handled = YES;
	dispatch_async(dispatch_get_main_queue(), ^{
		CFPreferencesAppSynchronize(CFSTR("com.shade.splyce"));
		// UnFinished Clear Switcher 
		/* SBAppSwitcherModel *model = (SBAppSwitcherModel *)[%c(SBAppSwitcherModel) sharedInstance];
		NSArray *identifiers = [model respondsToSelector:@selector(identifiers)] ? model.identifiers : model.snapshot;
		if ([identifiers count]) {
			Boolean exists = false;
			Boolean clearSwitcher = CFPreferencesGetAppBooleanValue(CFSTR("SCClearSwitcher"), CFSTR("com.shade.splyce"), &exists);
			if (!exists || clearSwitcher) {
				if ([model respondsToSelector:@selector(appsRemoved:added:)]) {
					[model appsRemoved:[NSArray arrayWithArray:identifiers] added:nil];
				} else {
					for (NSString *displayIdentifier in identifiers) {
						[model remove:displayIdentifier];
					}
				}
			}
		}
		SBUIController *uic = (SBUIController *)[%c(SBUIController) sharedInstance];
		[uic dismissSwitcherAnimated:YES]; */
		FBApplicationProcess *currentProcess = [(SpringBoard*)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
		for (FBApplicationProcess *process in [(FBProcessManager *)[%c(FBProcessManager) sharedInstance] allApplicationProcesses]) {
			if (!process.nowPlayingWithAudio && !process.recordingAudio && (process != currentProcess)) {
				BKSProcess *bkProcess = MSHookIvar<BKSProcess*>(process, "_bksProcess");
				if (bkProcess) {
					[process processWillExpire:bkProcess];
				}
			}
		}
	});
}

@end