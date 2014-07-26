//
//  DFViewController.m
//  DFImageFilterApp
//
//  Created by DF on 7/24/14.
//  Copyright (c) 2014 df. All rights reserved.
//

#import "DFViewController.h"
#import "DFImageFilter.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface DFViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *saveButtonPressed;
@property (weak, nonatomic) IBOutlet UIButton *clearImageButton;
@property (weak, nonatomic) IBOutlet UIButton *applyFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) CIImage *filteredImage;
@property (nonatomic, strong) CIContext *context;
- (IBAction)selectImagePressed:(id)sender;
- (IBAction)applyFilterPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)clearImageButtonPressed:(id)sender;
@end

@implementation DFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CIContext *)context {
    if (!_context) {
        _context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)} ];
    }
    return _context;
}


- (IBAction)selectImagePressed:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = NO;
        [self presentViewController:imagePickerController
                           animated:YES
                         completion:nil];
    }
    else {
        UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"Sorry"
                                                          message:@"library is unavailable on this device"
                                                         delegate:nil cancelButtonTitle:@"Dismiss"
                                                otherButtonTitles:nil, nil];
        [alerView show];
    }
}

- (IBAction)applyFilterPressed:(id)sender {
    self.imageView.alpha = .5f;
    [self.activityIndicator startAnimating];
   [DFImageFilter filteredImageWithImage:self.imageView.image completion:^(CIImage *filteredImage) {
       self.filteredImage = filteredImage;
       self.imageView.alpha = 1.0f;
       [self.activityIndicator stopAnimating];
       [self setupImage:[UIImage imageWithCIImage:filteredImage scale:2.0f
                                      orientation:UIImageOrientationUp]];
       self.applyFilterButton.enabled = NO;
        self.saveButton.enabled = YES;
   }];
}

- (IBAction)saveButtonPressed:(id)sender {
    [self.activityIndicator startAnimating];
    self.imageView.alpha = .5f;
    self.saveButton.enabled = NO;
    self.clearImageButton.enabled = NO;
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue, ^{
        CGImageRef cgImg = [self.context createCGImage:_filteredImage
                                              fromRect:[_filteredImage extent]];
        dispatch_async(dispatch_get_main_queue(), ^{
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeImageToSavedPhotosAlbum:cgImg
                                         metadata:nil
                                  completionBlock:^(NSURL *assetURL, NSError *error) {
                                      if (error) {
                                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                                                          message:nil
                                                                                         delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                          [alert show];
                                          self.saveButton.enabled = YES;
                                      }
                                      self.imageView.alpha = 1.0f;
                                      self.clearImageButton.enabled = YES;
                                      CGImageRelease(cgImg);
                                      [self.activityIndicator stopAnimating];
                                  }];
        });
    });
}

- (IBAction)clearImageButtonPressed:(id)sender {
    [self setupImage:nil];
}

-(void)setupImage:(UIImage *)image {
    self.imageView.image = image;
    self.applyFilterButton.enabled = image ? YES : NO;
    self.clearImageButton.enabled = image ? YES : NO;
    self.saveButton.enabled = NO;
}

#pragma mark - ImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *pickedImage = info[UIImagePickerControllerOriginalImage];
    [self setupImage:pickedImage];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"image is not selected");
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}
@end
