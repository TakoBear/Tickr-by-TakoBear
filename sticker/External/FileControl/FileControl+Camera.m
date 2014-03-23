//
//  FileControl+Camera.m
//  DTAutoUpload
//
//  Created by shouian on 13/5/13.
//
//

#import "FileControl+Camera.h"

@implementation FileControl (Camera)

- (void)copyAssetToLocal:(ALAsset *)asset withFilePath:(NSString *)filePath success:(FileControlSuccessBlock)success fail:(FileControlFailureBlock)fail
{
    // Load asset to buffer by 102400 byte every time, and save to local path, and transfer to NSData, delete local file after
    NSUInteger chunkSize = 100 * 1024;
    uint8_t *buffer = malloc(chunkSize * sizeof(uint8_t));
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    NSUInteger length = [rep size];
    
    NSString *localFilePath = [[self documentPath] stringByAppendingPathComponent:filePath];
    
    [[NSFileManager defaultManager] createFileAtPath:localFilePath contents:nil attributes:nil];
    NSFileHandle *handle = [[NSFileHandle fileHandleForWritingAtPath:localFilePath] retain];
    
    if (!handle){
        // Handle error
        NSLog(@"create error");
        fail(nil);
    }
    
    NSError *error = nil;
    NSUInteger offset = 0;
    do {
        NSUInteger bytesCopied = [rep getBytes:buffer fromOffset:offset length:chunkSize error:&error];
        offset += bytesCopied;
        NSData *data = [[NSData alloc] initWithBytes:buffer length:bytesCopied];
        
        @try {
            [handle writeData:data];
        } @catch (NSException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                fail(error);
            });
            return;
        }
        [data release];
    } while (offset < length);
    
    [handle closeFile];
    [handle release];
    free(buffer);
    
    buffer = NULL;
    
    success(localFilePath);
    
}

- (void)removeTempUploadFileWithComponent:(NSString *)component {
    
    // Remove file in local path
    NSString *documentsDirectory = [self documentPath];
    NSString *localFilePath = [documentsDirectory stringByAppendingPathComponent:component];
    [[NSFileManager defaultManager] removeItemAtPath:localFilePath error:nil];
}
@end
