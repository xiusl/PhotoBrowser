// 
//  SLPhotoBrowser.h
//  SLFeedExample
//
//  Created by xiusl on 2019/2/15.
//  Copyright © 2019 Instance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLPhoto.h"

@protocol SLPhotoBrowserDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface SLPhotoBrowser : UIViewController
@property (nonatomic, strong) NSArray<SLPhoto *> *photos;
@property (nonatomic, assign) NSInteger currentIndex;

- (void)show;

@property (nonatomic, weak) id<SLPhotoBrowserDelegate> delegate;
@end


@protocol SLPhotoBrowserDelegate <NSObject>
@optional
- (void)photoBrowser:(SLPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index;
@end
NS_ASSUME_NONNULL_END
