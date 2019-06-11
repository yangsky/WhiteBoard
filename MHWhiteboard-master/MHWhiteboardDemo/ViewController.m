//
//  ViewController.m
//  MHWhiteboardDemo
//
//  Created by MakeHui on 10/1/19.
//  Copyright © 2019年 MakeHui. All rights reserved.
//

#import "ViewController.h"
#import <MHWhiteboard/MHWhiteboard.h>
#import <AVOSCloud/AVOSCloud.h>

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UIImagePickerController *_foregroundPicker;
    UIImagePickerController *_backgroundPicker;
}

@property (weak, nonatomic) IBOutlet MHWhiteboardView *whiteboardView;
@property (weak, nonatomic) IBOutlet UIStackView *toolsView;
@property (weak, nonatomic) IBOutlet UIStackView *darwWidthView;
@property (weak, nonatomic) IBOutlet UIStackView *colorsView;
@property (weak, nonatomic) IBOutlet UIStackView *clearView;
@property (weak, nonatomic) IBOutlet UIStackView *graphView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _foregroundPicker = ({
        UIImagePickerController *picker = [UIImagePickerController new];
        [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        picker.delegate = self;
        picker;
    });
    
    _backgroundPicker = ({
        UIImagePickerController *picker = [UIImagePickerController new];
        [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        picker.delegate = self;
        picker;
    });
}

- (void)viewDidAppear:(BOOL)animated
{
//    AVQuery *query = [AVQuery queryWithClassName:@"TestObject"];
//    [query getObjectInBackgroundWithId:@"5cf77aaed5de2b0070f16d2c" block:^(AVObject *object, NSError *error) {
//        // object 就是 id 为 558e20cbe4b060308e3eb36c 的 Todo 对象实例
//        // 如果 objectId 不存在，会报错 kAVErrorObjectNotFound
//
//        if (object) {
//            NSString *url = [object objectForKey:@"foo"];
//            NSLog(@"url:%@", url);
//        }
//
//    }];
//    
//    [super viewDidAppear:YES];
//    AVObject *testObject = [AVObject objectWithClassName:@"TestObject"];
//    [testObject setObject:@"bar" forKey:@"foo"];
//    [testObject save];

}

- (IBAction)onOpenColorViewTouchUpInside:(id)sender
{
    [self showView:self.colorsView];
    AVQuery *query = [AVQuery queryWithClassName:@"TestObject"];
    [query getObjectInBackgroundWithId:@"5cf77aaed5de2b0070f16d2c" block:^(AVObject *object, NSError *error) {
        // object 就是 id 为 558e20cbe4b060308e3eb36c 的 Todo 对象实例
        // 如果 objectId 不存在，会报错 kAVErrorObjectNotFound
        
        if (object) {
            NSString *url = [object objectForKey:@"foo"];
            NSLog(@"url:%@", url);
        }
        
    }];
}

- (IBAction)onOpenWidthViewTouchUpInside:(id)sender
{
    [self showView:self.darwWidthView];
}

- (IBAction)onSelectForegroundImageTouchUpInside:(id)sender
{
    self.whiteboardView.pathModelAction = MHPathModelActionInsertImage;
    [self presentViewController:_foregroundPicker animated:YES completion:nil];
}

- (IBAction)onSelectBackgroundImageTouchUpInside:(id)sender
{
    [self presentViewController:_backgroundPicker animated:YES completion:nil];
}

- (IBAction)onEraserTouchUpInside:(id)sender
{
    self.whiteboardView.brushColor = self.whiteboardView.backgroundColor;
}

- (IBAction)onUndoTouchUpInside:(id)sender
{
    [self.whiteboardView undo];
}

- (IBAction)onRepeatTouchUpInside:(id)sender
{
    [self.whiteboardView repeatGraph];
}

- (IBAction)onClearTouchUpInside:(id)sender
{
    [self.whiteboardView clearAllGraph];
}

- (IBAction)onClearBackgroundImageTouchUpInside:(id)sender
{
    [self.whiteboardView clearBackgroundImage];
}

- (IBAction)onSelectWidthTouchUpInside:(UIButton *)sender
{
    if (sender.tag == 105) {
        [self showView:self.toolsView];
    }
    else {
        self.whiteboardView.brushWidth = (sender.tag - 100) * 5;
    }
}

- (IBAction)onSelectGraphTouchUpInisde:(UIButton *)sender
{
    self.whiteboardView.pathModelAction = 1 << (sender.tag - 85);
    
    if (sender.tag == 105) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"변"
                                                                                  message: @"입력 변수"
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        __weak typeof(self) weakSelf = self;
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"수";
            textField.textColor = [UIColor blueColor];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.text = @(weakSelf.whiteboardView.polygonSides).stringValue;
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"확정" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSArray * textfields = alertController.textFields;
            UITextField *sidesField = textfields[0];
            if (sidesField.text.length) {
                weakSelf.whiteboardView.polygonSides = sidesField.text.integerValue;
            }
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (IBAction)onSelectColorTouchUpInside:(UIButton *)sender
{
    if (sender.tag == 105) {
        [self showView:self.toolsView];
    }
    else {
        self.whiteboardView.brushColor = sender.preferredFocusedView.backgroundColor;
    }
}

- (IBAction)onToolsViewTouchUpInside:(UIButton *)sender
{
    if (sender.tag == 101) {
        [self showView:self.toolsView];
    }
    else if (sender.tag == 102) {
        [self showView:self.clearView];
    }
    else {
        [self showView:self.graphView];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];

    if (picker == _foregroundPicker) {
        [self.whiteboardView insertImageGraph:image];
    }
    else if (picker == _backgroundPicker) {
        [self.whiteboardView setBackgroundImage:image];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showView:(UIView *)view
{
    self.clearView.hidden = true;
    self.toolsView.hidden = true;
    self.colorsView.hidden = true;
    self.darwWidthView.hidden = true;
    self.graphView.hidden = true;
    view.hidden = false;
}

@end
