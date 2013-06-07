TLIndexPathTools
================

TLIndexPathTools makes it easy to build rich, dynamic table and collection views on iOS. The crown jewel of TLIndexPathTools is its ability to automatically perform batch updates on your table or collection view as your data model changes, giving your app those smooth animated transitions that users love. Here are some examples of awesome things you can do with this capability:

* Collapsable sections, tree views, etc. ([Collapse][1] and [Outline][2] examples)
* Animated sorting and filtering ([Core Data][3] example)
* Sophisticated, dynamic forms and settings screens ([Settings][4] example)

To get you up-and-running as quickly as possible, TLIndexPathTools provides base table and collection view controller classes, `TLTableViewController` and `TLCollectionViewController`, both of which provide default implementations of the essential delegate methods as well as a default instance of a `TLIndexPathController` as the primary interface for working with the data model. For example (the [Shuffle][5] example, to be precise), populating a collection view is as easy as giving an array of data items to the index path controller and applying those items in a cell configuration method.

    - (void)viewDidLoad
    {
        [super viewDidLoad];
        NSArray *items = @[
            @[@"A", [UIColor colorWithHexRGB:0x96D6C1]],
            @[@"B", [UIColor colorWithHexRGB:0xD696A3]],
            @[@"C", [UIColor colorWithHexRGB:0xFACB96]],
            ];
        self.indexPathController.items = items;
    }

    - (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
    {
        NSArray *item = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
        UILabel *label = (UILabel *)[cell viewWithTag:1];
        label.text = item[0];
        cell.backgroundColor = item[1];
    }

TODO HERE…WRITE THIS BETTER...Things start to get interesting when we change the data model. In this example, tapping a "Shuffle" button causes the data model to be randomly reordered. With TLIndexPathTools, we accomplish this with a few lines of code and have the cells slide into their new positions with a pleasing animation.

    - (void)shuffle
    {
        NSMutableArray *shuffledItems = [NSMutableArray arrayWithArray:self.indexPathController.items];
        NSInteger count = shuffledItems.count;
        for (int i = 0; i < count; i++) {
            [shuffledItems exchangeObjectAtIndex:i withObjectAtIndex:arc4random() % count];
        }
        self.indexPathController.items = shuffledItems;
    }


NSFetchedResultsController
--------------------------



TLIndexPathTools is a set of components designed to greatly simplify the building
of rich, dynamic table and collection views. Some awesome things you can do with
TLIndexPathTools include:

* Automatically calculate and perform animated batch updates
* Perform animated sorting and filtering operations against an array or `NSFetchRequest`
* Easily manage multiple cell prototypes and/or multiple data types as the data model changes

The central component of TLIndexPathTools is the `TLIndexPathController` class. This class
is a lot like Core Data's `NSFetchedResultsController` class in that it is responsible
for tracking a data source and reporting changes to the client. The big difference is that, while
`TLIndexPathController` does support `NSFetchRequest`, it does not require Core Data at all.
`TLIndexPathController` can just as easily work with an array of strings. For example, you can
initialize a `TLIndexPathController` with an array of strings to display as table rows and then
give the controller a new array of strings (perhaps a filtered or sorted version of the
original array) and the table will automatically animate to the new state.
See the "Shuffle" example project.

TLIndexPathTools provides base view controller classes `TLTableViewController` and
`TLCollectionViewController` (for table and collection views, respectively) that implement the
essential delegate methods to get you up-and-running as quickly as possible.

Installation
------------

1. Download the TLIndexPathTools project
2. Add the TLIndexPathTools sub-folder (sibling of the Examples folder) to your Xcode project.
3. Link to QuartzCore.framework and CoreData.framework (on the Build Phases tab of your project's target).

Getting Started
---------------
ToDo

[1]: https://github.com/wtmoose/TLIndexPathTools/blob/master/Examples/Collapse/Collapse/CollapseTableViewController.m
[2]: https://github.com/wtmoose/TLIndexPathTools/blob/master/Examples/Outline/Outline/OutlineTableViewController.m
[3]: https://github.com/wtmoose/TLIndexPathTools/blob/master/Examples/Core%20Data/Core%20Data/CoreDataCollectionViewController.m
[4]: https://github.com/wtmoose/TLIndexPathTools/blob/master/Examples/Settings/Settings/SettingsTableViewController.m
[5]: https://github.com/wtmoose/TLIndexPathTools/blob/master/Examples/Shuffle/Shuffle/ShuffleCollectionViewController.m