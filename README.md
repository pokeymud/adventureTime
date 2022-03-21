# AdventureTime GP bar

A [MUSHClient](https://www.mushclient.com/) plugin that renders a GP bar for [Discworld MUD](http://discworld.starturtle.net/lpc/). The GP bar not only shows your current guild GP but how much GP you have left for non-guild commands.

## Description

The GP bar looks like this:

![GP Bar image](https://github.com/pokeymud/adventureTime/blob/main/adventuretime.PNG?raw=true)

The code is a fairly straight-forward mashup of [quow's](https://quow.co.uk) and [one](https://www.mushclient.com/forum/?id=9270) found on the [MUSHClient](https://www.mushclient.com/) forums by the author of MUSHclient, with the additional logic to derive non-guild gp added by me.

Being a descendant of quow's gp bar, it shares the same quirks.

## GETTING Started

### Dependencies

* MUSHClient running discworld MUD.

### Installing

* Plonk "adventureTime.lua" into you plugins folder, then go to "file->plugins->add" in MUSHClient to add the plugin.

### Usage

* The plugin needs to see your non-guild GP at least once in order to function. Use "gp brief" to supply it with the numbers it needs. You can also do this automatically every time you log in with the following discworld command
```
alias afterinventory gp brief
```
* The plugin defaults to a GP regen rate of 3 but this is customisable using the following alias, provided by the plugin:
```
adventuretime regen N
```

## Help

* If you have issues or bugs, mudmail or tell Pokey on the disc!

## Authors
[Pokey](https://dwwiki.mooo.com/wiki/User:Pokey)

## Acknowledgments
* [Quow bar](https://quow.co.uk)
* [Discworld MUD](http://discworld.starturtle.net/lpc/) 
* [MUSHClient](https://www.mushclient.com/)
