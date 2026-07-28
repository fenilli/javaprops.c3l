// SPDX-License-Identifier: MIT
module javaprops;

import std::io, std::collections::map;

alias JavaProperties = HashMap{String, String};

fn JavaProperties? load(Allocator allocator, InStream stream) => @pool()
{
	JavaProperties properties;
	properties.init(allocator);
	defer catch properties.free();

	while (String logical_line , !@try_catch(logical_line, next_logical_line(stream), io::EOF)!)
	{
		if (!logical_line.len) continue;

		switch (logical_line[0])
		{
			case '!':
			case '#': continue;
		}

		ParsedProperty parsed_property = parse_property(allocator, logical_line)!;
		properties.set(parsed_property.key, parsed_property.value);
	}

	return properties;
}

fn JavaProperties? tload(InStream stream)
{
	return load(tmem, stream);
}

fn JavaProperties? parse(Allocator allocator, String string)
{
	ByteReader reader;
	reader.init(string);
	return load(allocator, &reader);
}

fn JavaProperties? tparse(String string)
{
	return parse(tmem, string);
}

module javaprops @private;

import std::io;

struct ParsedProperty
{
	String key;
	String value;
}

fn bool is_line_continued(String line)
{
	sz count = 0;
	foreach_r (c : line.trim_right())
	{
		if (c != '\\') break;
		count++;
	}

	return (count & 1) != 0;
}

fn String? next_logical_line(InStream stream)
{
	String logical_line;

	while (true)
	{
		String physical_line = io::treadline(stream)!.trim_left();

		if (!logical_line.len)
		{
			logical_line = physical_line;
		}
		else
		{
			logical_line = logical_line.trim_right("\\").tconcat(physical_line);
		}

		if (!is_line_continued(logical_line)) return logical_line;
	}
}

fn ParsedProperty? parse_property(Allocator allocator, String logical_line)
{
	sz key_ends = logical_line.len;
	for OUTER: (sz i = 0; i < logical_line.len; i++)
	{
		switch (logical_line[i])
		{
			case '\\': i++;
			case '=':
			case ':':
			case ' ':
			case '\t':
			case '\f':
				key_ends = i;
				break OUTER;
		}
	}

	String key = logical_line[:key_ends].unescape(allocator, true, true)!;

	String value_part = logical_line[key_ends..].trim_left();
	if (value_part.len > 0 && (value_part[0] == '=' || value_part[0] == ':'))
	{
		value_part = value_part[1..].trim_left();
	}

	String value = value_part.unescape(allocator, true, true)!;

	return (ParsedProperty) { key, value };
}
