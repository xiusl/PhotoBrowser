// 
//  SLPhotoView.m
//  SLFeedExample
//
//  Created by xiusl on 2019/2/15.
//  Copyright © 2019 Instance. All rights reserved.
//

#import "SLPhotoView.h"
#import "SLPhoto.h"
#import <UIImageView+WebCache.h>

@interface SLPhotoView () <UIGestureRecognizerDelegate>
@property (nonatomic, assign) BOOL doubleTap;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, assign) CGFloat scale;
@end
@implementation SLPhotoView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
         [self addSubview:self.imageView];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.delaysTouchesBegan = YES;
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        pan.delegate = self;
        self.imageView.userInteractionEnabled = YES;
        [self.imageView addGestureRecognizer:pan];
        
        self.canCancelContentTouches = NO;
        
        self.imageView.exclusiveTouch = YES;
        
    }
    return self;
}
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
////    if otherGestureRecognizer == scrollView.panGestureRecognizer { // or tableView.panGestureRecognizer
////        return true
////    } else {
////        return false
////    }
//    if (otherGestureRecognizer == self.panGestureRecognizer) {
//        return YES;
//    } else {
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:self];
//        if (fabs(translation.x) > fabs(translation.y)) {
//            //            self.imageView
//            return NO;
//        }
//    }
//    return YES;
//    }
//}
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    if ([NSStringFromClass([touch.view class]) isEqualToString:@"SLImageView"]) {
//        return NO;
//    }
//    return YES;
//}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint pos = [pan velocityInView:pan.view];
        if (pos.y > 0) {
            return YES;
        }
        
//        CGPoint translation = [pan translationInView:self];
//
//        if (fabs(translation.x) > fabs(translation.y)) {
//            //            self.imageView
//            return YES;
//        }
    }
    
    return NO;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    NSLog(@"%s", __func__);
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"FlyElephant---视图拖动开始");
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint location = [recognizer locationInView:self];
        
        if (location.y < 0 || location.y > self.bounds.size.height) {
            return;
        }
        CGPoint translation = [recognizer translationInView:self];
        
        
        
        NSLog(@"当前视图在View的位置:%@----平移位置:%@",NSStringFromCGPoint(location),NSStringFromCGPoint(translation));
        
//        if (fabs(translation.x) > fabs(translation.y)) {
////            self.imageView
//            return;
//        }
        
        CGFloat centerY = recognizer.view.center.y + translation.y;
        
        
        CGFloat scale = 1-fabs(centerY-[UIScreen mainScreen].bounds.size.height/2.0) / ([UIScreen mainScreen].bounds.size.height/2.0);
        NSLog(@"%f--%f", centerY, scale);
        self.imageView.transform = CGAffineTransformMakeScale(scale, scale);
        
        recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,recognizer.view.center.y + translation.y);
        [recognizer setTranslation:CGPointZero inView:self];
        
        self.scale = scale;
        
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewDidMove:scale:)]) {
            [self.photoViewDelegate photoViewDidMove:self scale:scale];
        }
        
        self.photo.sourceView.image = nil;
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"FlyElephant---视图拖动结束");
        if (self.scale < 0.7) {
            [self hide];
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                self.imageView.transform = CGAffineTransformIdentity;
                self.imageView.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
            }];
            if ([self.photoViewDelegate respondsToSelector:@selector(photoViewDidMove:scale:)]) {
                [self.photoViewDelegate photoViewDidMove:self scale:1];
            }
            
            self.photo.sourceView.image = self.photo.placeholder;
        }
    }
}
- (void)setPhoto:(SLPhoto *)photo {
    _photo = photo;
    
    [self showImage];
}
- (void)showImage {
    if (self.photo.firstShow) {
        self.imageView.image = self.photo.placeholder;
        self.photo.sourceView.image = nil;
        if (!self.photo.isGif) {
            __weak typeof(self) weakSelf = self;
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.photo.photoUrlStr] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                weakSelf.photo.image = image;
                [weakSelf adjustFrame];
            }];
        }
    } else {
        [self photoStartLoad];
    }
}
- (void)adjustFrame {
    if (_imageView.image == nil) {
        return;
    }
    // 基本尺寸参数
    CGSize boundsSize = self.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height-80;
    
    CGSize imageSize = self.imageView.image.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    
    // 设置伸缩比例
    CGFloat minScale = boundsWidth / imageWidth;
    if (minScale > 1) {
        minScale = 1;
    }
    minScale = 1;
    
    CGFloat maxScale = 6.0;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxScale = maxScale / [[UIScreen mainScreen] scale];
    }
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = 1;
    
    CGRect imageFrame = CGRectMake(0, 40, boundsWidth, imageHeight * boundsWidth / imageWidth);
    // 内容尺寸
    self.contentSize = CGSizeMake(0, imageFrame.size.height);
    
    // y值
    if (imageFrame.size.height < boundsHeight) {
        imageFrame.origin.y = floorf((boundsHeight+80 - imageFrame.size.height) / 2.0);
    } else {
        imageFrame.origin.y = 0;
    }
    
    if (self.photo.firstShow) { // 第一次显示的图片
        self.photo.firstShow = NO; // 已经显示过了
        _imageView.frame = [_photo.sourceView convertRect:_photo.sourceView.bounds toView:[UIApplication sharedApplication].keyWindow];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.imageView.frame = imageFrame;
        } completion:^(BOOL finished) {
            // 设置底部的小图片
            self.photo.sourceView.image = self.photo.placeholder;
            [self photoStartLoad];
        }];
    } else {
        
//        self.photo.sourceView.image = self.photo.placeholder;
        _imageView.frame = imageFrame;
    }
}
- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    _doubleTap = NO;
    [self performSelector:@selector(hide) withObject:nil afterDelay:0.2];
}
- (void)hide
{
    if (_doubleTap) return;
    
    // 移除进度条
    self.contentOffset = CGPointZero;
    
    // 清空底部的小图
    self.photo.sourceView.image = nil;
    
    CGFloat duration = 0.15;
    if (_photo.sourceView.clipsToBounds) {
        [self performSelector:@selector(reset) withObject:nil afterDelay:duration];
    }
    
    [UIView animateWithDuration:duration + 0.1 animations:^{
        self.imageView.frame = [self.photo.sourceView convertRect:self.photo.sourceView.bounds toView:nil];
        
        // gif图片仅显示第0张
        if (self.imageView.image.images) {
            self.imageView.image = self.imageView.image.images[0];
        }
        
        // 通知代理
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewSingleTap:)]) {
            [self.photoViewDelegate photoViewSingleTap:self];
        }
    } completion:^(BOOL finished) {
        // 设置底部的小图片
        self.photo.sourceView.image = self.photo.placeholder;
        
        
        // 通知代理
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewDidEndZoom:)]) {
            [self.photoViewDelegate photoViewDidEndZoom:self];
        }
    }];
}

- (void)reset
{
//    _imageView.image = _photo.capture;
    _imageView.contentMode = UIViewContentModeScaleToFill;
}
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (void)photoStartLoad {
    if (self.photo.image) {
        self.scrollEnabled = YES;
        self.imageView.image = self.photo.image;
        [self photoDidFinishLoadWithImage:self.photo.image];
    } else {
        self.scrollEnabled = NO;

        
        __weak typeof(self) weakSelf = self;
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.photo.photoUrlStr] placeholderImage:self.photo.sourceView.image options:SDWebImageLowPriority |SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [weakSelf photoDidFinishLoadWithImage:image];
        }];
        
    }
}
- (void)photoDidFinishLoadWithImage:(UIImage *)image
{
    if (image) {
        self.scrollEnabled = YES;
        
        _photo.image = image;
//        [_photoLoadingView removeFromSuperview];
        
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewImageFinishLoad:)]) {
            [self.photoViewDelegate photoViewImageFinishLoad:self];
        }
    } else {
//        [self addSubview:_photoLoadingView];
//        [_photoLoadingView showFailure];
    }
    
    // 设置缩放比例
    [self adjustFrame];
}
@end

