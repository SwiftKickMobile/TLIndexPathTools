TLIndexPathTools
================

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

The basic usage is as follows:

	#import <UIKit/UIKit.h>
	#import "TLIndexPathController.h"
	@interface ViewController : TLTableViewController
	@end

	#import "ViewController.h"
	@implementation ViewController

	- (void)viewDidLoad
	{
		[super viewDidLoad];
		self.indexPathController.items = @[@"Chevrolet", @"Bubble Gum", @"Chalkboard"]];
	}

	- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
	{
		UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
		NSString *title = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
		cell.textLabel.text = title;
		return cell;
	}

This yields a table view with rows "Chevrolet", "Bubble Gum" and "Chalkboard". Note that by default, as in this example, TLIndexPathTools assumes the cell's reuse identifier is "Cell".

Things get interesting when we add dynamic behavior, such as a method that shuffles rows (which we can wire into a button):

    - (IBAction)shuffle
    {
        NSMutableArray *shuffledItems = [NSMutableArray arrayWithArray:self.indexPathController.items];
        NSInteger count = shuffledItems.count;
        for (int i = 0; i < count; i++) {
            [shuffledItems exchangeObjectAtIndex:i withObjectAtIndex:arc4random() % count];
        }
        self.indexPathController.items = shuffledItems;
    }
    
Thats all it takes to generate a nice, smooth animated shuffle effect. Try running the [Shuffle][1] sample project to see the same effect in action with a `UICollectionView`.

Now, lets pull back the curtain a bit and see what this looks like without the help of `TLTableViewController`. Here is what the app looks like when done as a direct subclass of `UITableViewController` (unchanged lines are gray):

<pre><code><span style="color:gray">#import &lt;UIKit/UIKit.h&gt;
#import "TLIndexPathController.h"
@interface ViewController : </span>UITableViewController
@property (strong, nonatomic) TLIndexPathController *indexPathController;
<span style="color:gray">@end

#import "ViewController.h"
@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];</span>
    self.indexPathController = [[TLIndexPathController alloc] init];
	<span style="color:gray">self.indexPathController.items = @[@"Chevrolet", @"Bubble Gum", @"Chalkboard"]];
}</span>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.indexPathController.dataModel.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.indexPathController.dataModel numberOfRowsInSection:section];
}

<span style="color:gray">- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{</span>
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    <span style="color:gray">NSString *title = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    cell.textLabel.text = title;
    return cell;
}</span>

<span style="color:gray">- (IBAction)shuffle
{
    NSMutableArray *shuffledItems = [NSMutableArray arrayWithArray:self.indexPathController.items];
    NSInteger count = shuffledItems.count;
    for (int i = 0; i < count; i++) {
        [shuffledItems exchangeObjectAtIndex:i withObjectAtIndex:arc4random() % count];
    }
    self.indexPathController.items = shuffledItems;
}</span>

#pragma mark - TLIndexPathControllerDelegate

- (void)controller:(TLIndexPathController *)controller didUpdateDataModel:(TLIndexPathUpdates *)updates
{
    [updates performBatchUpdatesOnTableView:self.tableView withRowAnimation:UITableViewRowAnimationFade];    
}

<span style="color:gray">@end</span>
</code></pre>

As you can see, `TLTableViewController` is just adding some simple boiler plate methods. It is completely fine to not use `TLTableViewController` or `TLCollectionViewController`, though the former does provide some nice bells and whistles like automatic (dynamic) row height calculations (see the [Dynamic Height][2] sample project).

Now lets step through the code for a brief introduction to some basic APIs.

###TLIndexPathController

<pre><code><span style="color:gray">@interface ViewController : </span>UITableViewController
@property (strong, nonatomic) TLIndexPathController *indexPathController;
<span style="color:gray">@end</span>
</code></pre>

`TLIndexPathController` is the primary API access point, so we have a public property to get or set a controller. If you're familiar with Core Data's `NSFetchedResultsController`, `TLIndexPathController` plays a similar role except that it work with regular arrays. It also works with Core Data and can do things that `NSFetchedResultsController` can't do, such as animated sorting and filtering (more on that later).

Both `TLTableViewController` and `TLCollectionViewController` provide default index path controllers, but it is normal to replace this instance with a custom one (see the selection of initializers in [TLIndexPathController.h][3]).

<pre><code><span style="color:gray">- (void)viewDidLoad
{
    [super viewDidLoad];</span>
    self.indexPathController = [[TLIndexPathController alloc] init];
	<span style="color:gray">self.indexPathController.items = @[@"Chevrolet", @"Bubble Gum", @"Chalkboard"]];
}</span>
</code></pre>

Here we create a default index path controller just as `TLTableViewController` does. Then we populate the controller with our data by setting the `items` array property. Data items can be any type of object from `NSString`s as we have here to `NSDictionarie`s (see the [JSON][4] sample project) to `NSManagedObject`s (see the [Core Data][5] sample project).

###TLIndexPathDataModel

TODO...

[1]:https://github.com/wtmoose/TLIndexPathTools/blob/master/Examples/Shuffle/Shuffle/ShuffleCollectionViewController.m
[2]:https://github.com/wtmoose/TLIndexPathTools/blob/master/Examples/Dynamic%20Height/Dynamic%20Height/DynamicHeightTableViewController.m
[3]:https://github.com/wtmoose/TLIndexPathTools/blob/master/TLIndexPathTools/Controllers/TLIndexPathController.h
[4]:https://github.com/wtmoose/TLIndexPathTools/blob/master/Examples/JSON/JSON/JSONTableViewController.m
[5]:https://github.com/wtmoose/TLIndexPathTools/blob/master/Examples/Core%20Data/Core%20Data/CoreDataCollectionViewController.m

