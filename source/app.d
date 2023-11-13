import std.stdio;

void main()
{
	findCounterExamples();
}

void findCounterExamples()
{
	import std.algorithm : swap, sort, each;
	import collatz : BitArray, Bit, CounterExample;

	BitArray[] arrays1 = [BitArray([Bit.one, Bit.unknown])];
	BitArray[] arrays2;

	bool calculateCounterExample(BitArray bits) @safe
	{
		auto c = CounterExample(bits);
		auto result = CounterExample.Result.inProgress;
		while (result == CounterExample.Result.inProgress)
		{
			result = c.calculate();
		}
		return result == CounterExample.Result.possible;
	}

	size_t impossibleCount = 0;
	foreach (i; 0 .. 11)
	{
		foreach (array; arrays1)
		{
			array ~= Bit.unknown;

			array[$ - 2] = Bit.zero;
			if (calculateCounterExample(array.dup))
			{
				arrays2 ~= array.dup;
			}
			else
			{
				++impossibleCount;
			}

			array[$ - 2] = Bit.one;
			if (calculateCounterExample(array.dup))
			{
				arrays2 ~= array.dup;
			}
			else
			{
				++impossibleCount;
			}
		}

		swap(arrays1, arrays2);
		arrays2.length = 0;
	}

	writefln("possibles: %d, impossible: %d", arrays1.length, impossibleCount);
	arrays1.sort.each!writeln;
}

void writeSingleCollat(ulong n)
{
	writefln("%b", n);
	for (ulong current = n; current > 1;)
	{
		if (current & 0b1)
		{
			current = 3 * current + 1;
			while (!(current & 0b1))
			{
				current >>>= 1;
			}
			writefln("%b", current);
		}
		else
		{
			current >>>= 1;
		}
	}
}

void writePowersOf3()
{
	import std.algorithm : each, map;
	import std.range : iota;
	import std.array : appender;
	import std.conv : to;
	import std.bigint : BigInt;

	auto n = BigInt("1");
	auto app = appender!(ulong[]);
	foreach (i; 0 .. 1000)
	{
		app.clear();
		iota(0, n.ulongLength).map!(a => n.getDigit(a)).each!(d => app.put(d));

		foreach_reverse (digit; app.data)
		{
			writef("%b", digit);
		}
		writeln();

		n *= 3;
	}
}

void writeCollats()
{
	import std.conv : to;
	import std.algorithm : map, joiner;
	import std.range : iota;

	foreach (n; iota(1, 5000, 2))
	{
		auto result = collatz(n);
		writefln("%d,%b,%d,%s", n, n, result.length, result.map!(to!string).joiner(","));
	}
}

immutable(size_t)[] collatz(ulong n)
{
	import std.array : appender;
	import std.exception : assumeUnique;

	auto result = appender!(size_t[]);
	
	size_t shift = 0;
	for (ulong current = n; current > 1;)
	{
		if (current & 0b1)
		{
			result.put(shift);
			shift = 0;
			current = 3 * current + 1;
		}
		else
		{
			current >>>= 1;
			++shift;
		}
	}
	result.put(shift);

	return result.data.idup;
}