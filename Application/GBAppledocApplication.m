//
//  GBAppledocApplication.m
//  appledoc
//
//  Created by Tomaz Kragelj on 22.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "timing.h"
#import "DDCliUtil.h"
#import "DDGetoptLongParser.h"
#import "GBStore.h"
#import "GBParser.h"
#import "GBProcessor.h"
#import "GBGenerator.h"
#import "GBApplicationSettingsProvider.h"
#import "GBAppledocApplication.h"
#import "DDXcodeProjectFile.h"
#import "DDEmbeddedDataReader.h"
#import "DDZipReader.h"

#define DECL_PARAM(name, long, short) \
static const DDGetoptOption name = { long, short, DDGetoptRequiredArgument }
#define DECL_X_PARAM(name, long) \
static const DDGetoptOption name = { long, 0, DDGetoptRequiredArgument }
#define DECL_FLAG(name, long, short) \
static const DDGetoptOption name = { long, short, DDGetoptNoArgument }
#define DECL_X_FLAG(name, long) \
static const DDGetoptOption name = { long, 0, DDGetoptNoArgument }

DECL_X_PARAM(GBArgInputPath, 	"input");
DECL_PARAM(GBArgOutputPath,		"output",		'o');
DECL_PARAM(GBArgTemplatesPath,	"templates",	't');
DECL_PARAM(GBArgIgnorePath,		"ignore",		'i');

DECL_PARAM(GBArgExcludeOutputPath,		"exclude-output",	'x');
DECL_PARAM(GBArgIncludePath,				"include",			's');
DECL_X_PARAM(GBArgIndexDescPath,			"index-desc");
DECL_X_PARAM(GBArgDocSetInstallPath,		"docset-install-path");
DECL_X_PARAM(GBArgXcrunPath,				"xcrun-path");

DECL_PARAM(GBArgProjectName,				"project-name",		'p');
DECL_PARAM(GBArgProjectVersion,			"project-version",	'v');
DECL_PARAM(GBArgProjectCompany,			"project-company",	'c');
DECL_X_PARAM(GBArgCompanyIdentifier,		"company-id");

DECL_X_PARAM(GBArgDocSetBundleIdentifier,		"docset-bundle-id");
DECL_X_PARAM(GBArgDocSetBundleName,				"docset-bundle-name");
DECL_X_PARAM(GBArgDocSetCertificateIssuer,		"docset-cert-issuer");
DECL_X_PARAM(GBArgDocSetCertificateSigner,		"docset-cert-signer");
DECL_X_PARAM(GBArgDocSetDescription,				"docset-desc");
DECL_X_PARAM(GBArgDocSetFallbackURL,				"docset-fallback-url");
DECL_X_PARAM(GBArgDocSetFeedName,				"docset-feed-name");
DECL_X_PARAM(GBArgDocSetFeedURL,					"docset-feed-url");
DECL_X_PARAM(GBArgDocSetFeedFormats,				"docset-feed-formats");
DECL_X_PARAM(GBArgDocSetPackageURL,				"docset-package-url");
DECL_X_PARAM(GBArgDocSetMinimumXcodeVersion,	"docset-min-xcode-version");
DECL_X_PARAM(GBArgDocSetPlatformFamily,			"docset-platform-family");
DECL_X_PARAM(GBArgDocSetPublisherIdentifier,	"docset-publisher-id");
DECL_X_PARAM(GBArgDocSetPublisherName,			"docset-publisher-name");
DECL_X_PARAM(GBArgDocSetCopyrightMessage,		"docset-copyright");
DECL_X_PARAM(GBArgDashPlatformFamily,			"dash-platform-family");

DECL_X_PARAM(GBArgDocSetBundleFilename,			"docset-bundle-filename");
DECL_X_PARAM(GBArgDocSetAtomFilename,			"docset-atom-filename");
DECL_X_PARAM(GBArgDocSetXMLFilename,				"docset-xml-filename");
DECL_X_PARAM(GBArgDocSetPackageFilename,			"docset-package-filename");

DECL_X_FLAG(GBArgCleanOutput,		"clean-output");
DECL_FLAG(GBArgCreateHTML,			"create-html",		'h');
DECL_FLAG(GBArgCreateDocSet,			"create-docset",	'd');
DECL_X_FLAG(GBArgFinalizeDocSet,		"finalize-docset");
DECL_FLAG(GBArgInstallDocSet,		"install-docset",	'n');
DECL_FLAG(GBArgPublishDocSet,		"publish-docset",	'u');
DECL_X_PARAM(GBArgHTMLAnchorFormat, "html-anchors");
DECL_X_FLAG(GBArgNoCreateHTML,		"no-create-html");
DECL_X_FLAG(GBArgNoCreateDocSet,		"no-create-docset");
DECL_X_FLAG(GBArgNoInstallDocSet,	"no-install-docset");
DECL_X_FLAG(GBArgNoPublishDocSet,	"no-publish-docset");

DECL_X_PARAM(GBArgCrossRefFormat,		"crossref-format");
DECL_X_FLAG(GBArgExplicitCrossRef,		"explicit-crossref");
DECL_X_FLAG(GBArgNoExplicitCrossRef,		"no-explicit-crossref");

DECL_X_FLAG(GBArgKeepIntermediateFiles,				"keep-intermediate-files");
DECL_X_FLAG(GBArgKeepUndocumentedObjects,			"keep-undocumented-objects");
DECL_X_FLAG(GBArgKeepUndocumentedMembers,			"keep-undocumented-members");
DECL_X_FLAG(GBArgFindUndocumentedMembers,			"search-undocumented-doc");
DECL_X_FLAG(GBArgRepeatFirstParagraph,				"repeat-first-par");
DECL_X_FLAG(GBArgPreprocessHeaderDoc,				"preprocess-headerdoc");
DECL_X_FLAG(GBArgPrintInformationBlockTitles,		"print-information-block-titles");
DECL_X_FLAG(GBArgNoPrintInformationBlockTitles,		"no-print-information-block-titles");
DECL_X_FLAG(GBArgUseSingleStar,						"use-single-star");
DECL_X_FLAG(GBArgMergeCategoriesToClasses,			"merge-categories");
DECL_X_FLAG(GBArgMergeCategoryComment,				"merge-category-comment");
DECL_X_FLAG(GBArgKeepMergedCategoriesSections,		"keep-merged-sections");
DECL_X_FLAG(GBArgPrefixMergedCategoriesSections,	"prefix-merged-sections");
DECL_X_FLAG(GBArgUseCodeOrder,						"use-code-order");
DECL_X_PARAM(GBArgExitCodeThreshold,					"exit-threshold");
DECL_X_FLAG(GBArgNoKeepIntermediateFiles,			"no-keep-intermediate-files");
DECL_X_FLAG(GBArgNoKeepUndocumentedObjects,			"no-keep-undocumented-objects");
DECL_X_FLAG(GBArgNoKeepUndocumentedMembers,			"no-keep-undocumented-members");
DECL_X_FLAG(GBArgNoFindUndocumentedMembers,			"no-search-undocumented-doc");
DECL_X_FLAG(GBArgNoRepeatFirstParagraph,				"no-repeat-first-par");
DECL_X_FLAG(GBArgNoMergeCategoriesToClasses,		"no-merge-categories");
DECL_X_FLAG(GBArgNoMergeCategoryComment,				"no-merge-category-comment");
DECL_X_FLAG(GBArgNoKeepMergedCategoriesSections,	"no-keep-merged-sections");
DECL_X_FLAG(GBArgNoPrefixMergedCategoriesSections,	"no-prefix-merged-sections");
DECL_X_FLAG(GBArgNoUseCodeOrder,						"no-use-code-order");

DECL_X_FLAG(GBArgWarnOnMissingOutputPath,			"warn-missing-output-path");
DECL_X_FLAG(GBArgWarnOnMissingCompanyIdentifier,	"warn-missing-company-id");
DECL_X_FLAG(GBArgWarnOnUndocumentedObject,			"warn-undocumented-object");
DECL_X_FLAG(GBArgWarnOnUndocumentedMember,			"warn-undocumented-member");
DECL_X_FLAG(GBArgWarnOnEmptyDescription,			"warn-empty-description");
DECL_X_FLAG(GBArgWarnOnUnknownDirective,			"warn-unknown-directive");
DECL_X_FLAG(GBArgWarnOnInvalidCrossReference,		"warn-invalid-crossref");
DECL_X_FLAG(GBArgWarnOnMissingMethodArgument,		"warn-missing-arg");
DECL_X_FLAG(GBArgNoWarnOnMissingOutputPath,			"no-warn-missing-output-path");
DECL_X_FLAG(GBArgNoWarnOnMissingCompanyIdentifier,	"no-warn-missing-company-id");
DECL_X_FLAG(GBArgNoWarnOnUndocumentedObject,		"no-warn-undocumented-object");
DECL_X_FLAG(GBArgNoWarnOnUndocumentedMember,		"no-warn-undocumented-member");
DECL_X_FLAG(GBArgNoWarnOnEmptyDescription,			"no-warn-empty-description");
DECL_X_FLAG(GBArgNoWarnOnUnknownDirective,			"no-warn-unknown-directive");
DECL_X_FLAG(GBArgNoWarnOnInvalidCrossReference,		"no-warn-invalid-crossref");
DECL_X_FLAG(GBArgNoWarnOnMissingMethodArgument,		"no-warn-missing-arg");

DECL_X_PARAM(GBArgLogFormat,		"logformat");
DECL_X_PARAM(GBArgVerbose,		"verbose");
DECL_X_FLAG(GBArgPrintSettings,	"print-settings");
DECL_X_FLAG(GBArgVersion,		"version");
DECL_X_FLAG(GBArgHelp,			"help");

#pragma mark -

static inline BOOL GBStringIsLongOption(NSString *string, DDGetoptOption opt) {
	return (strcmp(string.UTF8String, opt.longOption) == 0);
}

static inline BOOL GBStringIsShortOption(NSString *string, DDGetoptOption opt) {
	return [string isEqual:[NSString stringWithFormat:@"%c", (char)opt.shortOption]];
}

static inline NSString *GBOptionFlag(DDGetoptOption opt) {
	return [NSString stringWithFormat:@"--%s", opt.longOption];
}

#pragma mark - Private declaration, FIXME

@interface DDGetoptLongParser ()

- (NSString *)optionToKey:(NSString *)option;

@end

#pragma mark -

@interface GBAppledocApplication ()

- (void)initializeLoggingSystem;
- (void)deleteContentsOfOutputPath;
- (void)validateSettingsAndArguments:(NSArray *)arguments;
- (NSString *)standardizeCurrentDirectoryForPath:(NSString *)path;
- (NSString *)combineBasePath:(NSString *)base withRelativePath:(NSString *)path;

- (void)injectXcodeSettingsFromArguments:(NSArray *)arguments;
- (void)injectGlobalSettingsFromArguments:(NSArray *)arguments parser:(DDGetoptLongParser *)parser;
- (void)injectProjectSettingsFromArguments:(NSArray *)arguments parser:(DDGetoptLongParser *)parser;
- (void)overrideSettingsWithGlobalSettingsFromPath:(NSString *)path parser:(DDGetoptLongParser *)parser;
- (void)injectSettingsFromSettingsFile:(NSString *)path parser:(DDGetoptLongParser *)parser usingBlock:(BOOL (^)(NSString *option, id *value, BOOL *stop))block;
- (BOOL)validateTemplatesPath:(NSString *)path error:(NSError **)error;

@property (readwrite, strong) GBApplicationSettingsProvider *settings;
@property (strong) NSMutableArray *additionalInputPaths;
@property (strong) NSMutableArray *ignoredInputPaths;
@property (strong) NSString *logformat;
@property (strong) NSString *verbose;
@property (assign) BOOL templatesFound;
@property (assign) BOOL printSettings;
@property (assign) BOOL version;
@property (assign) BOOL help;

@end

#pragma mark -

@interface GBAppledocApplication (UsagePrintout)

- (void)printSettingsAndArguments:(NSArray *)arguments;
- (void)printVersion;
- (void)printHelp;
- (void)printHelpForShortOption:(int)shortOpt longOption:(const char *)longOpt argument:(NSString *)argument description:(NSString *)description;

@end

#pragma mark -

@implementation GBAppledocApplication

#pragma mark Initialization & disposal

- (id)init {
	self = [super init];
	if (self) {
		self.settings = [GBApplicationSettingsProvider provider];
		self.additionalInputPaths = [NSMutableArray array];
		self.ignoredInputPaths = [NSMutableArray array];
		self.templatesFound = NO;
		self.printSettings = NO;
		self.logformat = @"1";
		self.verbose = @"2";
	}
	return self;
}

#pragma mark DDCliApplicationDelegate implementation

- (int)application:(DDCliApplication *)app runWithArguments:(NSArray *)arguments {
	if (self.help) {
		[self printHelp];
		return GBEXIT_SUCCESS;
	}
	if (self.version) {
		[self printVersion];
		return GBEXIT_SUCCESS;
	}

	// Prepare actual input paths by adding all paths from project settings and removing all plist paths.
	NSMutableArray *inputs = [NSMutableArray array];
	[inputs addObjectsFromArray:arguments];
	[inputs addObjectsFromArray:self.additionalInputPaths];
	[inputs removeObjectsInArray:self.ignoredInputPaths];
	
	[self printVersion];
	[self validateSettingsAndArguments:inputs];
	[self.settings replaceAllOccurencesOfPlaceholderStringsInSettingsValues];
	if (self.printSettings) [self printSettingsAndArguments:inputs];
	kGBLogBasedResult = GBEXIT_SUCCESS;

	@try {
		[self initializeLoggingSystem];
		[self deleteContentsOfOutputPath];
		
		GBLogNormal(@"Initializing...");
		GBStore *store = [[GBStore alloc] init];
		GBAbsoluteTime startTime = GetCurrentTime();
		
		GBLogNormal(@"Parsing source files...");
		GBParser *parser = [GBParser parserWithSettingsProvider:self.settings];
		[parser parseObjectsFromPaths:inputs toStore:store];
		[parser parseDocumentsFromPaths:[self.settings.includePaths allObjects] toStore:store];
		[parser parseCustomDocumentFromPath:self.settings.indexDescriptionPath outputSubpath:@"" key:kGBCustomDocumentIndexDescKey toStore:store];
		GBAbsoluteTime parseTime = GetCurrentTime();
		NSUInteger timeForParsing = SubtractTime(parseTime, startTime) * 1000.0;
		GBLogInfo(@"Finished parsing in %ldms.\n", timeForParsing);
		
		GBLogNormal(@"Processing parsed data...");
		GBProcessor *processor = [GBProcessor processorWithSettingsProvider:self.settings];
		[processor processObjectsFromStore:store];
		GBAbsoluteTime processTime = GetCurrentTime();
		NSUInteger timeForProcessing = SubtractTime(processTime, parseTime) * 1000.0;
		GBLogInfo(@"Finished processing in %ldms.\n", timeForProcessing);
		
		GBLogNormal(@"Generating output...");
		GBGenerator *generator = [GBGenerator generatorWithSettingsProvider:self.settings];
		[generator generateOutputFromStore:store];
		GBAbsoluteTime generateTime = GetCurrentTime();
		NSUInteger timeForGeneration = SubtractTime(generateTime, processTime) * 1000.0;
		GBLogInfo(@"Finished generating in %ldms.\n", timeForGeneration);
		
		NSUInteger timeForEverything = timeForParsing + timeForProcessing + timeForGeneration;
		GBLogNormal(@"Finished in %ldms.", timeForEverything);
		GBLogInfo(@"Parsing:    %ldms (%ld%%)", timeForParsing, timeForParsing * 100 / timeForEverything);
		GBLogInfo(@"Processing: %ldms (%ld%%)", timeForProcessing, timeForProcessing * 100 / timeForEverything);
		GBLogInfo(@"Generating: %ldms (%ld%%)", timeForGeneration, timeForGeneration * 100 / timeForEverything);
	}
	@catch (NSException *e) {
		GBLogException(e, @"Oops, something went wrong...");
		return GBEXIT_ASSERT_GENERIC;
	}
	
	int result = (kGBLogBasedResult >= self.settings.exitCodeThreshold) ? kGBLogBasedResult : 0;
	GBLogDebug(@"Exiting with result %d (reported result was %ld)...", result, kGBLogBasedResult);
	return result;
}

- (void)application:(DDCliApplication *)app willParseOptions:(DDGetoptLongParser *)optionParser {
	DDGetoptOption options[] = {
		GBArgOutputPath, GBArgTemplatesPath, GBArgIgnorePath,

		GBArgExcludeOutputPath, GBArgIncludePath, GBArgIndexDescPath,
		GBArgDocSetInstallPath, GBArgXcrunPath,

		GBArgProjectName, GBArgProjectVersion, GBArgProjectCompany,
		GBArgCompanyIdentifier,
		
		GBArgDocSetBundleIdentifier, GBArgDocSetBundleName,
		GBArgDocSetCertificateIssuer, GBArgDocSetCertificateSigner,
		GBArgDocSetDescription, GBArgDocSetFallbackURL, GBArgDocSetFeedName,
		GBArgDocSetFeedURL, GBArgDocSetFeedFormats, GBArgDocSetPackageURL,
		GBArgDocSetMinimumXcodeVersion, GBArgDocSetPlatformFamily,
		GBArgDocSetPublisherIdentifier, GBArgDocSetPublisherName,
		GBArgDocSetCopyrightMessage, GBArgDashPlatformFamily,
		
		GBArgDocSetBundleFilename, GBArgDocSetAtomFilename,
		GBArgDocSetXMLFilename, GBArgDocSetPackageFilename,
		
		GBArgCleanOutput, GBArgCreateHTML, GBArgCreateDocSet,
		GBArgFinalizeDocSet, GBArgInstallDocSet, GBArgPublishDocSet,
		GBArgHTMLAnchorFormat, GBArgNoCreateHTML, GBArgNoCreateDocSet,
		GBArgNoInstallDocSet, GBArgNoPublishDocSet,

		GBArgCrossRefFormat, GBArgExplicitCrossRef, GBArgNoExplicitCrossRef,

		GBArgKeepIntermediateFiles, GBArgKeepUndocumentedObjects,
		GBArgKeepUndocumentedMembers, GBArgFindUndocumentedMembers,
		GBArgRepeatFirstParagraph, GBArgPreprocessHeaderDoc,
		GBArgPrintInformationBlockTitles, GBArgNoPrintInformationBlockTitles,
		GBArgUseSingleStar, GBArgMergeCategoriesToClasses,
		GBArgMergeCategoryComment, GBArgKeepMergedCategoriesSections,
		GBArgPrefixMergedCategoriesSections, GBArgUseCodeOrder,
		GBArgExitCodeThreshold,  GBArgNoKeepIntermediateFiles,
		GBArgNoKeepUndocumentedObjects, GBArgNoKeepUndocumentedMembers,
		GBArgNoFindUndocumentedMembers,
		GBArgNoRepeatFirstParagraph, GBArgNoMergeCategoriesToClasses,
		GBArgNoMergeCategoryComment, GBArgNoKeepMergedCategoriesSections,
		GBArgNoPrefixMergedCategoriesSections, GBArgNoUseCodeOrder,

		GBArgWarnOnMissingOutputPath, GBArgWarnOnMissingCompanyIdentifier,
		GBArgWarnOnUndocumentedObject, GBArgWarnOnUndocumentedMember,
		GBArgWarnOnEmptyDescription, GBArgWarnOnUnknownDirective,
		GBArgWarnOnInvalidCrossReference, GBArgWarnOnMissingMethodArgument,
		GBArgNoWarnOnMissingOutputPath, GBArgNoWarnOnMissingCompanyIdentifier,
		GBArgNoWarnOnUndocumentedObject, GBArgNoWarnOnUndocumentedMember,
		GBArgNoWarnOnEmptyDescription, GBArgNoWarnOnUnknownDirective,
		GBArgNoWarnOnInvalidCrossReference, GBArgNoWarnOnMissingMethodArgument,

		GBArgLogFormat, GBArgVerbose, GBArgPrintSettings, GBArgVersion,
		GBArgHelp,

		DDGetoptOptionNull
	};
	NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    [self injectXcodeSettingsFromArguments:arguments];
	[self injectGlobalSettingsFromArguments:arguments parser:optionParser];
	[self injectProjectSettingsFromArguments:arguments parser:optionParser];
	[optionParser addOptionsFromTable:options];
}

#pragma mark Application handling

- (void)initializeLoggingSystem {
	id formatter = [GBLog logFormatterForLogFormat:self.logformat];
	[[GBConsoleLogger sharedInstance] setLogFormatter:formatter];
	[DDLog addLogger:[GBConsoleLogger sharedInstance]];
	[GBLog setLogLevelFromVerbose:self.verbose];
}

- (void)deleteContentsOfOutputPath {
	// Removes all files from output path to have a clean start. Although this is not necessary from functionality point of view, it makes the tool less confusing as output only contains files generated by this run. This is sent after initializing logging system, so we can use logging. Note that in case cleanup fails, we simply warn and continue; it the rest of the steps succeed, we can leave everything.
	if (!self.settings.cleanupOutputPathBeforeRunning) return;
	
	NSString *outputPath = self.settings.outputPath;
	NSString *standardizedOutput = [outputPath stringByStandardizingPath];
	NSError *error = nil;
	
	GBLogInfo(@"Deleting contents of output path '%@'...", outputPath);
	NSArray *contents = [self.fileManager contentsOfDirectoryAtPath:standardizedOutput error:&error];
	if (error) {
		GBLogNSError(error, @"Failed enumerating contents of output path '%@'!, for cleaning up!", outputPath);
		return;
	}
	
	for (NSString *subpath in contents) {
		GBLogDebug(@"- Deleting '%@'...", subpath);
		NSString *filename = [standardizedOutput stringByAppendingPathComponent:subpath];
		if (![self.fileManager removeItemAtPath:filename error:&error] && error) {
			GBLogNSError(error, @"Failed removing '%@' while cleaning up output!", filename);
		}
	}
}

- (void)validateSettingsAndArguments:(NSArray *)arguments {
	// Validate we have valid templates path - we use the value of the templatesFound set within initializeGlobalSettingsAndValidateTemplates. We can't simply raise exception there because that message is sent before handling help or version; so we would be required to provide valid templates path even if we just wanted "appledoc --help". As this message is sent afterwards, we can raise exception here. Not as elegant, but needed.
	if (!self.templatesFound) {
		[NSException raise:@"No predefined templates path exists and no template path specified from command line!"];
	}
    
    if ([[NSScanner scannerWithString:self.verbose] scanInt:NULL] == false)
    {
        [NSException raise:@"%@ argument or global setting must be numeric!", GBOptionFlag(GBArgVerbose)];
    }
	
	// Validate we have at least one argument specifying the path to the files to handle. Also validate all given paths are valid.
	if ([arguments count] == 0) [NSException raise:@"At least one directory or file name path is required, use 'appledoc --help'"];
	for (NSString *path in arguments) {
		if (![self.fileManager fileExistsAtPath:[path stringByStandardizingPath]]) {
			[NSException raise:@"Path or file '%@' doesn't exist!", path];
		}
	}
	
	// Now validate we have all required settings specified.
	if ([self.settings.projectName length] == 0) [NSException raise:@"%@ argument or global setting is required!", GBOptionFlag(GBArgProjectName)];
	if ([self.settings.projectCompany length] == 0) [NSException raise:@"%@ argument or global setting is required!", GBOptionFlag(GBArgProjectCompany)];
	
	// If output path is not given, revert to current path, but do warn the user.
	if ([self.settings.outputPath length] == 0) {
		self.settings.cleanupOutputPathBeforeRunning = NO;
		self.settings.outputPath = [self.fileManager currentDirectoryPath];
		if (self.settings.warnOnMissingOutputPathArgument) {
			ddprintf(@"WARN: %@ argument or global setting not given, will output to current dir '%@'!\n", GBOptionFlag(GBArgOutputPath), self.settings.outputPath);
		}
	}
	
	// If company identifier is not given and we have docset enabled, prepare one from company name, but do warn the user.
	if (self.settings.createDocSet && [self.settings.companyIdentifier length] == 0) {
		NSString *value = [NSString stringWithFormat:@"com.%@.%@", self.settings.projectCompany, self.settings.projectName];
		value = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
		value = [value lowercaseString];
		self.settings.companyIdentifier = value;
		if (self.settings.warnOnMissingCompanyIdentifier) {
			ddprintf(@"WARN: %@ argument or global setting not given, but creating DocSet is enabled, will use '%@'!\n", GBOptionFlag(GBArgCompanyIdentifier), self.settings.companyIdentifier);
		}
	}
	
	// If any of the include paths isn't valid, warn.
	[self.settings.includePaths enumerateObjectsUsingBlock:^(NSString *userPath, BOOL *stop) {
		NSString *path = [userPath stringByStandardizingPath];
		if (![self.fileManager fileExistsAtPath:path]) {
			ddprintf(@"WARN: %@ path '%@' doesn't exist, ignoring!\n", GBOptionFlag(GBArgIncludePath), userPath);
		}
	}];
	
	// If index description path is given but doesn't point to an existing file, warn.
	if ([self.settings.indexDescriptionPath length] > 0) {
		BOOL isDir;
		NSString *path = [self.settings.indexDescriptionPath stringByStandardizingPath];
		if (![self.fileManager fileExistsAtPath:path isDirectory:&isDir])
			ddprintf(@"WARN: %@ path '%@' doesn't exist, ignoring!\n", GBOptionFlag(GBArgIndexDescPath), self.settings.indexDescriptionPath);
		else if (isDir)
			ddprintf(@"WARN: %@ path '%@' is a directory, file is required, ignoring!\n", GBOptionFlag(GBArgIndexDescPath), self.settings.indexDescriptionPath);
	}
	
	// If we're using backwards compatibility mode, warn about potential incompatibility with Markdown!
	if (self.settings.useSingleStarForBold) {
		ddprintf(@"WARN: %@ may cause incompatibility with Markdown (* unordered lists etc.)", GBOptionFlag(GBArgUseSingleStar));
	}
}

- (BOOL)extractShippedTemplatesToPath:(NSString *)path {
    path = [path stringByExpandingTildeInPath];
    
    //read embedded data
    NSData *data = [DDEmbeddedDataReader embeddedDataFromSegment:@"__ZIP" inSection:@"__templates" error:nil];
    if(!data) {
        NSLog( @"Error: extractShippedTemplatesToPath called, but no data embeded" );
        return NO;
    }

    //get a path
    NSString *p = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
    
    //write the data
    BOOL br = [data writeToFile:p atomically:NO];
    if(!br) {
        NSLog( @"Error: extractShippedTemplatesToPath failed write data to tmp path %@", p );
        return NO;
    }
    
    //open the zip
    DDZipReader *reader = [[DDZipReader alloc] init];
    br = [reader openZipFile:p];
    if(!br) {
        NSLog( @"Error: extractShippedTemplatesToPath failed to open the zip at %@", p );
        return NO;
    }
    
    //extract
    br = [reader unzipFileTo:path flattenStructure:NO];
    if(!br) {
        NSLog( @"Error: extractShippedTemplatesToPath failed to unzip the zip from %@ TO %@", p, path );
        return NO;
    }
    
    //close and remove the temp
    [reader closeZipFile];
    br = [[NSFileManager defaultManager] removeItemAtPath:p error:nil];
    if(!br) {
        NSLog( @"Error: extractShippedTemplatesToPath failed to rm %@", p );
        return NO;
    }

    return YES;
}

- (BOOL)validateTemplatesPath:(NSString *)path error:(NSError **)error {
	// Validates the given templates path contains all required template files. If not, it returns the reason through the error argument and returns NO. Note that we only do simple "path exist and is directory" tests here, each object that requires templates at the given path will do it's own validation later on and will report errors if it finds something missing.
	BOOL isDirectory = NO;
	NSString *trimmed = [path stringByTrimmingWhitespaceAndNewLine];
	NSString *standardized = [[self standardizeCurrentDirectoryForPath:trimmed] stringByStandardizingPath];
	if (![self.fileManager fileExistsAtPath:standardized isDirectory:&isDirectory]) {
		if (error) {
			NSString *desc = [NSString stringWithFormat:@"Template path doesn't exist at '%@'!", standardized];
			*error = [NSError errorWithCode:GBErrorTemplatePathDoesntExist description:desc reason:nil];
		}
		return NO;
	}
	if (!isDirectory) {
		if (error) {
			NSString *desc = [NSString stringWithFormat:@"Template path '%@' is not directory!", standardized];
			*error = [NSError errorWithCode:GBErrorTemplatePathNotDirectory description:desc reason:nil];
		}
		return NO;
	}
	return YES;
}

- (NSString *)standardizeCurrentDirectoryForPath:(NSString *)path {
	// Converts . to actual working directory.
	if (![path hasPrefix:@"."] || [path hasPrefix:@".."]) return path;
	NSString *suffix = [path substringFromIndex:1];
	return [[self.fileManager currentDirectoryPath] stringByAppendingPathComponent:suffix];
}

- (NSString *)combineBasePath:(NSString *)base withRelativePath:(NSString *)path {
	// Appends the given relative path to the given base path if necessary. If relative path points to an exact location (starts with / or ~), it's simply returned, otherwise it's appended to the base path and result is returned.
	if ([path hasPrefix:@"~"] || [path hasPrefix:@"/"]) return path;
	if ([path hasPrefix:@"."] && ![path hasPrefix:@".."]) path = [path substringFromIndex:1];
	return [base stringByAppendingPathComponent:path];
}

#pragma mark Xcode, Global and project settings handling

- (void)injectXcodeSettingsFromArguments:(NSArray *)arguments {
    //check if even deal with a project
    if([arguments count] < 2)
        return;
    NSString *path = [arguments objectAtIndex:1];
    if(![path.pathExtension isEqualToString:@"xcodeproj"])
        return;

    //parse the file and get a representation of it
    NSError *error = nil;
    DDXcodeProjectFile *file = [DDXcodeProjectFile xcodeProjectFileWithPath:path error:&error];
    if(!file) {
        NSLog(@"Failed to parse pbx at %@: %@", path, error);
        return;
    }
    
    //set basic vars
    [self setProjectName:file.name];
    [self setProjectCompany:file.company];

    //prepare docset
    [self setCreateDocset:YES];
    [self setInstallDocset:YES];
    [self setDocsetBundleName:file.name];
    [self setCompanyId:[file.company stringByAppendingFormat:@".%@", file.name].lowercaseString];

    //set output path to be next to project
    [self.additionalInputPaths addObject:file.projectRoot];
    [self setOutput:file.projectRoot];
}

- (void)injectGlobalSettingsFromArguments:(NSArray *)arguments parser:(DDGetoptLongParser *)parser {
	// This is where we override factory defaults (factory defaults with global templates). This needs to be sent before giving DDCli a chance to go through parameters! DDCli will "take care" (or more correct: it's KVC messages will) of overriding with command line arguments. Note that we scan the arguments backwards to get the latest template value - this is what we'll get with DDCli later on anyway. If no template path is given, check predefined paths.
	self.templatesFound = NO;
	__block NSString *path = nil;
	[arguments enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString *option, NSUInteger idx, BOOL *stop) {
		NSString *opt = [option copy];
		while ([opt hasPrefix:@"-"]) opt = [opt substringFromIndex:1];
		if (GBStringIsShortOption(option, GBArgTemplatesPath) || GBStringIsLongOption(option, GBArgTemplatesPath)) {
			NSError *error = nil;
			if (![self validateTemplatesPath:path error:&error]) [NSException raiseWithError:error format:@"Path '%@' from %@ is not valid!", path, option];
			[self overrideSettingsWithGlobalSettingsFromPath:path parser:parser];
			self.templatesFound = YES;
			*stop = YES;
			return;
		}
		path = option;
	}];
	
	// If no templates path is provided through command line, test predefined ones. Note that we don't raise exception here if validation fails on any path, but we do raise it if no template path is found at all as we can't run the application!
	if (!self.templatesFound) {
		NSArray *appSupportPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		for (NSString *appSupportPath in appSupportPaths)
		{
			path = [appSupportPath stringByAppendingPathComponent:@"appledoc"];
			if ([self validateTemplatesPath:path error:nil]) {
				[self overrideSettingsWithGlobalSettingsFromPath:path parser:parser];
				self.settings.templatesPath = path;
				self.templatesFound = YES;
				return;
			}
		}
		
		path = @"~/.appledoc";
		if ([self validateTemplatesPath:path error:nil]) {
			[self overrideSettingsWithGlobalSettingsFromPath:path parser:parser];
			self.settings.templatesPath = path;
			self.templatesFound = YES;
			return;
		}
        
        #ifdef COMPILE_TIME_DEFAULT_TEMPLATE_PATH
		path = COMPILE_TIME_DEFAULT_TEMPLATE_PATH;
		if ([self validateTemplatesPath:path error:nil]) {
			[self overrideSettingsWithGlobalSettingsFromPath:path];
			self.settings.templatesPath = path;
			self.templatesFound = YES;
			return;
		}
        #endif
        
        //if we got here, there is NO templates installed which we can find.
        //IF we have embedded data though, we can get THAT and install it
		path = @"~/.appledoc";
        [self extractShippedTemplatesToPath:path];
		if ([self validateTemplatesPath:path error:nil]) {
			[self overrideSettingsWithGlobalSettingsFromPath:path parser:parser];
			self.settings.templatesPath = path;
			self.templatesFound = YES;
			return;
		}
                
	}
}

- (void)injectProjectSettingsFromArguments:(NSArray *)arguments parser:(DDGetoptLongParser *)parser {
	// Checks all command line paths for project settings and injects the settings to the application if found. Note that in case more than one path contains settings, all settings are injected with latest having greater priority. Note that we handle arguments very roughly; we start at back and proceed until we find first option name. This means we will also include last option value... Not too smart, but we need to do this before giving DDCli a chance to parse as we want to have command line switches overriding any project settings and we don't want to duplicate the behavior from DDCli.
	[arguments enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString *argument, NSUInteger idx, BOOL *stop) {
		if ([argument hasPrefix:@"-"]) {
			*stop = YES;
			return;
		}
		
		// Convert the argument to path.
		NSString *path = [[self standardizeCurrentDirectoryForPath:argument] stringByStandardizingPath];
		NSString *filename = path;
		
		// If we have a directory, check if it contains AppledocSettings.plist; ignore it if not. Note that we don't have to check if the file exists or not, that'll be handled for us inside settings injection method.
		BOOL dir;
		if (![self.fileManager fileExistsAtPath:path isDirectory:&dir]) return;
		if (dir) filename = [path stringByAppendingPathComponent:@"AppledocSettings.plist"];
		
		// If we have a plist file, handle it. Note that we need to handle --templates cmd line switch separately so that it's properly accepted by the application!
		if ([[filename pathExtension] isEqualToString:@"plist"]) {
			// Prepare the directory path to the plist file. We'll use it for preparing relative paths.
			if (!dir) [self.ignoredInputPaths addObject:argument];
			NSString *plistPath = [filename stringByDeletingLastPathComponent];

			// In the first pass, we need to handle --templates option. We need to handle these before any other option from the project settings to prevent global settings overriding project settings! Note how we prevent handling of every option except --templates; we leave that option through to get it set to application settings (that's all the KVC setter does).
			[self injectSettingsFromSettingsFile:filename parser:parser usingBlock:^BOOL(NSString *option, id *value, BOOL *stop) {
				if (GBStringIsLongOption(option, GBArgTemplatesPath)) {
					NSError *error = nil;
					NSString *templatesPath = [self combineBasePath:plistPath withRelativePath:*value];
					if (![self validateTemplatesPath:templatesPath error:&error]) [NSException raiseWithError:error format:@"Path '%@' from --%@ option in project settings '%@' is not valid!", *value, option, filename];
					[self overrideSettingsWithGlobalSettingsFromPath:templatesPath parser:parser];
					self.templatesFound = YES;
					*value = templatesPath;
					return YES;
				}
				return NO;
			}];
			
			// In the second pass, we handle all options. Note that we handle --input option manually; there is no KVC setter for it as it's not regular command line option (we get all input paths directly through command line arguments, not via command line switches). Also note that --templates is still allows but it's only going to be passed to application settings this time without being handled.
			[self injectSettingsFromSettingsFile:filename parser:parser usingBlock:^BOOL(NSString *option, id *value, BOOL *stop) {
				// If option is input path, add it to additional paths. We'll append these to any path found from command line. Note that we must properly handle . paths and paths not starting with / or ~; we assume these are relative paths so we prefix them with the path of the settings file!
				if (GBStringIsLongOption(option, GBArgInputPath)) {
					for (NSString *inputPath in *value) {
						NSString *combined = [self combineBasePath:plistPath withRelativePath:inputPath];
						[self.additionalInputPaths addObject:combined];
					}
					return NO;
				} else if (GBStringIsLongOption(option, GBArgTemplatesPath)) {
					return NO;
				}
				return YES;
			}];
		}
	}];
}

- (void)overrideSettingsWithGlobalSettingsFromPath:(NSString *)path parser:(DDGetoptLongParser *)parser {
	// Checks if global settings file exists at the given path and if so, overrides current settings with values from the file.
	NSString *userPath = [path stringByAppendingPathComponent:@"GlobalSettings.plist"];
	NSString *filename = [userPath stringByStandardizingPath];
	[self injectSettingsFromSettingsFile:filename parser:parser usingBlock:^(NSString *option, id *value, BOOL *stop) {
		if (GBStringIsLongOption(option, GBArgTemplatesPath)) {
			ddprintf(@"WARN: Found unsupported --%@ option in global settings file '%@'!\n", option, userPath);
			return NO;
		}
		if (GBStringIsLongOption(option, GBArgInputPath)) {
			ddprintf(@"WARN: Found unsupported --%@ option in global settings '%@'!\n", option, userPath);
			return NO;
		}
		return YES;
	}];
}

- (void)injectSettingsFromSettingsFile:(NSString *)path parser:(DDGetoptLongParser *)parser usingBlock:(BOOL (^)(NSString *option, id *value, BOOL *stop))block {
	// Injects any settings found in the given file to the application settings, overriding current settings with values from the file. To keep code as simple as possible, we're reusing DDCli KVC here: settings file simply uses keys which are equal to command line arguments. Then, by reusing DDCli method for converting switch to KVC key, we're simply sending appropriate KVC messages to receiver. From object's point of view, this is no different than getting KVC messages sent from DDCli. Note that this may cause some KVC messages beeing sent twice or more. The only code added is handling boolean settings (i.e. adding "--no" prefix) and settings that may be entered multiple times (--ignore for example). To even further simplify handling, we're only allowing long command line arguments names in settings files for now!
	if (![self.fileManager fileExistsAtPath:path]) return;

	NSError* error = nil;
	NSData* data = [NSData dataWithContentsOfFile:path options:0 error:&error];
	if (!data) [NSException raise:@"Failed reading settings from '%@'!", path];
	NSDictionary *theSettings = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error];
	if (!theSettings) [NSException raiseWithError:error format:@"Failed reading settings plist from '%@'!", path];
	
	// We first pass each option and it's value to the block. The block can return YES to allow handling it, NO otherwise. It can also pass back a different value (we're passing a pointer to the value!).
	[theSettings enumerateKeysAndObjectsUsingBlock:^(NSString *option, id value, BOOL *stop) {
		while ([option hasPrefix:@"-"]) option = [option substringFromIndex:1];
		NSString *key = [parser optionToKey:option];
		if (!block(option, &value, stop)) return;

		// If the value is an array, send as many messages as there are values.
		if ([value isKindOfClass:[NSArray class]]) {
			for (NSString *item in value) {
				[self setValue:item forKey:key];
			}
			return;
		}
		
		// For all other values, just send the KVC message. Note that this works for booleans as well - if the plist has NO value, the value reported is going to be [NSNumber numberWithBool:NO] and our KVC mutator would properly assign the value, so therefore we don't have to prefix with "no"...
		[self setValue:value forKey:key];
	}];
}

#pragma mark Overriden methods

- (NSString *)description {
	return [self className];
}

#pragma mark Callbacks API for DDCliApplication

- (void)setOutput:(NSString *)path { self.settings.outputPath = [self standardizeCurrentDirectoryForPath:path]; }
- (void)setDocsetInstallPath:(NSString *)path { self.settings.docsetInstallPath = [self standardizeCurrentDirectoryForPath:path]; }
- (void)setXCRunPath:(NSString *)path { self.settings.xcrunPath = [self standardizeCurrentDirectoryForPath:path]; }
- (void)setInclude:(NSString *)path { [self.settings.includePaths addObject:[self standardizeCurrentDirectoryForPath:path]]; }
- (void)setIndexDesc:(NSString *)path { self.settings.indexDescriptionPath = [self standardizeCurrentDirectoryForPath:path]; }
- (void)setTemplates:(NSString *)path { self.settings.templatesPath = [self standardizeCurrentDirectoryForPath:path]; }
- (void)setIgnore:(NSString *)path {
	if ([path hasPrefix:@"*"]) path = [path substringFromIndex:1];
	[self.settings.ignoredPaths addObject:path];
}
- (void)setExcludeOutput:(NSString *)path {
	[self.settings.excludeOutputPaths addObject:path];
}

- (void)setProjectName:(NSString *)value { self.settings.projectName = value; }
- (void)setProjectVersion:(NSString *)value { self.settings.projectVersion = value; }
- (void)setProjectCompany:(NSString *)value { self.settings.projectCompany = value; }
- (void)setCompanyId:(NSString *)value { self.settings.companyIdentifier = value; }

- (void)setCleanOutput:(BOOL)value { self.settings.cleanupOutputPathBeforeRunning = value; }
- (void)setCreateHtml:(BOOL)value {
	self.settings.createHTML = value;
	if (!value) {
		self.settings.createDocSet = NO;
		self.settings.finalizeDocSet = NO;
		self.settings.installDocSet = NO;
		self.settings.publishDocSet = NO;
	}
}
- (void)setCreateDocset:(BOOL)value {
	self.settings.createDocSet = value;
	if (value) {
		self.settings.createHTML = YES;
	} else {
		self.settings.finalizeDocSet = NO;
		self.settings.installDocSet = NO;
		self.settings.publishDocSet = NO;
	}
}
- (void)setFinalizeDocset:(BOOL)value {
	self.settings.finalizeDocSet = value;
	if (value) {
		self.settings.createHTML = YES;
		self.settings.createDocSet = YES;
		self.settings.installDocSet = NO;

	//	} else {
	//		self.settings.publishDocSet = NO;
	}
}
- (void)setInstallDocset:(BOOL)value {
	self.settings.installDocSet = value;
	if (value) {
		self.settings.createHTML = YES;
		self.settings.createDocSet = YES;
		self.settings.finalizeDocSet = YES;

    //	} else {
    //		self.settings.publishDocSet = NO;
	}
}
- (void)setPublishDocset:(BOOL)value {
	self.settings.publishDocSet = value;
	if (value) {
		self.settings.createHTML = YES;
		self.settings.createDocSet = YES;
	//	self.settings.installDocSet = YES;
	}
}
- (void)setHtmlAnchors:(NSString *)value {
    self.settings.htmlAnchorFormat = GBHTMLAnchorFormatFromNSString(value);
}
- (void)setNoCleanOutput:(BOOL)value { self.settings.cleanupOutputPathBeforeRunning = !value; }
- (void)setNoCreateHtml:(BOOL)value { [self setCreateHtml:!value]; }
- (void)setNoCreateDocset:(BOOL)value { [self setCreateDocset:!value]; }
- (void)setNoFinalizeDocset:(BOOL)value { [self setFinalizeDocset:!value]; }
- (void)setNoInstallDocset:(BOOL)value { [self setInstallDocset:!value]; }
- (void)setNoPublishDocset:(BOOL)value { [self setPublishDocset:!value]; }

- (void)setCrossrefFormat:(NSString *)value { self.settings.commentComponents.crossReferenceMarkersTemplate = value; }
- (void)setExplicitCrossref:(BOOL)value { self.settings.commentComponents.crossReferenceMarkersTemplate = value ? @"<%@>" : @"<?%@>?"; }
- (void)setNoExplicitCrossref:(BOOL)value { [self setExplicitCrossref:!value]; }

- (void)setExitThreshold:(int)value { self.settings.exitCodeThreshold = value; }
- (void)setKeepIntermediateFiles:(BOOL)value { self.settings.keepIntermediateFiles = value;}
- (void)setKeepUndocumentedObjects:(BOOL)value { self.settings.keepUndocumentedObjects = value; }
- (void)setKeepUndocumentedMembers:(BOOL)value { self.settings.keepUndocumentedMembers = value; }
- (void)setSearchUndocumentedDoc:(BOOL)value { self.settings.findUndocumentedMembersDocumentation = value; }
- (void)setRepeatFirstPar:(BOOL)value { self.settings.repeatFirstParagraphForMemberDescription = value; }
- (void)setPreprocessHeaderdoc:(BOOL)value { self.settings.preprocessHeaderDoc = value; }
- (void)setPrintInformationBlockTitles:(BOOL)value { self.settings.printInformationBlockTitles = value; }
- (void)setUseSingleStar:(BOOL)value { self.settings.useSingleStarForBold = value; }
- (void)setMergeCategories:(BOOL)value { self.settings.mergeCategoriesToClasses = value; }
- (void)setMergeCategoryComment:(BOOL)value { self.settings.mergeCategoryCommentToClass = value; }
- (void)setKeepMergedSections:(BOOL)value { self.settings.keepMergedCategoriesSections = value; }
- (void)setPrefixMergedSections:(BOOL)value { self.settings.prefixMergedCategoriesSectionsWithCategoryName = value; }
- (void)setNoKeepIntermediateFiles:(BOOL)value { self.settings.keepIntermediateFiles = !value;}
- (void)setNoKeepUndocumentedObjects:(BOOL)value { self.settings.keepUndocumentedObjects = !value; }
- (void)setNoKeepUndocumentedMembers:(BOOL)value { self.settings.keepUndocumentedMembers = !value; }
- (void)setNoSearchUndocumentedDoc:(BOOL)value { self.settings.findUndocumentedMembersDocumentation = !value; }
- (void)setNoRepeatFirstPar:(BOOL)value { self.settings.repeatFirstParagraphForMemberDescription = !value; }
- (void)setNoUseSingleStar:(BOOL)value { self.settings.useSingleStarForBold = !value; }
- (void)setNoPreprocessHeaderdoc:(BOOL)value { self.settings.preprocessHeaderDoc = !value; }
- (void)setNoPrintInformationBlockTitles:(BOOL)value { self.settings.printInformationBlockTitles = !value; }
- (void)setNoMergeCategories:(BOOL)value { self.settings.mergeCategoriesToClasses = !value; }
- (void)setNoMergeCategoryComment:(BOOL)value { self.settings.mergeCategoryCommentToClass = !value; }
- (void)setNoKeepMergedSections:(BOOL)value { self.settings.keepMergedCategoriesSections = !value; }
- (void)setNoPrefixMergedSections:(BOOL)value { self.settings.prefixMergedCategoriesSectionsWithCategoryName = !value; }
- (void)setUseCodeOrder:(BOOL)value { self.settings.useCodeOrder = value; }
- (void)setNoUseCodeOrder:(BOOL)value { self.settings.useCodeOrder = !value; }

- (void)setWarnMissingOutputPath:(BOOL)value { self.settings.warnOnMissingOutputPathArgument = value; }
- (void)setWarnMissingCompanyId:(BOOL)value { self.settings.warnOnMissingCompanyIdentifier = value; }
- (void)setWarnUndocumentedObject:(BOOL)value { self.settings.warnOnUndocumentedObject = value; }
- (void)setWarnUndocumentedMember:(BOOL)value { self.settings.warnOnUndocumentedMember = value; }
- (void)setWarnEmptyDescription:(BOOL)value { self.settings.warnOnEmptyDescription = value; }
- (void)setWarnUnknownDirective:(BOOL)value { self.settings.warnOnUnknownDirective = value; }
- (void)setWarnInvalidCrossref:(BOOL)value { self.settings.warnOnInvalidCrossReference = value; }
- (void)setWarnMissingArg:(BOOL)value { self.settings.warnOnMissingMethodArgument = value; }
- (void)setNoWarnMissingOutputPath:(BOOL)value { self.settings.warnOnMissingOutputPathArgument = !value; }
- (void)setNoWarnMissingCompanyId:(BOOL)value { self.settings.warnOnMissingCompanyIdentifier = !value; }
- (void)setNoWarnUndocumentedObject:(BOOL)value { self.settings.warnOnUndocumentedObject = !value; }
- (void)setNoWarnUndocumentedMember:(BOOL)value { self.settings.warnOnUndocumentedMember = !value; }
- (void)setNoWarnEmptyDescription:(BOOL)value { self.settings.warnOnEmptyDescription = !value; }
- (void)setNoWarnUnknownDirective:(BOOL)value { self.settings.warnOnUnknownDirective = !value; }
- (void)setNoWarnInvalidCrossref:(BOOL)value { self.settings.warnOnInvalidCrossReference = !value; }
- (void)setNoWarnMissingArg:(BOOL)value { self.settings.warnOnMissingMethodArgument = !value; }

- (void)setDocsetBundleId:(NSString *)value { self.settings.docsetBundleIdentifier = value; }
- (void)setDocsetBundleName:(NSString *)value { self.settings.docsetBundleName = value; }
- (void)setDocsetDesc:(NSString *)value { self.settings.docsetDescription = value; }
- (void)setDocsetCopyright:(NSString *)value { self.settings.docsetCopyrightMessage = value; }
- (void)setDocsetFeedName:(NSString *)value { self.settings.docsetFeedName = value; }
- (void)setDocsetFeedUrl:(NSString *)value { self.settings.docsetFeedURL = value; }
- (void)setDocsetFeedFormats:(NSString *)value {
    self.settings.docsetFeedFormats = GBPublishedFeedFormatsFromNSString(value);
}
- (void)setDocsetPackageUrl:(NSString *)value { self.settings.docsetPackageURL = value; }
- (void)setDocsetFallbackUrl:(NSString *)value { self.settings.docsetFallbackURL = value; }
- (void)setDocsetPublisherId:(NSString *)value { self.settings.docsetPublisherIdentifier = value; }
- (void)setDocsetPublisherName:(NSString *)value { self.settings.docsetPublisherName = value; }
- (void)setDocsetMinXcodeVersion:(NSString *)value { self.settings.docsetMinimumXcodeVersion = value; }
- (void)setDocsetPlatformFamily:(NSString *)value { self.settings.docsetPlatformFamily = value; }
- (void)setDocsetCertIssuer:(NSString *)value { self.settings.docsetCertificateIssuer = value; }
- (void)setDocsetCertSigner:(NSString *)value { self.settings.docsetCertificateSigner = value; }
- (void)setDashPlatformFamily:(NSString *)value { self.settings.dashDocsetPlatformFamily = value; }

- (void)setDocsetBundleFilename:(NSString *)value { self.settings.docsetBundleFilename = value; }
- (void)setDocsetAtomFilename:(NSString *)value { self.settings.docsetAtomFilename = value; }
- (void)setDocsetXMLFilename:(NSString *)value { self.settings.docsetXMLFilename = value; }
- (void)setDocsetPackageFilename:(NSString *)value { self.settings.docsetPackageFilename = value; }

@synthesize additionalInputPaths;
@synthesize ignoredInputPaths;
@synthesize logformat;
@synthesize verbose;
@synthesize printSettings;
@synthesize templatesFound;
@synthesize version;
@synthesize help;

#pragma mark Properties

@synthesize settings;

@end

#pragma mark -

@implementation GBAppledocApplication (UsagePrintout)

- (void)printSettingsAndArguments:(NSArray *)arguments {
	#define printOpt(key, value) ddprintf(@"--%s = %@\n", key.longOption, value)
	#define printBool(v) (v ? @"YES" : @"NO")

	// This is useful for debugging to see exact set of setting values that are going to be used for this session. Note that this is coupling command line switches to actual settings. Here it's just the opposite than DDCli callbacks.
	ddprintf(@"Running for files in locations:\n");
	for (NSString *path in arguments) ddprintf(@"- %@\n", path);
	ddprintf(@"\n");

	ddprintf(@"Settings used for this run:\n");
	printOpt(GBArgProjectName, self.settings.projectName);
	printOpt(GBArgProjectVersion, self.settings.projectVersion);
	printOpt(GBArgProjectCompany, self.settings.projectCompany);
	printOpt(GBArgCompanyIdentifier, self.settings.companyIdentifier);
	ddprintf(@"\n");
	
	printOpt(GBArgTemplatesPath, self.settings.templatesPath);
	printOpt(GBArgOutputPath, self.settings.outputPath);
	printOpt(GBArgIndexDescPath, self.settings.indexDescriptionPath);
	for (NSString *path in self.settings.includePaths) printOpt(GBArgIncludePath, path);
	for (NSString *path in self.settings.ignoredPaths) printOpt(GBArgIgnorePath, path);
	for (NSString *path in self.settings.excludeOutputPaths) printOpt(GBArgExcludeOutputPath, path);
	printOpt(GBArgDocSetInstallPath, self.settings.docsetInstallPath);
	printOpt(GBArgXcrunPath, self.settings.xcrunPath);
	ddprintf(@"\n");
	
	printOpt(GBArgDocSetBundleIdentifier, self.settings.docsetBundleIdentifier);
	printOpt(GBArgDocSetBundleName, self.settings.docsetBundleName);
	printOpt(GBArgDocSetDescription, self.settings.docsetDescription);
	printOpt(GBArgDocSetCopyrightMessage, self.settings.docsetCopyrightMessage);
	printOpt(GBArgDocSetFeedName, self.settings.docsetFeedName);
	printOpt(GBArgDocSetFeedURL, self.settings.docsetFeedURL);
	printOpt(GBArgDocSetFeedFormats, NSStringFromGBPublishedFeedFormats(self.settings.docsetFeedFormats));
	printOpt(GBArgDocSetPackageURL, self.settings.docsetPackageURL);
	printOpt(GBArgDocSetFallbackURL, self.settings.docsetFallbackURL);
	printOpt(GBArgDocSetPublisherIdentifier, self.settings.docsetPublisherIdentifier);
	printOpt(GBArgDocSetPublisherName, self.settings.docsetPublisherName);
	printOpt(GBArgDocSetMinimumXcodeVersion, self.settings.docsetMinimumXcodeVersion);
	printOpt(GBArgDocSetPlatformFamily, self.settings.docsetPlatformFamily);
	printOpt(GBArgDocSetCertificateIssuer, self.settings.docsetCertificateIssuer);
	printOpt(GBArgDocSetCertificateSigner, self.settings.docsetCertificateSigner);

	printOpt(GBArgDocSetBundleFilename, self.settings.docsetBundleFilename);
	printOpt(GBArgDocSetAtomFilename, self.settings.docsetAtomFilename);
	printOpt(GBArgDocSetXMLFilename, self.settings.docsetXMLFilename);
	printOpt(GBArgDocSetPackageFilename, self.settings.docsetPackageFilename);
	ddprintf(@"\n");
	
	printOpt(GBArgCleanOutput, printBool(self.settings.cleanupOutputPathBeforeRunning));
	printOpt(GBArgCreateHTML, printBool(self.settings.createHTML));
	printOpt(GBArgCreateDocSet, printBool(self.settings.createDocSet));
	printOpt(GBArgInstallDocSet, printBool(self.settings.installDocSet));
	printOpt(GBArgPublishDocSet, printBool(self.settings.publishDocSet));
	printOpt(GBArgHTMLAnchorFormat, NSStringFromGBHTMLAnchorFormat(self.settings.htmlAnchorFormat));
	printOpt(GBArgKeepIntermediateFiles, printBool(self.settings.keepIntermediateFiles));
	printOpt(GBArgKeepUndocumentedObjects, printBool(self.settings.keepUndocumentedObjects));
	printOpt(GBArgKeepUndocumentedMembers, printBool(self.settings.keepUndocumentedMembers));
	printOpt(GBArgFindUndocumentedMembers, printBool(self.settings.findUndocumentedMembersDocumentation));
	printOpt(GBArgRepeatFirstParagraph, printBool(self.settings.repeatFirstParagraphForMemberDescription));
	printOpt(GBArgPreprocessHeaderDoc, printBool(self.settings.preprocessHeaderDoc));
	printOpt(GBArgPrintInformationBlockTitles, printBool(self.settings.printInformationBlockTitles));
	printOpt(GBArgUseSingleStar, printBool(self.settings.useSingleStarForBold));
	printOpt(GBArgMergeCategoriesToClasses, printBool(self.settings.mergeCategoriesToClasses));
	printOpt(GBArgMergeCategoryComment, printBool(self.settings.mergeCategoryCommentToClass));
	printOpt(GBArgKeepMergedCategoriesSections, printBool(self.settings.keepMergedCategoriesSections));
	printOpt(GBArgPrefixMergedCategoriesSections, printBool(self.settings.prefixMergedCategoriesSectionsWithCategoryName));
	printOpt(GBArgCrossRefFormat, self.settings.commentComponents.crossReferenceMarkersTemplate);
	printOpt(GBArgUseCodeOrder, printBool(self.settings.useCodeOrder));
	printOpt(GBArgExitCodeThreshold, @(self.settings.exitCodeThreshold));
	ddprintf(@"\n");

	printOpt(GBArgWarnOnMissingOutputPath, printBool(self.settings.warnOnMissingOutputPathArgument));
	printOpt(GBArgWarnOnMissingCompanyIdentifier, printBool(self.settings.warnOnMissingCompanyIdentifier));
	printOpt(GBArgWarnOnUndocumentedObject, printBool(self.settings.warnOnUndocumentedObject));
	printOpt(GBArgWarnOnUndocumentedMember, printBool(self.settings.warnOnUndocumentedMember));
	printOpt(GBArgWarnOnEmptyDescription, printBool(self.settings.warnOnEmptyDescription));
	printOpt(GBArgWarnOnUnknownDirective, printBool(self.settings.warnOnUnknownDirective));
	printOpt(GBArgWarnOnInvalidCrossReference, printBool(self.settings.warnOnInvalidCrossReference));
	printOpt(GBArgWarnOnMissingMethodArgument, printBool(self.settings.warnOnMissingMethodArgument));
	ddprintf(@"\n");
	
	printOpt(GBArgLogFormat, self.logformat);
	printOpt(GBArgVerbose, self.verbose);
	ddprintf(@"\n");

	#undef printOpt
	#undef printBool
}

- (void)printVersion {
	NSString *appledocName = [self.settings.stringTemplates.appledocData objectForKey:@"tool"];
	NSString *appledocVersion = [self.settings.stringTemplates.appledocData objectForKey:@"version"];
	NSString *appledocBuild = [self.settings.stringTemplates.appledocData objectForKey:@"build"];
	ddprintf(@"%@ version: %@ (build %@)\n", appledocName, appledocVersion, appledocBuild);
	ddprintf(@"\n");
}

- (void)printHelp {
	void(^printOptUsage)(DDGetoptOption, NSString *, NSString *) = ^(DDGetoptOption opt, NSString *argument, NSString *description){
		NSString *aShort = opt.shortOption ? [NSString stringWithFormat:@"%c,", (char)opt.shortOption] : @"   ";
		NSString *aLong = opt.longOption ? [NSString stringWithUTF8String:opt.longOption] : @"";
		while([aLong length] + [argument length] < 32) argument = [argument stringByAppendingString:@" "];
		ddprintf(@"  %@ --%@ %@ %@\n", aShort, aLong, argument, description);
	};
#define PRINT_USAGE(short,long,arg,desc) [self printHelpForShortOption:short longOption:long argument:arg description:desc]

	NSString *name = [self.settings.stringTemplates.appledocData objectForKey:@"tool"];
	ddprintf(@"Usage: %@ [OPTIONS] <paths to source dirs or files>\n", name);
	ddprintf(@"\n");
	ddprintf(@"PATHS\n");
	printOptUsage(GBArgOutputPath, @"<path>", @"Output path");
	printOptUsage(GBArgTemplatesPath, @"<path>", @"Template files path");
	printOptUsage(GBArgDocSetInstallPath, @"<path>", @"DocSet installation path");
	printOptUsage(GBArgIncludePath, @"<path>", @"Include static doc(s) at path");
	printOptUsage(GBArgIgnorePath, @"<path>", @"Ignore given path");
	printOptUsage(GBArgExcludeOutputPath, @"<path>", @"Exclude given path from output");
	printOptUsage(GBArgIndexDescPath, @"<path>", @"File including main index description");
	ddprintf(@"\n");
	ddprintf(@"PROJECT INFO\n");
	printOptUsage(GBArgProjectName, @"<string>", @"Project name");
	printOptUsage(GBArgProjectVersion, @"<string>", @"Project version");
	printOptUsage(GBArgProjectCompany, @"<string>", @"Project company");
	printOptUsage(GBArgCompanyIdentifier, @"<string>", @"Company UTI (i.e. reverse DNS name)");
	ddprintf(@"\n");
	ddprintf(@"OUTPUT GENERATION\n");
	printOptUsage(GBArgCreateHTML, @"", @"[b] Create HTML");
	printOptUsage(GBArgCreateDocSet, @"", @"[b] Create documentation set");
	printOptUsage(GBArgInstallDocSet, @"", @"[b] Install documentation set to Xcode");
	printOptUsage(GBArgPublishDocSet, @"", @"[b] Prepare DocSet for publishing");
	printOptUsage(GBArgHTMLAnchorFormat, @"<string>", @"[*] The html anchor format to use in DocSet HTML.");
	printOptUsage(GBArgCleanOutput, @"", @"[b] Remove contents of output path before starting !!CAUTION!!");
	ddprintf(@"\n");
	ddprintf(@"OPTIONS\n");
	printOptUsage(GBArgKeepIntermediateFiles, @"", @"[b] Keep intermediate files in output path");
	printOptUsage(GBArgKeepUndocumentedObjects, @"", @"[b] Keep undocumented objects");
	printOptUsage(GBArgKeepUndocumentedMembers, @"", @"[b] Keep undocumented members");
	printOptUsage(GBArgFindUndocumentedMembers, @"", @"[b] Search undocumented members documentation");
	printOptUsage(GBArgRepeatFirstParagraph, @"", @"[b] Repeat first paragraph in member documentation");
	printOptUsage(GBArgPreprocessHeaderDoc, @"", @"[b] Preprocess header doc comments - 10.7 only!");
	printOptUsage(GBArgPrintInformationBlockTitles, @"", @"[b] Print title of information blocks. \"Note:\", \"Warning:\", etc.");
	printOptUsage(GBArgUseSingleStar, @"", @"[b] Use single star for bold marker");
	printOptUsage(GBArgMergeCategoriesToClasses, @"", @"[b] Merge categories to classes");
	printOptUsage(GBArgMergeCategoryComment, @"", @"[b] Merge category comment to class");
	printOptUsage(GBArgKeepMergedCategoriesSections, @"", @"[b] Keep merged categories sections");
	printOptUsage(GBArgPrefixMergedCategoriesSections, @"", @"[b] Prefix merged sections with category name");
	printOptUsage(GBArgExplicitCrossRef, @"", @"[b] Shortcut for explicit default cross ref template");
	printOptUsage(GBArgUseCodeOrder, @"", @"[b] Order sections by the order specified in the input files");
	printOptUsage(GBArgCrossRefFormat, @"<string>", @"Cross reference template regex");
	printOptUsage(GBArgExitCodeThreshold, @"<number>", @"Exit code threshold below which 0 is returned");
	ddprintf(@"\n");
	ddprintf(@"WARNINGS\n");
	printOptUsage(GBArgWarnOnMissingOutputPath, @"", @"[b] Warn if output path is not given");
	printOptUsage(GBArgWarnOnMissingCompanyIdentifier, @"", @"[b] Warn if company ID is not given");
	printOptUsage(GBArgWarnOnUndocumentedObject, @"", @"[b] Warn on undocumented object");
	printOptUsage(GBArgWarnOnUndocumentedMember, @"", @"[b] Warn on undocumented member");
	printOptUsage(GBArgWarnOnEmptyDescription, @"", @"[b] Warn on empty description block");
	printOptUsage(GBArgWarnOnUnknownDirective, @"", @"[b] Warn on unknown directive or format");
	printOptUsage(GBArgWarnOnInvalidCrossReference, @"", @"[b] Warn on invalid cross reference");
	printOptUsage(GBArgWarnOnMissingMethodArgument, @"", @"[b] Warn on missing method argument documentation");
	ddprintf(@"\n");
	ddprintf(@"DOCUMENTATION SET INFO\n");
	printOptUsage(GBArgDocSetBundleIdentifier, @"<string>", @"[*] DocSet bundle identifier");
	printOptUsage(GBArgDocSetBundleName, @"<string>", @"[*] DocSet bundle name");
	printOptUsage(GBArgDocSetDescription, @"<string>", @"[*] DocSet description");
	printOptUsage(GBArgDocSetCopyrightMessage, @"<string>", @"[*] DocSet copyright message");
	printOptUsage(GBArgDocSetFeedName, @"<string>", @"[*] DocSet feed name");
	printOptUsage(GBArgDocSetFeedURL, @"<string>", @"[*] DocSet feed URL");
	printOptUsage(GBArgDocSetFeedFormats, @"<values>", @"DocSet feed formats. Separated by a comma [atom,xml]");
	printOptUsage(GBArgDocSetPackageURL, @"<string>", @"[*] DocSet package (.xar) URL");
	printOptUsage(GBArgDocSetFallbackURL, @"<string>", @"[*] DocSet fallback URL");
	printOptUsage(GBArgDocSetPublisherIdentifier, @"<string>", @"[*] DocSet publisher identifier");
	printOptUsage(GBArgDocSetPublisherName, @"<string>", @"[*] DocSet publisher name");
	printOptUsage(GBArgDocSetMinimumXcodeVersion, @"<string>", @"[*] DocSet min. Xcode version");
	printOptUsage(GBArgDocSetPlatformFamily, @"<string>", @"[*] DocSet platform familiy");
	printOptUsage(GBArgDocSetCertificateIssuer, @"<string>", @"[*] DocSet certificate issuer");
	printOptUsage(GBArgDocSetCertificateSigner, @"<string>", @"[*] DocSet certificate signer");
	printOptUsage(GBArgDocSetBundleFilename, @"<string>", @"[*] DocSet bundle filename");
	printOptUsage(GBArgDocSetAtomFilename, @"<string>", @"[*] DocSet atom feed filename");
	printOptUsage(GBArgDocSetXMLFilename, @"<string>", @"[*] DocSet xml feed filename");
	printOptUsage(GBArgDocSetPackageFilename, @"<string>", @"[*] DocSet package (.xar,.tgz) filename. Leave off the extension. This will be added depending on the generated package.");
	ddprintf(@"\n");
	ddprintf(@"MISCELLANEOUS\n");
	printOptUsage(GBArgLogFormat, @"<number>", @"Log format [0-3]");
	printOptUsage(GBArgVerbose, @"<value>", @"Log verbosity level [0-6,xcode]");
	printOptUsage(GBArgVersion, @"", @"Display version and exit");
	printOptUsage(GBArgHelp, @"", @"Display this help and exit");
	ddprintf(@"\n");
	ddprintf(@"==================================================================\n");
	ddprintf(@"[b] boolean parameter, uses no value, use --no- prefix to negate.\n");
	ddprintf(@"\n");
	ddprintf(@"[*] indicates parameters accepting placeholder strings:\n");
	ddprintf(@"- %@ replaced with --project-name\n", kGBTemplatePlaceholderProject);
	ddprintf(@"- %@ replaced with normalized --project-name\n", kGBTemplatePlaceholderProjectID);
	ddprintf(@"- %@ replaced with --project-version\n", kGBTemplatePlaceholderVersion);
	ddprintf(@"- %@ replaced with normalized --project-version\n", kGBTemplatePlaceholderVersionID);
	ddprintf(@"- %@ replaced with --project-company\n", kGBTemplatePlaceholderCompany);
	ddprintf(@"- %@ replaced with --company-id\n", kGBTemplatePlaceholderCompanyID);
	ddprintf(@"- %@ replaced with current year (format yyyy)\n", kGBTemplatePlaceholderYear);
	ddprintf(@"- %@ replaced with current date (format yyyy-MM-dd)\n", kGBTemplatePlaceholderUpdateDate);
	ddprintf(@"- %@ replaced with --docset-bundle-filename\n", kGBTemplatePlaceholderDocSetBundleFilename);
	ddprintf(@"- %@ replaced with --docset-atom-filename\n", kGBTemplatePlaceholderDocSetAtomFilename);
	ddprintf(@"- %@ replaced with --docset-package-filename\n", kGBTemplatePlaceholderDocSetPackageFilename);
	ddprintf(@"\n");
	ddprintf(@"==================================================================\n");
	ddprintf(@"Find more help and tips online:\n");
	ddprintf(@"- http://appledoc.gentlebytes.com/\n");
	ddprintf(@"- http://tomaz.github.com/appledoc/\n");
	ddprintf(@"\n");
	ddprintf(@"==================================================================\n");
	ddprintf(@"%@ uses the following open source components, fully or partially:\n", name);
	ddprintf(@"\n");
	ddprintf(@"- DDCli by Dave Dribin\n");
	ddprintf(@"- CocoaLumberjack by Robbie Hanson\n");
	ddprintf(@"- ParseKit by Todd Ditchendorf\n");
	ddprintf(@"- RegexKitLite by John Engelhart\n");
	ddprintf(@"- GRMustache by Gwendal Roué\n");
	ddprintf(@"- Discount by David Parsons\n");
	ddprintf(@"- Timing functions from Apple examples\n");
	ddprintf(@"\n");
	ddprintf(@"We'd like to thank all authors for their contribution!\n");
}

- (void)printHelpForShortOption:(int)shortOpt longOption:(const char *)longOpt argument:(NSString *)argument description:(NSString *)description {
	NSString *aShort = (shortOpt == 0) ? @"   " : [NSString stringWithFormat:@"%c,", (char)shortOpt];
	NSString *aLong = [NSString stringWithUTF8String:longOpt];
	while([aLong length] + [argument length] < 32) argument = [argument stringByAppendingString:@" "];
	ddprintf(@"  %@ --%@ %@ %@\n", aShort, aLong, argument, description);
}

@end
