//
//  GBLog.m
//  appledoc
//
//  Created by Tomaz Kragelj on 22.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBLog.h"

#pragma mark Log level handling

int kGBLogLevel = LOG_LEVEL_NORMAL;
int kGBLogBasedResult = GBEXIT_SUCCESS;

void GBLogUpdateResult(int result) {
	// This code relies on exit codes being larger for more serious errors.
	if (result > kGBLogBasedResult) kGBLogBasedResult = result;
}

@implementation GBLog

+ (void)setLogLevel:(int)value {
	kGBLogLevel = value;
}

+ (void)setLogLevelFromVerbose:(NSString *)verbosity {
	NSInteger value = [verbosity integerValue];
	if (value < 0) value = 0;
	if (value > 6) value = 6;
	switch (value) {
		case 0:
			[self setLogLevel:LOG_LEVEL_FATAL];
			break;
		case 1:
			[self setLogLevel:LOG_LEVEL_ERROR];
			break;
		case 2:
			[self setLogLevel:LOG_LEVEL_WARN];
			break;
		case 3:
			[self setLogLevel:LOG_LEVEL_NORMAL];
			break;
		case 4:
			[self setLogLevel:LOG_LEVEL_INFO];
			break;
		case 5:
			[self setLogLevel:LOG_LEVEL_VERBOSE];
			break;
		case 6:
			[self setLogLevel:LOG_LEVEL_DEBUG];
			break;
	}
}

+ (id<DDLogFormatter>)logFormatterForLogFormat:(NSString *)level {
	if ([level isKindOfClass:[NSString class]]) {
		level = [level lowercaseString];
		if ([level isEqualToString:@"xcode"]) return [[GBLogFormatXcodeFormatter alloc] init];
	}
	
	NSInteger value = [level integerValue];
	if (value < 0) value = 0;
	if (value > 3) value = 3;
	switch (value) {
		case 0: return [[GBLogFormat0Formatter alloc] init];
		case 1: return [[GBLogFormat1Formatter alloc] init];
		case 2: return [[GBLogFormat2Formatter alloc] init];
		case 3: return [[GBLogFormat3Formatter alloc] init];
	}
	return nil;
}

@end

#pragma mark Custom loggers

@implementation GBConsoleLogger

static GBConsoleLogger *sharedConsoleLogger;

+ (void)initialize {
	static BOOL initialized = NO;
	if (!initialized) {
		initialized = YES;		
		sharedConsoleLogger = [[GBConsoleLogger alloc] init];
	}
}

+ (GBConsoleLogger *)sharedInstance {
	return sharedConsoleLogger;
}

- (void)logMessage:(DDLogMessage *)logMessage {
	// Note that we asume formatter is always attached - this is not a generic logger, so this will work for our case! It should still work in case log message is nil by doing nothing...
	NSString *logMsg = logMessage->logMsg;
	if (formatter) logMsg = [formatter formatLogMessage:logMessage];	
	if (logMsg) {
		switch (logMessage->logFlag) {
			case LOG_FLAG_FATAL:
			case LOG_FLAG_ERROR:
			case LOG_FLAG_WARN:
				ddfprintf(stderr, @"%@\n", logMsg);
				break;
			default:
				ddfprintf(stdout, @"%@\n", logMsg);
				break;
		}
	}
}

- (NSString *)loggerName {
	return @"cocoa.lumberjack.gbconsolelogger";
}

@end

#pragma mark Log formatting handling

static NSString *GBLogLevel(DDLogMessage *msg) {
	switch (msg->logFlag) {
		case LOG_FLAG_FATAL:	return @"FATAL";
		case LOG_FLAG_ERROR:	return @"ERROR";
		case LOG_FLAG_WARN:		return @"WARN";
		case LOG_FLAG_NORMAL:	return @"NORMAL";
		case LOG_FLAG_INFO:		return @"INFO";
		case LOG_FLAG_VERBOSE:	return @"VERBOSE";
		case LOG_FLAG_DEBUG:	return @"DEBUG";
	}
	return @"UNKNOWN";
}

@implementation GBLogFormat0Formatter
- (NSString *)formatLogMessage:(DDLogMessage *)m {
	return [NSString stringWithFormat:@"%@", m->logMsg];
}
@end

@implementation GBLogFormat1Formatter
- (NSString *)formatLogMessage:(DDLogMessage *)m {
	return [NSString stringWithFormat:@"%@ | %@", GBLogLevel(m), m->logMsg];
}
@end

@implementation GBLogFormat2Formatter
- (NSString *)formatLogMessage:(DDLogMessage *)m {
	return [NSString stringWithFormat:@"%@ | %s > %@", GBLogLevel(m), m->function, m->logMsg];
}
@end

@implementation GBLogFormat3Formatter
- (NSString *)formatLogMessage:(DDLogMessage *)m {
	return [NSString stringWithFormat:@"%@ | %s ln %i > %@", GBLogLevel(m), m->file, m->lineNumber, m->logMsg];
}
@end

@implementation GBLogFormatXcodeFormatter
- (NSString *)formatLogMessage:(DDLogMessage *)m {
	if (m->file) {
		NSString *level = nil;
		switch (m->logFlag) {
			case LOG_FLAG_FATAL:	level = @"fatal"; break;
			case LOG_FLAG_ERROR:	level = @"error"; break;
			case LOG_FLAG_WARN:		level = @"warning"; break;
			case LOG_FLAG_NORMAL:	level = @"normal"; break;
			case LOG_FLAG_INFO:		level = @"info"; break;
			case LOG_FLAG_VERBOSE:	level = @"verbose"; break;
			case LOG_FLAG_DEBUG:	level = @"debug"; break;
			default:				level = @"unknown"; break;
		}
		return [NSString stringWithFormat:@"%s:%d: %@: %@", m->file, m->lineNumber, level, m->logMsg];
	}
	return m->logMsg;
}
@end
