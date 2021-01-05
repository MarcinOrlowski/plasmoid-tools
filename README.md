![Logo](img/logo.png)

# KDE QML/Plasma Applet Developer Tools #

Helper tools and scripts I wrote to help me while working on KDE QML Plasmoids.

# Tools #

By design all the tools are "location agnostic" and can be invoked from any directory.
they will try to determine proper root directory of QML plasmoid if needed, based on
your current working directory (traversing up if needed). This means that your working
directory **must** be one of plasmoid's directories. You currently cannot manually
specify where plasmoid is manually, but that's mostly because I do not work that way
and it was not needed (adding support for that is trivial though).

# Determinig plasmoid root directory #

When you invoke i.e. `test.sh` tool, it will try to determine root folder of the plasmoid.
This is done by looking for `metadata.desktop` file in current directory. If file is not
present, the parent dir is checked and so on.

# Usage #

As mentioned, scripts are "location agnostic" and can be invoked from any directory. 
You can add it to your `$PATH`. I personally use [Fish shell](https://fishshell.com/)
and added following aliases to my `~/.config/fish/config.fish`:

```
alias otest "<TOOLS_DIR>/bin/test.sh"
alias oinstall "<TOOLS_DIR>/bin/install.sh"
```

## License ##

 * Written and copyrighted &copy;2020-2021 by Marcin Orlowski <mail (#) marcinorlowski (.) com>
 * Weekday Grid widget is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)

