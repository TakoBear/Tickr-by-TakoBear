//
//  FileControl+Camera.h
//  DTAutoUpload
//
//  Created by shouian on 13/5/13.
//
//

#import "FileControl.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface FileControl (Camera)

typedef void (^FileControlFailureBlock) (NSError *error);
typedef void (^FileControlSuccessBlock) (NSString *filePath);

- (void)copyAssetToLocal:(ALAsset *)asset withFilePath:(NSString *)filePath success:(FileControlSuccessBlock)success fail:(FileControlFailureBlock)fail;
- (void)removeTempUploadFileWithComponent:(NSString *)component;
@end
