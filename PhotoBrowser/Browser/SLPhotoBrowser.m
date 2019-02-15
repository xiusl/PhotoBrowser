// 
//  SLPhotoBrowser.m
//  SLFeedExample
//
//  Created by xiusl on 2019/2/15.
//  Copyright © 2019 Instance. All rights reserved.
//

#import "SLPhotoBrowser.h"
#import "SLPhotoView.h"
#define kPadding 10
#define kPhotoViewTagOffset 1000
#define kPhotoViewIndex(photoView) ([photoView tag] - kPhotoViewTagOffset)

@interface SLPhotoBrowser () <UIScrollViewDelegate, SLPhotoViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableSet *visibleViews;
@property (nonatomic, strong) NSMutableSet *reusableViews;
@end
@implementation SLPhotoBrowser
- (void)loadView {
    self.view = [[UIView alloc] init];
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor colorWithRed:55/255.0
                                                green:55/255.0
                                                 blue:55/255.0
                                                alpha:1.0];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupScrollView];
    
}
- (void)show {
//    [UIView animateWithDuration:0.2 animations:^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:self.view];
        [window.rootViewController addChildViewController:self];
        
        if (self.currentIndex == 0) {
            [self showPhotos];
        }
//    }];
}

- (void)setupScrollView {
    CGRect frame = self.view.bounds;
    frame.origin.x -= kPadding;
    frame.size.width += (2 * kPadding);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.contentSize = CGSizeMake(frame.size.width * self.photos.count, 0);
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
    
    scrollView.contentOffset = CGPointMake(self.currentIndex*frame.size.width, 0);
    
    
}
- (void)setPhotos:(NSArray<SLPhoto *> *)photos {
    _photos = photos;
    
    if (photos.count > 1) {
        _visibleViews = [NSMutableSet set];
        _reusableViews = [NSMutableSet set];
    }
    
    for (int i = 0; i<_photos.count; i++) {
        SLPhoto *photo = _photos[i];
        photo.saved = NO;
        photo.index = i;
        photo.firstShow = (i == self.currentIndex);
    }
}
- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    
    for (int i = 0; i<_photos.count; i++) {
        SLPhoto *photo = _photos[i];
        photo.firstShow = (i == currentIndex);
    }
    if ([self isViewLoaded]) {
        self.scrollView.contentOffset = CGPointMake(currentIndex * self.scrollView.frame.size.width, 0);
        
        // 显示所有的相片
        [self showPhotos];
    }
}
- (void)showPhotos {
    if (self.photos.count == 1) {
        [self showPhotoViewAtIndex:0];
        return;
    }
    
    CGRect visibleBounds = self.scrollView.bounds;
    int firstIndex = (int)(CGRectGetMinX(visibleBounds)+kPadding*2) / CGRectGetWidth(visibleBounds);
    int lastIndex  = (int)(CGRectGetMaxX(visibleBounds)-kPadding*2-1) / CGRectGetWidth(visibleBounds);
    if (firstIndex < 0) firstIndex = 0;
    if (firstIndex >= self.photos.count) firstIndex = (int)self.photos.count - 1;
    if (lastIndex < 0) lastIndex = 0;
    if (lastIndex >= self.photos.count) lastIndex = (int)self.photos.count - 1;
    
    // 回收不再显示的ImageView
    NSInteger photoViewIndex;
    for (SLPhotoView *photoView in self.visibleViews) {
        photoViewIndex = kPhotoViewIndex(photoView);
        if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
            [self.reusableViews addObject:photoView];
            [photoView removeFromSuperview];
        }
    }
    
    [self.visibleViews minusSet:self.reusableViews];
    while (self.reusableViews.count > 2) {
        [self.reusableViews removeObject:[self.reusableViews anyObject]];
    }
    
    for (NSUInteger index = firstIndex; index <= lastIndex; index++) {
        if (![self isShowingPhotoViewAtIndex:index]) {
            [self showPhotoViewAtIndex:(int)index];
        }
    }
}
- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index {
    for (SLPhotoView *photoView in self.visibleViews) {
        if (kPhotoViewIndex(photoView) == index) {
            return YES;
        }
    }
    return  NO;
}
- (void)showPhotoViewAtIndex:(NSInteger)index
{
    SLPhotoView *photoView = [self dequeueReusablePhotoView];
    if (!photoView) { // 添加新的图片view
        photoView = [[SLPhotoView alloc] init];
        photoView.photoViewDelegate = self;
    }
    
    // 调整当期页的frame
    CGRect bounds = self.scrollView.bounds;
    CGRect photoViewFrame = bounds;
    photoViewFrame.size.width -= (2 * kPadding);
    photoViewFrame.origin.x = (bounds.size.width * index) + kPadding;
    photoView.tag = kPhotoViewTagOffset + index;
    
    SLPhoto *photo = _photos[index];
    photoView.frame = photoViewFrame;
    photoView.photo = photo;
    
    [_visibleViews addObject:photoView];
    [self.scrollView addSubview:photoView];
    
//    [self loadImageNearIndex:index];
}
- (SLPhotoView *)dequeueReusablePhotoView {
    SLPhotoView *photoView = [_reusableViews anyObject];
    if (photoView) {
        [_reusableViews removeObject:photoView];
    }
    return photoView;
}
- (void)photoViewSingleTap:(SLPhotoView *)photoView
{
    
//    [UIApplication sharedApplication].statusBarStyle = self.barStyle;
//    [UIApplication sharedApplication].statusBarHidden = _statusBarHiddenInited;
    self.view.backgroundColor = [UIColor clearColor];
    
}

- (void)photoViewDidEndZoom:(SLPhotoView *)photoView
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)photoViewImageFinishLoad:(SLPhotoView *)photoView
{
}
- (void)photoViewDidMove:(SLPhotoView *)photoView scale:(CGFloat)scale {
    self.view.backgroundColor = [UIColor colorWithRed:55/255.0
                                                green:55/255.0
                                                 blue:55/255.0
                                                alpha:scale];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self showPhotos];
}
@end
