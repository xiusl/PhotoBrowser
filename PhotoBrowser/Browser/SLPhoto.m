// 
//  SLPhoto.m
//  SLFeedExample
//
//  Created by xiusl on 2019/2/15.
//  Copyright © 2019 Instance. All rights reserved.
//

#import "SLPhoto.h"

@implementation SLPhoto
- (void)setSourceView:(UIImageView *)sourceView {
    _sourceView = sourceView;
    
    _placeholder = sourceView.image;
}
@end
