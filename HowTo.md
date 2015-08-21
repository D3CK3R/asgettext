This is a short demo how to create gettext translation files for an existing Flex project.

  1. `cd` to your flex source folder
```
cd flex_workspace/myProject
```
  1. Initialize the translation directory
```
asgettext init
```
> if `asgettext` is not found here, either make sure it is in your [PATH](http://www.cs.purdue.edu/homes/cs541/unix_path.html), or copy it directly into the flex project location.
  1. Add a language to translate. "en" is installed by default.
```
asgettext add de
```
  1. Extract the translation strings and update all translation files
```
asgettext update
```
  1. Edit the translation files in `translation/locale/LANGUAGE/LC_MESSAGES/messages.pot` using an editor of your choice (see [Installation](Installation.md) for more details)
  1. Compile the translation files to mo files for distribution
```
asgettext compile
```
> Now you have your compiled mo-files in `translation/locale/LANGUAGE/LC_MESSAGES/messages.mo`


To use these mo files from within Flex use the [Gettext classes from sephiroth](http://www.sephiroth.it/phpwiki/index.php?title=Gettext_actionscript3) or from [gettext-for-flash](http://code.google.com/p/gettext-for-flash/).