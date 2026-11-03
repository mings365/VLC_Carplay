/*****************************************************************************
 * VLCCarPlayProbeDiagnostics.h
 * VLC for iOS
 *****************************************************************************
 * Copyright (c) 2026 VLC CarPlay contributors
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

#import <Foundation/Foundation.h>

static inline void VLCCarPlayProbeRecord(NSString *event)
{
    NSString *line = [NSString stringWithFormat:@"%@ %@", [[NSISO8601DateFormatter new] stringFromDate:[NSDate date]], event];
    NSLog(@"%@", line);

    NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    if (!documents) {
        return;
    }

    NSString *path = [documents stringByAppendingPathComponent:@"CarPlayProbe.log"];
    NSString *previous = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] ?: @"";
    if (previous.length > 16384) {
        previous = [previous substringFromIndex:previous.length - 16384];
    }
    NSString *updated = [previous stringByAppendingFormat:@"%@\n", line];
    [updated writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
