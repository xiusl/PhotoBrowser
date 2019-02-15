//
//  ViewController.m
//  PhotoBrowser
//
//  Created by xiusl on 2019/2/15.
//  Copyright © 2019 Instance. All rights reserved.
//

#import "ViewController.h"
#import <UIImageView+WebCache.h>
#import "SLPhotoBrowser.h"

#define kScreenSize [UIScreen mainScreen].bounds.size
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
@interface ViewController ()
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, weak) UIView *imagesView;
@end

@implementation ViewController

- (NSArray *)images {
    if (!_images) {
        NSDictionary *dict = @{
                               @"small": @"https://tpc.googlesyndication.com/simgad/6315776724983511804",
                               @"origin": @"https://tpc.googlesyndication.com/simgad/6315776724983511804",
                               };
        
        _images = @[dict,dict,dict];
    }
    return _images;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(16, 120, kScreenWidth-32, kScreenWidth-32);
    //    view.backgroundColor = ;
    [self.view addSubview:view];
    self.imagesView = view;
    
    CGFloat m = 6;
    CGFloat w = (kScreenWidth-32-m*2)/3.0;
    int i = 0;
    for (NSDictionary *image in self.images) {
        NSInteger row = i / 3;
        NSInteger col = i % 3;
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(col*w+col*m, row*w+row*m, w, w);
        imageView.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:0.1];
        NSString *name = image[@"small"];
        [imageView sd_setImageWithURL:[NSURL URLWithString:name]];
        imageView.tag = i;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(aaa:)];
        [imageView addGestureRecognizer:tap];
        [view addSubview:imageView];
        i++;
    }
}
- (void)aaa:(UITapGestureRecognizer *)tap {
    UIView *view = tap.view;
    
    SLPhotoBrowser *b = [[SLPhotoBrowser alloc] init];
    
    NSMutableArray *arr = [NSMutableArray array];
    NSInteger i = 0;
    for (NSDictionary *image in self.images) {
        SLPhoto *photo = [[SLPhoto alloc] init];
        photo.photoUrlStr = image[@"origin"];
        photo.sourceView = self.imagesView.subviews[i];
        [arr addObject:photo];
        i++;
    }
    b.photos = arr;
    b.currentIndex = view.tag;
    [b show];
}


@end
