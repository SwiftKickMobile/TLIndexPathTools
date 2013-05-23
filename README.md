TLIndexPathTools
================

`TLIndexPathTools` is a set of components designed to greatly simplify the building
of rich, dynamic table and collection views. Some awesome things you can do with
`TLIndexPathTools` include:

* Automatically calculate and perform animated batch updates
* Perform animated sorting and filtering operations against an `NSFetchRequest`
* Easily manage multiple cell prototypes and/or multiple data types as the data model changes

The central component of `TLIndexPathTools` is the `TLIndexPathController` class. This class
is a lot like Core Data's `NSFetchedResultsController` class in that it is responsible
for tracking a data source and reporting changes to the client. The big difference is that, while
`TLIndexPathController` does support `NSFetchRequest`, it does not require Core Data at all.
`TLIndexPathController` can just as easily work with an array of strings. For example, you can
initialize a `TLIndexPathController` with an array of strings to display as table rows and then
give the controller a new array of strings (perhaps a filtered or sorted version of the
original array) and the table will automatically animate to the new state.
See the "Shuffle" example project.

`TLIndexPathTools` provides base view controller classes `TLTableViewController` and
`TLCollectionViewController` for table and collection views, respectively, that implement the
essential delegate methods to get you up-and-running as quickly as possible.

Installation
------------

TODO
