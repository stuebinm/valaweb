# valaweb
A tool for literate programming with vala.

Along the lines of Donald E. Knuth's WEB program.

Mostly written for practice and to understand how literate programming works (this program is self-hosting in the sense that it is itself a literate program); in case you're interested in productive literate programming with vala, it might be better to look at more tested alternatives (NOWEB comes to mind).

## Usage:

Once installed, use it like this:

> $ valaweb input.web

> $ valac [options] input.vala

(For an exampe on what the input.web file might look like consult src/valaweb.web, which is this program's actual source code)

## Installing and Hacking:

### building with cmake:

a simple cmake should suffice:

> $ cmake

> $ make

(having an extra build directory is recommended)

The CMakeLists.txt I've created isn't really any good yet, though, so you might want to do it by hand:

### building by hand:

This can be somewhat tricky. Since it's self-hosting, there's a (very limited) implementation of the whole thing that I've called "src/bootstrap.vala" written in ordinary vala which should be compiled first, then used to compile the main program (in "src/valaweb.web") like this:

> $ ./bootstrap valaweb.web

> $ valac --pkg gio-2.0 --pkg gee-0.8 valaweb.vala

Afterwards, you can self-host the whole thing, like this:

> $ ./valaweb valaweb.web

> $ valac --pkg gio-2.0 --pkg gee-0.8 valaweb.vala
