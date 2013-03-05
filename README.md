TLIndexPathTools
================

`TLIndexPathTools` is a set of components designed to greatly simplify the building
of rich, dynamic table and collection views. For example, `TLIndexPathTools`-driven table
can automatically perform batch updates (inserts, deletes, etc.) when the data model
changes. This is indeed similar to what `NSFetchedResultsController` can do except that
`TLIndexPathTools` is not tied to Core Data. `TLIndexPathTools` does, however, provide
a subclass of `NSFetchedResultsController` named `TLInMemoryFetchedResultsController`
that can perform batch updates for modified predicates and sort descriptors
(think animated sorting and filtering).

The system is based on a few basic concepts (references to table also apply to
collection unless otherwise noted):

- An instance of `TLIndexPathDataModel` represents a table's data model.
- Data models are created by passing an array of data items to `TLIndexPathDataModel`'s
initializer. Each data item corresponds to an index path. Items can be anything from
a list of strings, core data objects, or the `TLIndexPathItem` wrapper object for
heterogeneous data sets (as is typical with multiple cell prototypes).
- Every data item is assumed to have an identifier. This identifier is used by the
framework to compute batch updates from two data model instances (old and new). The
item itself can serve as the identifier (such as as with a string) or one can specify
an `identifierKeypath` (for example `objectID` with Core Data managed objects).
- `TLIndexPathDataModelUpdates` takes two versions of the data model and computes
the inserts, deletes, moves, and updates. Then the batch updates are performed
by calling either of
`TLIndexPathDataModelUpdates:performBatchUpdatesOnTableView:withRowAnimation:` or
`performBatchUpdatesOnCollectionView:collectionView`.

`TLIndexPathDataModel` provides several additional components:

`TLTableViewController` is a base table view controller provided for quickly
integrating TLIndexPathDataModel into a project.

`TLNoResultsTableDataModel` is a subclass of `TLTableViewController` that automatically
displays a "no result" message as a special row when there are no items.

`TLInMemoryFetchedResultsController` is a subclass of `NSFetchedResultsController`
that uses an internal data model to report batch updates when predicates or
sort descriptors are modified. This allows for animated sorting and filtering UIs, which
the base `NSFetchedResultsController` cannot do.

`TLCoreDataCollectionViewController` is a base collection view controller class for
integrating with `NSFetchedResultsController` (or `TLInMemoryFetchedResultsController`).
