TLIndexPathTools
================

TLIndexPathTools is a set of components designed to greatly simplify building
rich, dynamic table and collection views. Here are some of the awesome things that TLIndexPathTools does:

* Automatically calculate and perform animated inserts, deletes and moves.
* Automatically organize the data model into sections.
* Simplify implementing data source and delegate methods via rich data model APIs.
* Provide a simpler alternative to Core Data's `NSFetchedResultsController`

##Installation

1. Download the TLIndexPathTools project
2. Add the TLIndexPathTools sub-folder (sibling of the Examples folder) to your Xcode project.
3. Link to QuartzCore.framework and CoreData.framework (on the Build Phases tab of your project's target).

<!--CoreData is required for Core Data integration and because `TLIndexPathSectionInfo` implements the `NSFetchedResultsSectionInfo` protocol. QuartzCore is required because the Grid extension uses it.-->

##Overview

Table and collection view batch updates (inserts, deletes and moves) are great because they provide the smooth animation everyone loves. But if you've ever written batch update code, you may have found that they can make your view controller's implementation very complex (and confusing). TLIndexPathTools makes all of this very easy by providing two simple classes to do the bookkeeping and perform the batch updates for you. `TLIndexPathDataModel` does the bookkeeping. It can organize your data into sections and provides a rich API to simplify implementing data source and delegate methods. `TLIndexPathUpdates` performs the batch updates. All you've got to do is provide two versions of your data model.

Most of the functionality in TLIndexPathTools can be accomplished with just `TLIndexPathDataModel` and `TLIndexPathUpdates`. However, there are a number of additional components that build on these classes to make life a little bit easier.

* `TLIndexPathController` provides a common programming model for building view controllers that work interchangeably with Core Data `NSFetchRequests` or plain arrays. One controller to rule them all.
* `TLTableViewController` and `TLCollectionViewController` are base  table and collection view implementations that provide the essential data source and delegate methods to get you up and running quickly with a few bells and whistles, like data-driven table cell height calculation, thrown in for good measure.
* `TLIndexPathItem` is a wrapper class for your data items, useful for things like heterogenous data or multiple cell prototypes. Take a look at the [Settings sample project][1], for example.
* The `Extensions` folder contains a number of extensions for things like [collapsable sections][2] and [expandable tree views][3]. This is a good resource to see how `TLIndexPathDataModel` can be easily extended for special data structures.
* And last, but not least, the `Examples` folder contains numerous sample projects demonstrating various use cases and features of the framework. [Shuffle][4] is a good starting point and be sure to try [Core Data][5].

This version of TLIndexPathTools is designed to handle up to a few thousand items. Larger data sets may not perform well.

###TLIndexPathDataModel

`TLIndexPathDataModel` is an immutable object you use in your view controller to hold your data items instead of an array. There are three initializers, a basic one and two handling multiple sections:

```Objective-C
// single section initializer
TLIndexPathDataModel dataModel1 = [TLIndexPathDataModel alloc] initWithItems:items];

// multiple sections defined by item key path
TLIndexPathDataModel dataModel2 = [TLIndexPathDataModel alloc] initWithItems:items sectionNameKeyPath:@"someKeyPath" identifierKeyPath:nil];

// multiple explicitly defined sections (including an empty section)
TLIndexPathSectionInfo section1 = [TLIndexPathSectionInfo alloc] initWithItems:@[@"Item 1.1"] name:@"Section 1"];
TLIndexPathSectionInfo section2 = [TLIndexPathSectionInfo alloc] initWithItems:@[@"Item 2.1", @"Item 2.2"] name:@"Section 2"];
TLIndexPathSectionInfo section3 = [TLIndexPathSectionInfo alloc] initWithItems:nil name:@"Section 3"];
TLIndexPathDataModel dataModel3 = [TLIndexPathDataModel alloc] initWithSectionInfos:@[section1, section2, section3] identifierKeyPath:nil];
```

And there are numerous APIs to simplify delegate and data source implementations:

```Objective-C
// access all items across all sections as a flat array
dataModel.items;

// access items organized by sections
dataModel.sections;

// number of sections
[dataModel numberOfSections];

// number of rows in section
[dataModel numberOfRowsInSection:section];

// look up item at a given index path
[dataModel itemAtIndexPath:indexPath];

// look up index path for a given item
[dataModel indexPathForItem:item];
```    

As an immutable object, all of the properties and methods in `TLIndexPathDataModel` are read-only. So using the data model is very straightforward once you've selected the appropriate initializer.

###TLIndexPathUpdates

`TLIndexPathUpdates` is where the real magic happens. You provide two versions of your data model to the initializer of `TLIndexPathUpdates` and the inserts, deletes, and moves are calculated right then and there. Then call either `performBatchUpdatesOnTableView:` or `performBatchUpdatesOnCollectionView:` and see the batch updates performed in all their animated glory.

```Objective-C
// initialize collection view with unordered items
// (assuming view controller has a self.dataModel property)
self.dataModel = [TLIndexPathDataModel alloc] initWithItems:@[@"B", @"A", @"C"];
[self.collectionView reloadData];

// ...

// sort items, update data model & perform batch updates (perhaps when a sort button it tapped)
TLIndexPathDataModel *oldDataModel = self.dataModel;
NSArray *sortedItems = [self.dataModel.items sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
self.dataModel = [TLIndexPathDataModel alloc] initWithItems:sortedItems];
TLIndexPathUpdates *updates = [TLIndexPathUpdates alloc] initWithOldDataModel:oldDataModel updatedDataModel:self.dataModel];
[updates performBatchUpdatesOnCollectionView:self.collectionView];
```

Thats all it takes!

###TLIndexPathController

`TLIndexPathController` is TLIndexPathTools' version of `NSFetchedResultsController`. It should not come as a surprise, then, that you must use this class if you want to integrate with Core Data.

Although it primarily exists for Core Data integration, `TLIndexPathController` works interchangeably with `NSFetchRequest` or plain 'ol arrays of arbitrary data. Thus, if you choose to standardize your view controllers on `TLIndexPathController`, it is possible to have a common programming model across all of your table and collection views.

`TLIndexPathController` also makes a few nice improvements relative to `NSFetchedResultsController`:

* Items do not need to be presorted by section. The data model handles organizing sections.
* Changes to your fetch request are animated. So you can get animated sorting and filtering.
* There is only one delegate method to implement (versus five for `NSFetchedResultsController`).

The basic template for using `TLIndexPathController` in a (table) view controller is as follows:

```Objective-C
#import <UIKit/UIKit.h>
#import "TLIndexPathController.h"
@interface ViewController : UITableViewController <TLIndexPathControllerDelegate>
@end

#import "ViewController.h"
@interface ViewController ()
@property (strong, nonatomic) TLIndexPathController *indexPathController;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.indexPathController = [[TLIndexPathController alloc] init];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.indexPathController.dataModel.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.indexPathController.dataModel numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    id item = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    //configure cell using data item
    return cell;
}

#pragma mark - TLIndexPathControllerDelegate

- (void)controller:(TLIndexPathController *)controller didUpdateDataModel:(TLIndexPathUpdates *)updates
{
    [updates performBatchUpdatesOnTableView:self.tableView withRowAnimation:UITableViewRowAnimationFade];    
}

@end
```

This template works with plain arrays or `NSFetchRequests`. With plain arrays, you simply set the `dataModel` property of the controller (or set the `items` property and get a default data model). With `NSFetchRequests`, you set the `fetchRequest` property and call `performFetch:`. From then on, the controller updates the data model interinally every time the fetch results change (using an internal instance of `NSFetchedResultsController` and responding to `controllerDidChangeContent` messages).

In either case, whether you explicitly set a data model or the controller converts a fetch result into a data model, the controller creates the `TLIndexPathUpdates` object for you and passes it to the delegate, giving you an opportunity to perform batch updates:

```Objective-C
- (void)controller:(TLIndexPathController *)controller didUpdateDataModel:(TLIndexPathUpdates *)updates
{
    [updates performBatchUpdatesOnTableView:self.tableView withRowAnimation:UITableViewRowAnimationFade];    
}
```

###TLTableViewController & TLCollectionViewController

`TLTableViewController` and `TLCollectionViewController` are base table and collection view implementations, providing the essential data source and delegate methods to get you up and running quickly. Both classes look much like the code outlined above for integrating with `TLIndexPathController` with a few bells and whistles thrown in.

Most notably, `TLTableViewController` includes a default implementation of `heightForRowAtIndexPath` that calculates static or data-driven cell heights using prototype cell instances. For example, if you're using storyboards, the cell heights specified in the storyboard are automatically used. And if your cell implements the `TLDynamicSizeView` protocol, the height will be determined by calling the `sizeWithData:` method on the prototype cell. This is a great way to handle data-driven height because the `sizeWithData:` method can use the actual layout logic of the cell itself, rather than duplicating the layout logic in the view controller.

Most of the sample projects are based on `TLTableViewController` or `TLCollectionViewController`, so a brief perusal will give you a good idea what can be accomplished with a few lines of code.

<!--###TLTableViewDelegateImpl and TLCollectionViewDelegateImpl

TODO

###TLIndexPathItem

TODO

###TLDynamicSizeView

TODO-->

##Documentation

The Xcode docset can be generated by running the Docset project. The build configuration assumes [Appledoc][6] is installed in /usr/local/bin/appledoc. This can be changed at TLIndexPathTools project | Docset target | Build Phases tab | Run Script.

The API documentation is also [available online][7].

[1]:https://github.com/wtmoose/TLIndexPathTools/blob/master/Examples/Settings/Settings/SettingsTableViewController.m
[2]:https://github.com/wtmoose/TLIndexPathTools/blob/master/Examples/Collapse/Collapse/CollapseTableViewController.m
[3]:https://github.com/wtmoose/TLIndexPathTools/blob/master/Examples/Outline/Outline/OutlineTableViewController.m
[4]:https://github.com/wtmoose/TLIndexPathTools/blob/master/Examples/Outline/Outline/OutlineTableViewController.m
[5]:https://github.com/wtmoose/TLIndexPathTools/blob/master/Examples/Core%20Data/Core%20Data/CoreDataCollectionViewController.m
[6]:https://github.com/tomaz/appledoc
[7]:http://tlindexpathtools.com/api/index.html
