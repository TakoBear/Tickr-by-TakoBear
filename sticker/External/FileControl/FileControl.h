//
//  FileControl.h
//
//  Created by Darktt on 14/6/12.
//  Copyright (c) 2012 Darktt. All rights reserved.

#import <Foundation/Foundation.h>

typedef void (^FCCompletionBlock) (BOOL, NSError *);

@interface FileControl : NSObject

+ (FileControl *)mainPath;

// Check File Is Exist
- (BOOL)fileExistAtPath:(NSString *)path;
- (BOOL)fileExistAtURL:(NSURL *)url;

// Check Free Space
- (NSString *)getFreeSpaceAtPath:(NSString *)path converSizeUnit:(BOOL)conver;
- (NSNumber *)checkStorageSpace;
- (BOOL)checkSpaceEnoughWithFilePath:(NSString *)path;
- (BOOL)checkSpaceEnoughWithFileSize:(NSNumber *)size;

// Get Path
- (NSString *)currentApplicationPath;
- (NSString *)currentApplicationPathWithDirectoryName:(NSString *)dirName;
- (NSString *)documentPath;
- (NSString *)documentPathWithFileName:(NSString *)fileName;
- (NSString *)cachesPath;
- (NSString *)cachesPathWithFileName:(NSString *)fileName;
- (NSString *)LibraryPath;

// Read Data
- (NSString *)readStringFromPath:(NSString *)filePath;
- (NSArray *)readArrayFromPath:(NSString *)filePath;
- (NSDictionary *)readDictionaryFromFilePath:(NSString *)filePath;

// Write Data
- (void)writeStringFile:(NSString *)string withFilePath:(NSString *)filePath;
- (void)writeArrayFile:(NSArray *)array withFilePath:(NSString *)filePath;
- (void)writeDictionaryToFile:(NSDictionary *)dictionary withFilePath:(NSString *)filePath;

// Create File Or Directory
- (BOOL)createDirectoryUnderDocument:(NSString *)directory;
- (BOOL)createDirectoryUnderCaches:(NSString *)directory;
- (BOOL)createFile:(NSString *)fileName directoryUnderDocument:(NSString *)directory;
- (BOOL)createFileWithPath:(NSString *)path;

// Get File List
- (NSArray *)filesOfCurrentDirectoryName:(NSString *)dirName;
- (NSArray *)getFilesWithDirectoryPath:(NSString *)path;
- (NSArray *)convertFullPathWithFiles:(NSArray *)files path:(NSString *)path;

// Remove File
- (BOOL)removeFileAtPath:(NSString *)path;

// Copy File
- (BOOL)copyFileAtPath:(NSString *)path toPath:(NSString *)toPath;
- (void)copyFileUseBlockAtPath:(NSString *)path toPath:(NSString *)toPath completion:(FCCompletionBlock)completion;

// Move File
- (BOOL)moveFileAtPath:(NSString *)path toPath:(NSString *)toPath;
- (void)moveFileUseBlockAtPath:(NSString *)path toPath:(NSString *)toPath completion:(FCCompletionBlock)completion;

// Get File Infomation
- (NSDictionary *)getFileInformationAtPath:(NSString *)path;
- (NSString *)getFileSizeAtPath:(NSString *)path converSizeUnit:(BOOL)conver;
- (NSDate *)getFileCreationDateAtPath:(NSString *)path;
- (NSString *)getFileCreationDateAtPath:(NSString *)path dateFormat:(NSString *)format;
- (NSDate *)getFileModificationDateAtPath:(NSString *)path;
- (NSString *)getFileModificationDateAtPath:(NSString *)path dateFormat:(NSString *)format;

// Convert File Size
- (NSString *)convertFileSizeWithSize:(NSNumber *)fileSize;

@end
