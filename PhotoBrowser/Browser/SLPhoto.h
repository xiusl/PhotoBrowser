// 
//  SLPhoto.h
//  SLFeedExample
//
//  Created by xiusl on 2019/2/15.
//  Copyright © 2019 Instance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLPhoto : NSObject
@property (nonatomic, copy) NSString *photoUrlStr;
@property (nonatomic, strong) UIImageView *sourceView;

@property (nonatomic, strong, readonly) UIImage *placeholder;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) BOOL firstShow;
@property (nonatomic, assign) BOOL isGif;
@property (nonatomic, assign) BOOL saved;

@property (nonatomic, assign) NSInteger index;
@end

NS_ASSUME_NONNULL_END
