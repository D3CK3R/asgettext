# Requirements #

For running asgettext you need the following programs installed on your machine:
  * [gnu-gettext](http://www.gnu.org/software/gettext/) for extracting the translation strings
  * [ruby](http://www.ruby-lang.org/) for running the script
  * A shell / terminal
  * For using gettext in Flex you need the [Gettext classes from sephiroth](http://www.sephiroth.it/phpwiki/index.php?title=Gettext_actionscript3).

Furthermore you may want to have an editor for the translation Files. A common multiplatform editor is [poedit](http://www.poedit.net/).
  * [Lokalize](http://userbase.kde.org/Lokalize) (Unix KDE, intended to replace KBabel)
  * [KBabel](http://i18n.kde.org/tools/kbabel/) (Unix KDE)
  * [GTranslator](http://gtranslator.sourceforge.net/) (Unix Gnome)
  * [poEdit](http://www.poedit.net/) (Multiplatform)
  * [Emacs](http://www.gnu.org/software/emacs/emacs.html) with po-mode (Multiplatform)
  * [Vim](http://www.vim.org/) with PO [plug-in](http://www.vim.org/scripts/script.php?script_id=695) (Multiplatform)

## Linux ##
On Linux the gettext package usually is already installed. If not, use your package manager look out for "xgettext" or "gettext" and install it.

## Mac ##
Gettext has to be installed manually. It does not ship with XCode, so you have to use [Fink](http://www.finkproject.org/) or [Macports](http://www.macports.org/).
For Macports you simply type
{{sudo port install gettext}}
in your terminal to install the gettext package.

For further details check this [blog entry](http://blog.doughellmann.com/2009/06/installing-gnu-gettext-for-use-with.html), describing most of the details to install the gettext.

## Windows ##
TO BE FILLED OUT