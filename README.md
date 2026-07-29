# JavaProps

A small parser for Java .properties files written in C3.

## Features

- Supports separators `=`, `:`, `whitespace`
- Ignores blank lines and comment lines beginning with # or !
- Supports line continuations using a trailing `\`
- Supports escape sequences `\n`, `\f`, `\t`, `\r`, `\uXXXX` (Unicode escape)

## Quick Start

You can easily parse it, and get properties from it:

```c3
import javaprops;

fn int main()
{
    String text = `
    name = Gustavo Fenilli
    language = C3
    path = C:\\Program Files\\App
    `;

    JavaProperties java_properties = javaprops::tparse(text)!!;

    io::printfn("Name: %s", java_properties.get("name")!!);
    io::printfn("Language: %s", java_properties.get("language")!!);
    io::printfn("Path: %s", java_properties.get("path")!!);

    return 0;
}

// Output:
// Name: Gustavo Fenilli
// Language: C3
// Path: C:\Program Files\App
```

Also encode it and save the way you want:

```c3
import javaprops;

fn int main()
{
    JavaProperties java_properties;
    java_properties.set("a", "1");
	java_properties.set("b", "2");

    String properties = javaprops::tencode(&java_properties)!!;

    io::printfn("%s", properties);

    return 0;
}

// Output:
// a=1
// b=2
```

Encoding accepts 2 aditional parameters `separator` and `header`:

```c3
import javaprops;

fn int main()
{
    JavaProperties java_properties;
    java_properties.set("a", "1");
	java_properties.set("b", "2");

    String properties = javaprops::tencode(&java_properties, ":", "Machine Generated")!!;

    io::printfn("%s", properties);

    return 0;
}

// Output:
// # Machine Generated
// a:1
// b:2
```

## Installation

Add the library by cloning or adding as a submodule to your C3 project folder pointed by `dependency-search-paths`:

```sh
# Cloning
git clone https://github.com/fenilli/javaprops.c3l.git <YOUR_PROJECT_DEPENDENCY_PATH>

# Submodule
git submodule add https://github.com/fenilli/javaprops.c3l.git <YOUR_PROJECT_DEPENDENCY_PATH>
```

Then update your project.json to include:

```
{
    "dependency-search-paths": [ "lib" ],
    "dependencies": [ "javaprops" ]
}
```

## License

MIT License
