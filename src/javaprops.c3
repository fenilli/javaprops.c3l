// SPDX-License-Identifier: MIT
module javaprops;

import std::io, std::collections::map;

faultdef INVALID_UNICODE;

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

		ParsedProperty parsed_property = parse_property(logical_line)!;
		properties.set(parsed_property.key.copy_str(allocator), parsed_property.value.copy_str(allocator));
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
	DString key;
	DString value;
}

fn DString? unescape(String raw)
{
	DString out;
	out.tinit();

	sz i         = 0;
	bool escaped = false;
	while (i < raw.len)
	{
		char c = raw[i];

		if (!escaped)
		{
			if (c == '\\')
			{
				escaped = true;
				i++;
				continue;
			}
			out.append_char(c);
			i++;
			continue;
		}

		escaped = false;
		switch (c)
		{
			case 'n': out.append_char('\n'); i++;
			case 't': out.append_char('\t'); i++;
			case 'r': out.append_char('\r'); i++;
			case 'f': out.append_char('\f'); i++;
			case 'u':
				i++;
				if (i + 4 > raw.len) return INVALID_UNICODE~;

				String hex = raw[i:4];
				int? code_point = hex.to_int(16);
				if (catch code_point) return INVALID_UNICODE~;

				char[4] buf;
				sz? written = conv::char32_to_utf8((Char32)code_point, &buf);
				if (catch written) return INVALID_UNICODE~;

				out.append(buf[:written]);
				i += 4;
			default:
				out.append_char(c);
				i++;
		}
	}

	return out;
}

fn bool is_line_continued(String line)
{
	String stripped_line = line.trim_right();
	sz count             = 0;

	foreach_r (c : stripped_line)
	{
		if (c == '\\')
		{
			count++;
		}
		else
		{
			break;
		}
	}

	return !((count % 2) == 0);
}

fn String? next_logical_line(InStream stream)
{
	String logical_line;

	while (true)
	{
		String? physical_line = io::treadline(stream);
		if (catch excuse = physical_line) return excuse~;

		physical_line = physical_line.trim_left();

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

fn ParsedProperty? parse_property(String logical_line)
{
	sz key_ends = logical_line.len;
	for (sz i = 0; i < logical_line.len; i++)
	{
		char c = logical_line[i];

		if (c == '\\')
		{
			i++;
			continue;
		}

		if (c == '=' || c == ':' || c == ' ' || c == '\t' || c == '\f')
		{
			key_ends = i;
			break;
		}
	}

	DString key = unescape(logical_line[:key_ends])!;

	sz value_starts = key_ends;
	while (value_starts < logical_line.len
		&& (logical_line[value_starts] == ' ' || logical_line[value_starts] == '\t'
			|| logical_line[value_starts] == '\f'))
	{
		value_starts++;
	}

	if (value_starts < logical_line.len && (logical_line[value_starts] == '=' || logical_line[value_starts] == ':'))
	{
		value_starts++;

		while (value_starts < logical_line.len
			&& (logical_line[value_starts] == ' ' || logical_line[value_starts] == '\t'
				|| logical_line[value_starts] == '\f'))
		{
			value_starts++;
		}
	}

	DString value = unescape(logical_line[value_starts..])!;

	return (ParsedProperty) { key, value };
}
