![Logo](img/logo.png)

# KDE QML/Plasma Applet Developer Tools #

Helper tools and scripts I wrote to help me while working on KDE QML Plasmoids (widgets).

# Tools #

By design all the tools are "location agnostic" and can be invoked from any directory.
they will try to determine proper root directory of QML plasmoid if needed, based on
your current working directory (traversing up if needed). This means that your working
directory **must** be one of plasmoid's directories. You currently cannot manually
specify where plasmoid is manually, but that's mostly because I do not work that way
and it was not needed by my workflow (adding support for that is trivial though).

# Determinig plasmoid root directory #

When you invoke i.e. `test.sh` script, it will try to determine root folder of the plasmoid.
This is done by looking for `metadata.desktop` file in current directory. If file is not
present, the parent dir is checked and so on.

# Tools #

Available tools:

* `test.sh`: runs your plasmoid in `plasmaviewer`. When invoked without arguments,
  will try to use `CompactRepresentation` by enforcing smaller widget area, which
  mimics docking plasmoid in the Panel. When invoked with any argument (literaly
  any will work, i.e. `test.sh foo`), will run you plasmoid as it is installed as
  desktop widget (so `FullRepresentation` should kick in).
* `meta.sh`: This is my work around for Plasma API not exposing metadata file content
  in any other way. It parses project's `metadata.desktop` and creates `/contents/js/meta.js`
  containing extracted information, that can be later imported and used in your JavaScript
  code. Currently exposes metadata's `X-KDE-PluginInfo-Version` as `version`,
  `Name` as `name`, `X-KDE-PluginInfo-Website` as `url`, `X-KDE-PluginInfo-Author` as `authorName`.
  It also looks for additional, non-standard fields: `X-KDE-PluginInfo-Author-Url` (exported
  as `authorUrl`), `X-KDE-PluginInfo-UpdateChecker-Url` (exported as `updateCheckerUrl`) and
  `X-KDE-PluginInfo-FirstReleaseYear` exported as `firstReleaseYear`.
* `install.sh`: installs/upgrades your plasmoid in `~/.local/share/plasma/plasmoids/`
  folderm then restarts plasmashell. Please note it will upgrade existing installation
  without any confirmation. Note: it automatically updates `meta.js` file.
* `release.sh`: packs plasmoid sources and creates release file. Target file name is
  going to be `PACKAGE-VERSION.plasmoid` and  constructed using `metadata.desktop` information.
  Note: it automatically updates `meta.js` file.


# Installation #

As mentioned, scripts are "location agnostic" and can be invoked from any directory.
You can add it to your `$PATH`. I personally use [Fish shell](https://fishshell.com/)
and added following aliases to my `~/.config/fish/config.fish`:

```
alias otest "<TOOLS_DIR>/bin/test.sh"
alias oinstall "<TOOLS_DIR>/bin/install.sh"
alias orelease "<TOOLS_DIR>/bin/release.sh"
alias ometa "<TOOLS_DIR>/bin/meta.sh"
```

# Tips #

* If your plasmoid misbehave, you may want to run it using "desktop" mode (`test.sh foo`).
  That will make any syntax error related messages nicely visible in plasmaviewer window.
* You can easily customize QT log entries (thrown by `console.xxx()` calls) and i.e.
  add file name or line number to it by setting `QT_MESSAGE_PATTERN`. See `test.sh` souces
  for details and additional links.

## License ##

* Written and copyrighted &copy;2020-2023 by Marcin Orlowski <mail (#) marcinorlowski (.) com>
* Plasmoid Tools is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT).
