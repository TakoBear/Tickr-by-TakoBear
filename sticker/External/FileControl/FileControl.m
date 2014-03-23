//
//  FileControl.m
//
//  Created by Darktt on 14/6/12.
//  Copyright (c) 2012 Darktt. All rights reserved.
//

#import "FileControl.h"

typedef void (^QueueBlock) (void);

@implementation FileControl

static FileControl *singleton = nil;

+ (FileControl *)mainPath
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [FileControl new];
    });
    
    return singleton;
}

#pragma mark - File Checking Methods
#pragma mark Check File Is Exist

- (BOOL)fileExistAtPath:(NSString *)path
{
    NSURL *fileURL = [NSURL URLWithString:path];
    if ([fileURL isFileURL]) {
        path = [fileURL path];
    }
    
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (BOOL)fileExistAtURL:(NSURL *)url
{
    if (![url isFileURL]) {
        [NSException raise:NSInvalidArgumentException format:@"%@-line %d: URL pattern error not file URL", [self class], __LINE__];
    }
    
    NSString *path = [url path];
    
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

#pragma mark Check Current Device Storage Space

- (NSString *)getFreeSpaceAtPath:(NSString *)path converSizeUnit:(BOOL)conver
{
    NSError *error = nil;
    NSDictionary *fileSystemInfomation = [[NSFileManager defaultManager] attributesOfFileSystemForPath:path error:&error];
    
    if (error != nil) NSLog(@"%@", error);
    
    NSNumber *freeSpace = [fileSystemInfomation objectForKey:NSFileSystemFreeSize];
    
    NSString *size = [freeSpace stringValue];
    
    if (conver) {
        size = [self convertFileSizeWithSize:freeSpace];
    }
    
    return size;
}

- (NSNumber *)checkStorageSpace
{
    NSString *path = [self documentPath];
    
    NSString *freeSpace = [self getFreeSpaceAtPath:path converSizeUnit:NO];
    
    NSNumber *freeSpaceNumber = [NSNumber numberWithLongLong:[freeSpace longLongValue]];
    
    return freeSpaceNumber;
}

- (BOOL)checkSpaceEnoughWithFilePath:(NSString *)path
{
    NSNumber *currentSpace = [self checkStorageSpace];
    NSString *fileSizeString = [self getFileSizeAtPath:path converSizeUnit:NO];
    NSNumber *fileSize = [NSNumber numberWithLongLong:[fileSizeString longLongValue]];
    
//    NSLog(@"Free : %@, File Size : %@", currentSpace, fileSize);
    
    return ([currentSpace longLongValue] > [fileSize longLongValue]) ? YES : NO;
}

- (BOOL)checkSpaceEnoughWithFileSize:(NSNumber *)size
{
    NSNumber *currentSpace = [self checkStorageSpace];
    
//    NSLog(@"Free : %@, File Size : %@", currentSpace, size);
    
    return ([currentSpace longLongValue] > [size longLongValue]) ? YES : NO;
}

#pragma mark - Get FilePath Methods

- (NSString *)currentApplicationPath
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    
    return path;
}

- (NSString *)currentApplicationPathWithDirectoryName:(NSString *)dirName
{
    NSString *path = [self currentApplicationPath];
    NSString *pathWithDirectory = [path stringByAppendingPathComponent:dirName];
    
    return pathWithDirectory;
}

- (NSString *)documentPath
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSLog(@"Path:%@", path);
    NSString *docDir = [path objectAtIndex:0];
//    NSLog(@"%@", docDir);
    return docDir;
}

- (NSString *)documentPathWithFileName:(NSString *)fileName
{
    NSString *path = [self documentPath];
    
    return [path stringByAppendingPathComponent:fileName];
}

- (NSString *)cachesPath
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *cachesDir = [path objectAtIndex:0];
//    NSLog(@"%@", cachesDir);
    return cachesDir;
}

- (NSString *)cachesPathWithFileName:(NSString *)fileName
{
    NSString *path = [self cachesPath];
    
    return [path stringByAppendingPathComponent:fileName];
}

- (NSString *)LibraryPath
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);

    NSString *libDir = [path objectAtIndex:0];
    
    return libDir;
}

- (NSString *)tempPath
{
//    NSArray *path = NSSearchPathForDirectoriesInDomains(NSTemporaryDirectory(), NSUserDomainMask, YES);
    return nil;
}

#pragma mark - Read file Methods

- (NSString *)readStringFromPath:(NSString *)filePath
{
//    NSLog(@"Read Path:%@",filePath);
    if ([self fileExistAtPath:filePath]) {
        NSString *string = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        return string;
    } else {
        return nil;
    }
}

- (NSDictionary *)readDictionaryFromFilePath:(NSString *)filePath
{
    if ([self fileExistAtPath:filePath]) {
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
        return dic;
    } else {
        return nil;
    }
}

- (NSArray *)readArrayFromPath:(NSString *)filePath
{
    if ([self fileExistAtPath:filePath]) {
        NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
        return array;
    } else {
        return nil;
    }
}


#pragma mark - Write Data To File Methods

- (void)writeStringFile:(NSString *)string withFilePath:(NSString *)filePath
{
    [string writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)writeArrayFile:(NSArray *)array withFilePath:(NSString *)filePath
{
    [array writeToFile:filePath atomically:YES];
} 

- (void)writeDictionaryToFile:(NSDictionary *)dictionary withFilePath:(NSString *)filePath
{
    [dictionary writeToFile:filePath atomically:YES];
}

#pragma mark - Create File Or Directory

- (BOOL)createDirectoryUnderDocument:(NSString *)directory
{
    // Create directory
    NSString *folderPathUnderDirectory = [[self documentPath] stringByAppendingPathComponent:directory];
    
    return [self createDirectoryAtPath:folderPathUnderDirectory];
}

- (BOOL)createDirectoryUnderCaches:(NSString *)directory
{
    NSString *folderPathUnderCaches = [[self cachesPath] stringByAppendingPathComponent:directory];
    
    return [self createDirectoryAtPath:folderPathUnderCaches];
}

- (BOOL)createDirectoryAtPath:(NSString *)path
{
    NSError *error = nil;
    
    if ([self fileExistAtPath:path])    //Does directory already exist?
    {
        return NO;
    }
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                   withIntermediateDirectories:NO
                                                    attributes:nil
                                                         error:&error]){
        NSLog(@"%@", error);
        
        return NO; // Create failed
    }
    
    return YES;
}

- (BOOL)createFile:(NSString *)fileName directoryUnderDocument:(NSString *)directory
{
    if (directory == nil) {
        // Create file under Document
        NSString *localFilePath = [[self documentPath] stringByAppendingPathComponent:fileName];
        
        [self createFileWithPath:localFilePath];
        NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:localFilePath];
        if (!handle) {
            return NO;
        } else {
            return YES;
        }
    }
    
    NSString *path = [self documentPathWithFileName:[directory stringByAppendingPathComponent:fileName]];
    
    if ([self createDirectoryUnderDocument:directory]) {
        [self createFileWithPath:path];
        NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:path];
        
        if (!handle) {
            return NO;
        } else {
            return YES;
        }
    }
   
    return NO;
}

- (BOOL)createFileWithPath:(NSString *)path
{
   return [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
}

#pragma mark - Get Files In Directory

- (NSArray *)filesOfCurrentDirectoryName:(NSString *)dirName
{
    NSString *path = [self currentApplicationPathWithDirectoryName:dirName];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
    return files;
}

- (NSArray *)getFilesWithDirectoryPath:(NSString *)path
{
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
    return files;
}

- (NSArray *)convertFullPathWithFiles:(NSArray *)files path:(NSString *)path
{
    NSMutableArray *convertedFiles = [NSMutableArray array];
    
    void (^block) (NSString *, NSUInteger, BOOL *) = ^(NSString *file, NSUInteger idx, BOOL *stop){
        NSString *fullPath = [path stringByAppendingPathComponent:file];
        
        [convertedFiles addObject:fullPath];
    };
    
    [files enumerateObjectsUsingBlock:block];
    
    return convertedFiles;
}

#pragma mark - File Process
#pragma mark Remove File

- (BOOL)removeFileAtPath:(NSString *)path
{
    NSError *error = nil;
    BOOL isRemove = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    
    if (error != nil)
        NSLog(@"%@", error);
    
    return isRemove;
}

#pragma mark Copy File

- (BOOL)copyFileAtPath:(NSString *)path toPath:(NSString *)toPath
{
    NSError *error = nil;
    BOOL isCopy = [[NSFileManager defaultManager] copyItemAtPath:path toPath:toPath error:&error];
    
    if (error != nil)
        NSLog(@"%@", error);
    
    return isCopy;
}

- (void)copyFileUseBlockAtPath:(NSString *)path toPath:(NSString *)toPath completion:(FCCompletionBlock)completion
{
    QueueBlock copyQueueBlock = ^(){
        
        NSError *error = nil;
        BOOL copyDone = [[NSFileManager defaultManager] copyItemAtPath:path toPath:toPath error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            completion(copyDone, error);
        });
    };
    
    dispatch_queue_t copyQueue = dispatch_queue_create("Copy Queue", NULL);
    dispatch_async(copyQueue, copyQueueBlock);
}

#pragma mark Move File

- (BOOL)moveFileAtPath:(NSString *)path toPath:(NSString *)toPath
{
    NSError *error = nil;
    BOOL isMove = [[NSFileManager defaultManager] moveItemAtPath:path toPath:toPath error:&error];
    
    if (error != nil)
        NSLog(@"%@", error);
    
    return isMove;
}

- (void)moveFileUseBlockAtPath:(NSString *)path toPath:(NSString *)toPath completion:(FCCompletionBlock)completion
{
    QueueBlock moveQueueBlock = ^(){
        
        NSError *error = nil;
        BOOL moveDone = [[NSFileManager defaultManager] moveItemAtPath:path toPath:toPath error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            completion(moveDone, error);
        });
    };
    
    dispatch_queue_t moveQueue = dispatch_queue_create("Move Queue", NULL);
    dispatch_async(moveQueue, moveQueueBlock);
}

#pragma mark - Get File Information

- (NSDictionary *)getFileInformationAtPath:(NSString *)path
{
    NSError *error = nil;
    NSDictionary *fileInformation = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    
    if (error != nil)
        NSLog(@"%@", error);
    
    return fileInformation;
}

#pragma mark File Size

- (NSString *)getFileSizeAtPath:(NSString *)path converSizeUnit:(BOOL)conver
{
    NSNumber *fileSize = [[self getFileInformationAtPath:path] objectForKey:NSFileSize];
    
    NSString *size = [fileSize stringValue];
    
    if (conver) {
        size = [self convertFileSizeWithSize:fileSize];
    }
    
    return size;
}

#pragma mark File Creation Date

- (NSDate *)getFileCreationDateAtPath:(NSString *)path
{
    NSDate *creationDate = [[self getFileInformationAtPath:path] objectForKey:NSFileCreationDate];
    
    return creationDate;
}

- (NSString *)getFileCreationDateAtPath:(NSString *)path dateFormat:(NSString *)format
{
    NSDate *creationDate = [self getFileCreationDateAtPath:path];
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    [dateFormat setDateFormat:format];
    
    NSString *dateString = [dateFormat stringFromDate:creationDate];
    [dateFormat release];
    
    return dateString;
}

#pragma mark File Modification Date

- (NSDate *)getFileModificationDateAtPath:(NSString *)path
{
    NSDate *modificationDate = [[self getFileInformationAtPath:path] objectForKey:NSFileModificationDate];
    
    return modificationDate;
}

- (NSString *)getFileModificationDateAtPath:(NSString *)path dateFormat:(NSString *)format
{
    NSDate *modificationDate = [self getFileModificationDateAtPath:path];
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    [dateFormat setDateFormat:format];
    
    NSString *dateString = [dateFormat stringFromDate:modificationDate];
    [dateFormat release];
    
    return dateString;
}

#pragma mark - Convert File Size

- (NSString *)convertFileSizeWithSize:(NSNumber *)fileSize
{
    float _fileSize = [fileSize floatValue];
    NSString *fileSizeString = [NSString stringWithFormat:@"%.1f B", roundf(_fileSize * 10) / 10];
    
    if (_fileSize > 1024.0f) {
        _fileSize /= 1024.0f;
        
        fileSizeString = [NSString stringWithFormat:@"%.1f KB", roundf(_fileSize * 10) / 10];
    }
    
    if (_fileSize > 1024.0f) {
        _fileSize /= 1024.0f;
        
        fileSizeString = [NSString stringWithFormat:@"%.1f MB", roundf(_fileSize * 10) / 10];
    }
    
    if (_fileSize > 1024.0f) {
        _fileSize /= 1024.0f;
        
        fileSizeString = [NSString stringWithFormat:@"%.1f GB", roundf(_fileSize * 10) / 10];
    }
    
    return fileSizeString;
}

@end