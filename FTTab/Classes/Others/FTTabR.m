//  Generate by Oribt Pod Tool
//  Created by Inso

#import "FTTabR.h"

@implementation FTTabImage

- (UIImage *)TAB_DARK_IM_SELECTED {
    return [FTTabImage FTTab_xcassetImageNamed:@"tab_dark_IM_selected"];
}

- (UIImage *)TAB_DARK_IM_UN_SELECTED {
    return [FTTabImage FTTab_xcassetImageNamed:@"tab_dark_IM_unSelected"];
}

- (UIImage *)TAB_DARK_MALL_SELECTED {
    return [FTTabImage FTTab_xcassetImageNamed:@"tab_dark_mall_selected"];
}

- (UIImage *)TAB_DARK_MALL_UN_SELECTED {
    return [FTTabImage FTTab_xcassetImageNamed:@"tab_dark_mall_unSelected"];
}

- (UIImage *)TAB_DARK_ME_SELECTED {
    return [FTTabImage FTTab_xcassetImageNamed:@"tab_dark_me_selected"];
}

- (UIImage *)TAB_DARK_ME_UN_SELECTED {
    return [FTTabImage FTTab_xcassetImageNamed:@"tab_dark_me_unSelected"];
}

- (UIImage *)TAB_DARK_PLUS {
    return [FTTabImage FTTab_xcassetImageNamed:@"tab_dark_plus"];
}

- (UIImage *)TAB_DARK_VIDEO_SELECTED {
    return [FTTabImage FTTab_xcassetImageNamed:@"tab_dark_video_selected"];
}

- (UIImage *)TAB_DARK_VIDEO_UN_SELECTED {
    return [FTTabImage FTTab_xcassetImageNamed:@"tab_dark_video_unSelected"];
}

- (UIImage *)TAB_LIGHT_IM_SELECTED {
    return [FTTabImage FTTab_xcassetImageNamed:@"tab_light_IM_selected"];
}

- (UIImage *)TAB_LIGHT_IM_UN_SELECTED {
    return [FTTabImage FTTab_xcassetImageNamed:@"tab_light_IM_unSelected"];
}

- (UIImage *)TAB_LIGHT_MALL_SELECTED {
    return [FTTabImage FTTab_xcassetImageNamed:@"tab_light_mall_selected"];
}

- (UIImage *)TAB_LIGHT_MALL_UN_SELECTED {
    return [FTTabImage FTTab_xcassetImageNamed:@"tab_light_mall_unSelected"];
}

- (UIImage *)TAB_LIGHT_ME_SELECTED {
    return [FTTabImage FTTab_xcassetImageNamed:@"tab_light_me_selected"];
}

- (UIImage *)TAB_LIGHT_ME_UN_SELECTED {
    return [FTTabImage FTTab_xcassetImageNamed:@"tab_light_me_unSelected"];
}

- (UIImage *)TAB_LIGHT_PLUS_SELECTED {
    return [FTTabImage FTTab_xcassetImageNamed:@"tab_light_plus_selected"];
}

- (UIImage *)TAB_LIGHT_PLUS_UN_SELECTED {
    return [FTTabImage FTTab_xcassetImageNamed:@"tab_light_plus_unSelected"];
}

- (UIImage *)TAB_LIGHT_VIDEO_SELECTED {
    return [FTTabImage FTTab_xcassetImageNamed:@"tab_light_video_selected"];
}

- (UIImage *)TAB_LIGHT_VIDEO_UN_SELECTED {
    return [FTTabImage FTTab_xcassetImageNamed:@"tab_light_video_unSelected"];
}

+ (nullable UIImage *)FTTab_xcassetImageNamed:(NSString *)name {
    if(name &&
      ![name isEqualToString:@""]){
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSURL *url = [bundle URLForResource:@"FTTab" withExtension:@"bundle"];
        if(!url) return [UIImage new];
        NSBundle *imageBundle = [NSBundle bundleWithURL:url];
        UIImage *image = [UIImage imageNamed:name inBundle:imageBundle compatibleWithTraitCollection:nil];
        return image;
    }
    return nil;
}
@end

@implementation FTTabR

static FTTabImage *_img = nil;

+ (FTTabImage *)image {
    if (!_img) {
        _img = [FTTabImage new];
    }
    return _img;
}

+ (void)setImage:(FTTabImage *)image {
    _img = image;
}

@end
