**asgettext** is [Ruby](http://www.ruby-lang.org/)-script simplifying the use of [gettext](http://en.wikipedia.org/wiki/GNU_gettext) with [Flex](http://www.adobe.com/products/flex/) applications.

This is ruby script managing the translation file generation for you. It is a wrapper for the GNU-gettext.

Creating multilingual Flex application sucks, since there are no standard tools out there. `gettext` has been there for many years. The tools provided by `gettext` are easy to use but require a bit more detailed knowledge of the whole translation process. Another problem is the duality of Flex source files, `gettext` does not work well on `mxml` source-files, the mixture of `actioscript` and `xml` has not been added to `gettext` as source type.

**asgettext** helps
  1. extracting translation strings from `mxml` and `as` source files
  1. managing the translation files (.po, .pot and .mo)

**asgettext** is [Ruby-script](http://www.ruby-lang.org/) using [gettext](http://en.wikipedia.org/wiki/GNU_gettext).

## TODO ##
  * there is no support for multiple packages yet
  * parsing the gettext translation lines has to be improved, although it works for most cases

## Contact ##
For discussion and questions use our [mailinglist](http://groups.google.com/group/asgettext).

If there are any bugs use the [issue-tracker](http://code.google.com/p/asgettext/issues/list) to file them.