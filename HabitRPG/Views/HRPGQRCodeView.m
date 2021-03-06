//
//  HRPGQRCodeView.m
//  Habitica
//
//  Created by Phillip Thelen on 05/08/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGQRCodeView.h"

@interface HRPGQRCodeView ()

@property UIImageView *qrCodeView;
@property UIView *avatarView;
@property UIView *wrapperView;
@property UIView *outerWrapperView;
@property int scaling;
@end

@implementation HRPGQRCodeView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    self.qrCodeView = [[UIImageView alloc] init];
    self.qrCodeView.contentMode = UIViewContentModeCenter;
    [self addSubview:self.qrCodeView];
    
    UIGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    return self;
}

- (void)layoutSubviews {
    self.qrCodeView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self setQrCode];
    CGFloat avatarSize = self.scaling * 11;
    self.avatarView.frame = CGRectMake((self.qrCodeView.frame.size.width-avatarSize)/2, (self.qrCodeView.frame.size.height-avatarSize)/2, avatarSize, avatarSize);
    CGFloat innerSize = avatarSize-10;
    self.wrapperView.frame = CGRectMake(-innerSize, -(innerSize/2), avatarSize*2, avatarSize*2);
    self.outerWrapperView.frame = CGRectMake(5, 5, innerSize, innerSize);
}

- (void)setText:(NSString *)text {
    _text = text;
    [self setQrCode];
}

- (void)setAvatarViewWithUser:(User *)user {
    if (self.avatarView) {
        [self.avatarView removeFromSuperview];
    }
    self.avatarView = [[UIView alloc] init];
    self.avatarView.backgroundColor = [UIColor whiteColor];
    self.wrapperView = [[UIView alloc] init];
    self.outerWrapperView = [[UIView alloc] init];
    self.outerWrapperView.clipsToBounds = YES;
    [user setAvatarSubview:self.wrapperView showsBackground:NO showsMount:NO showsPet:NO];
    [self.outerWrapperView addSubview:self.wrapperView];
    [self.avatarView addSubview:self.outerWrapperView];
    [self addSubview:self.avatarView];
    [self layoutSubviews];
}

- (void)setQrCode {
    
    NSData *stringData = [self.text dataUsingEncoding:NSISOLatin1StringEncoding];
    
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    // Send the image back
    self.qrCodeView.image = [self createNonInterpolatedUIImageFromCIImage:qrFilter.outputImage];
}

- (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image {
    // Render the CIImage into a CGImage
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:image fromRect:image.extent];
    
    self.scaling = self.frame.size.width / image.extent.size.width;
    CGFloat imagesize = image.extent.size.width * self.scaling;
    // Now we'll rescale using CoreGraphics
    UIGraphicsBeginImageContext(CGSizeMake(imagesize, imagesize));
    CGContextRef context = UIGraphicsGetCurrentContext();
    // We don't want to interpolate (since we've got a pixel-correct image)
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    // Get the image out
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // Tidy up
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    return scaledImage;
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    if (self.shareAction) {
        self.shareAction();
    }
}

@end
