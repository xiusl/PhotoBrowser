// 
//  SLPhotoView.h
//  SLFeedExample
//
//  Created by xiusl on 2019/2/15.
//  Copyright © 2019 Instance. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SLPhoto, SLPhotoView;
NS_ASSUME_NONNULL_BEGIN

@protocol SLPhotoViewDelegate <NSObject>
- (void)photoViewImageFinishLoad:(SLPhotoView *)photoView;
- (void)photoViewSingleTap:(SLPhotoView *)photoView;
- (void)photoViewDidEndZoom:(SLPhotoView *)photoView;
- (void)photoViewDidMove:(SLPhotoView *)photoView scale:(CGFloat)scale;
@end


@interface SLPhotoView : UIScrollView
@property (nonatomic, strong) SLPhoto *photo;
@property (nonatomic, weak) id<SLPhotoViewDelegate> photoViewDelegate;
@end

NS_ASSUME_NONNULL_END
