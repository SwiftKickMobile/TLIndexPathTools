//
//  TLIndexPathController.h
//
//  Copyright (c) 2013 Tim Moose (http://tractablelabs.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>

#import "TLIndexPathDataModel.h"
#import "TLIndexPathUpdates.h"

//sent whenever a TLIndexPathController changes it's content for any reason
extern NSString * const TLIndexPathControllerChangedNotification;

@class TLIndexPathController;

#pragma mark - TLIndexPathControllerDelegate

/**
 An instance of `TLIndexPathController` uses this protocol to notify it's delegate
 about batch changes to the data model, providing access to the `TLIndexPathDataModelUpdates`
 instance which can be uses to perform batch updates on a table or collection view.
 */
@protocol TLIndexPathControllerDelegate <NSObject>

@optional

/**
 Notifies the reciever of batch data model changes.
 
 @param controller  the index path controller that sent the message.
 @param updates  the updates object that can be used to perform batch updates on a table or collection view.
 
 */
- (void)controller:(TLIndexPathController *)controller didUpdateDataModel:(TLIndexPathUpdates *)updates;

@end

@interface TLIndexPathController : NSObject

#pragma mark - Initialization

/**
 Returns an index path controller initialized with the given items.
 
 @param items  the aray of items
 @return the index path controller with a default data model representation of the given items
 
 A default data model is initialized with items where the properties `identifierKeyPath`,
 `sectionNameKeyPath` and `cellIdentifierKeyPath` are all `nil`. If any of
 these are required, use `initWithDataModel:` instead.
 */
- (instancetype)initWithItems:(NSArray *)items;

/**
 Returns an index path controller initialized with the given TLIndexPathItmes.
 
 @param items  the array of TLIndexPathItems
 @return the index path controller with a default data model representation of the given TLIndexPathItems
 
 This initilizer differs from `initWithItems:` only in that the properties
 `identifierKeyPath`, `sectionNameKeyPath` and `cellIdentifierKeyPath` are
 not nil, but rather the appropriate values for TLIndexPathItem.
 */
- (instancetype)initWithIndexPathItems:(NSArray *)items;

/**
 Returns an index path controller initialized with the given data model.
 
 @param dataModel  the data model
 @return the index path controller with the given data model representation
 */
- (instancetype)initWithDataModel:(TLIndexPathDataModel *)dataModel;

#pragma mark - Configuration information

/**
 The controller's delegate.
 */
@property (weak, nonatomic) id<TLIndexPathControllerDelegate>delegate;

#pragma mark - Accessing data

/**
 The items being tracked by the controller.
 
 Setting this property causes a new data model to be created and any changes propagated
 to the controller's delegate. This new data model preserves the configuration of
 the previous data model. The type of items need not necessarily be the same
 as the previous data model, provided they are consistent with the configuration,
 such as `indetifierKeyPath`. If the new data model requires a different configuration,
 set the `dataModel` property directly.
 */
@property (strong, nonatomic) NSArray *items;

/**
 The data model representation of the items being tracked by the controller.
 
 Setting this property causes the any changes to be propagated to the controller's
 delegate. The type of items and configuration of the new data model need not
 necessarily be the same as the previous data model, provided that the controller's
 delegate is prepared to handle the changes.
 */
@property (strong, nonatomic) TLIndexPathDataModel *dataModel;

@end
