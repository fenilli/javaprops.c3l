# JavaProps

A small parser for Java .properties files written in C3.

## Features

- Supports separators `=`, `:`, `whitespace`
- Ignores blank lines and comment lines beginning with # or !
- Supports line continuations using a trailing `\`
- Supports escape sequences `\n`, `\f`, `\t`, `\r`, `\uXXXX` (Unicode escape)

## Quick Start

```c3
import javaprops;

fn int main()
{
    String text = `
    name = Gustavo Fenilli
    language = C3
    path = C:\\Program Files\\App
    `;

    JavaProperties props = javaprops::tparse(text)!!;

    io::printfn("Name: %s", props.get("name")!!);
    io::printfn("Language: %s", props.get("language")!!);
    io::printfn("Path: %s", props.get("path")!!);

    return 0;
}
```

## Installation

1. Clone or add this repository as a submodule into `<YOUR_PROJECT>/lib` or the where your `dependency-search-paths` is:
    - `git clone https://github.com/fenilli/javaprops.c3l.git <YOUR_PROJECT>/lib`
    - `git submodule add https://github.com/fenilli/javaprops.c3l.git <YOUR_PROJECT>/lib`
2. Add `javaprops` to the `dependencies` list in your `project.json`
3. Done!

## License

MIT License