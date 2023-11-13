/**
Collatz module.
*/
module collatz;

struct Rational
{
	ulong numerator;
	ulong denominator = 1;

	ref Rational opOpAssign(string op: "+")(ulong n) @nogc nothrow pure @safe scope
	{
		numerator += n * denominator;
		return this;
	}

	ref Rational opOpAssign(string op: "*")(ulong n) @nogc nothrow pure @safe scope
	{
		numerator *= n;
		return this;
	}

	ref Rational opOpAssign(string op: "/")(ulong n) @nogc nothrow pure @safe scope
	{
		denominator *= n;
		return this;
	}

	@property bool moreThan1() const @nogc nothrow pure @safe
	{
		return numerator > denominator;
	}

    string toString() const pure @safe scope
    {
        import std.string : format;
        return format("%d/%d", numerator, denominator);
    }
}

///
@nogc nothrow pure @safe unittest
{
    Rational r;
    r.numerator = 1;
    r.denominator = 2;
    assert(r.moreThan1 == false);

    r += 1;

    assert(r.numerator == 3);
    assert(r.denominator == 2);
    assert(r.moreThan1 == true);

    r *= 2;

    assert(r.numerator == 6);
    assert(r.denominator == 2);
    assert(r.moreThan1 == true);

    r /= 4;

    assert(r.numerator == 6);
    assert(r.denominator == 8);
    assert(r.moreThan1 == false);
}

struct Bit
{

    enum Value
    {
        zero,
        one,
        unknown
    }

    enum one = Bit(Value.one);
    enum zero = Bit(Value.zero);
    enum unknown = Bit(Value.unknown);

    Value value;

    bool add(Bit rhs, bool carry = false) @nogc nothrow pure @safe
    {
		if (value == Value.unknown || rhs.value == Value.unknown)
		{
            value = Value.unknown;
			return false;
		}
	
		switch (value)
		{
			case Value.zero:
                if (carry)
                {
                    if (rhs.value == Value.zero)
                    {
                        value = Value.one;
                        return false;
                    }
                    else
                    {
                        value = Value.zero;
                        return true;
                    }
                }
                else
                {
                    value = rhs.value;
                    return false;
                }
			case Value.one:
                if (carry)
                {
                    value = rhs.value;
                    return true;
                }
                else
                {
                    if (rhs.value == Value.zero)
                    {
                        return false;
                    }
                    else
                    {
                        value = Value.zero;
                        return true;
                    }
                }
			default:
                break;
		}
        assert(false);
    }

    ///
    @nogc nothrow pure @safe unittest
    {
        Bit b = Bit.zero;
        assert(!b.add(Bit.one));
        assert(b == Bit.one);

        b = Bit.zero;
        assert(!b.add(Bit.zero));
        assert(b == Bit.zero);

        b = Bit.zero;
        assert(b.add(Bit.one, true));
        assert(b == Bit.zero);

        b = Bit.zero;
        assert(!b.add(Bit.zero, true));
        assert(b == Bit.one);

        b = Bit.zero;
        assert(!b.add(Bit.unknown));
        assert(b == Bit.unknown);

        b = Bit.zero;
        assert(!b.add(Bit.unknown, true));
        assert(b == Bit.unknown);

        b = Bit.one;
        assert(b.add(Bit.one));
        assert(b == Bit.zero);

        b = Bit.one;
        assert(!b.add(Bit.zero));
        assert(b == Bit.one);

        b = Bit.one;
        assert(b.add(Bit.one, true));
        assert(b == Bit.one);

        b = Bit.one;
        assert(b.add(Bit.zero, true));
        assert(b == Bit.zero);

        b = Bit.one;
        assert(!b.add(Bit.unknown));
        assert(b == Bit.unknown);

        b = Bit.one;
        assert(!b.add(Bit.unknown, true));
        assert(b == Bit.unknown);
    }

    int opCmp(Bit rhs) const @nogc nothrow pure @safe scope
    {
        if (value == rhs.value)
        {
            return 0;
        }

        switch (value)
        {
            case Value.zero:
                return -1;
            case Value.one:
                return rhs.value == Value.unknown ? -1 : 1;
            case Value.unknown:
                return 1;
            default:
                assert(false);
        }
    }

    ///
    @nogc nothrow pure @safe unittest
    {
        assert(!(Bit.zero < Bit.zero));
        assert(Bit.zero < Bit.one);
        assert(Bit.zero < Bit.unknown);

        assert(!(Bit.one < Bit.zero));
        assert(!(Bit.one < Bit.one));
        assert(Bit.one < Bit.unknown);
        
        assert(!(Bit.unknown < Bit.zero));
        assert(!(Bit.unknown < Bit.one));
        assert(!(Bit.unknown < Bit.unknown));
    }

    string toString() const @nogc nothrow pure @safe scope
    {
        switch (value)
        {
            case Value.zero:
                return "0";
            case Value.one:
                return "1";
            case Value.unknown:
                return "?";
            default:
                assert(false);
        }
    }
}

struct BitArray
{
    Bit[] bits;

    void add()(auto ref const(BitArray) rhs) nothrow pure @safe
    {
        if (length < rhs.length)
        {
            bits.length = rhs.length;
        }

        bool carry = false;
        foreach (i, ref bit; bits)
        {
            Bit rhsBit = Bit.zero;
            if (i < rhs.length)
            {
                rhsBit = rhs[i];
            }
            else if (!carry)
            {
                break;
            }

            carry = bit.add(rhsBit, carry);
        }
        
        if (carry)
        {
            bits ~= Bit.one;
        }
    }
    
    ///
    nothrow pure @safe unittest
    {
        auto array = BitArray([Bit.zero, Bit.one]);
        assert(array.length == 2);
        assert(array[0] == Bit.zero);
        assert(array[1] == Bit.one);

        auto array2 = BitArray([Bit.one, Bit.one]);
        array.add(array2);
        assert(array.length == 3);
        assert(array[0] == Bit.one);
        assert(array[1] == Bit.zero);
        assert(array[2] == Bit.one);

        array.add(BitArray([Bit.zero, Bit.one]));
        assert(array.length == 3);
        assert(array[0] == Bit.one);
        assert(array[1] == Bit.one);
        assert(array[2] == Bit.one);

        array.add(BitArray([Bit.one]));
        assert(array.length == 4);
        assert(array[0] == Bit.zero);
        assert(array[1] == Bit.zero);
        assert(array[2] == Bit.zero);
        assert(array[3] == Bit.one);
    }

    ref BitArray opOpAssign(string op : "<<")(size_t n) nothrow pure @safe scope
    {
        import std.algorithm : copy;

        if (n == 0)
        {
            return this;
        }

        bits.length += n;
        copy(bits[0 .. $ - n], bits[n .. $]);
        bits[0 .. n] = Bit.zero;

        return this;
    }
    
    ///
    nothrow pure @safe unittest
    {
        auto array = BitArray([Bit.one]);
        array <<= 0;
        assert(array.bits == [Bit.one]);
        array <<= 1;
        assert(array.bits == [Bit.zero, Bit.one]);
        array <<= 2;
        assert(array.bits == [Bit.zero, Bit.zero, Bit.zero, Bit.one]);
    }

    ref BitArray opOpAssign(string op : ">>")(size_t n) nothrow pure @safe scope
    {
        import std.algorithm : copy;

        if (n == 0)
        {
            return this;
        }
        else if (n >= length)
        {
            bits.length = 1;
            bits[0] = Bit.zero;
            return this;
        }

        copy(bits[n .. $], bits[0 .. $ - n]);
        bits.length -= n;

        return this;
    }
    
    ///
    nothrow pure @safe unittest
    {
        auto array = BitArray([Bit.zero, Bit.zero, Bit.zero, Bit.one]);
        array >>= 0;
        assert(array.bits == [Bit.zero, Bit.zero, Bit.zero, Bit.one]);
        array >>= 1;
        assert(array.bits == [Bit.zero, Bit.zero, Bit.one]);
        array >>= 2;
        assert(array.bits == [Bit.one]);
        array >>= 1;
        assert(array.bits == [Bit.zero]);
        array >>= 1000;
        assert(array.bits == [Bit.zero]);
    }

    ref BitArray opOpAssign(string op : "~")(Bit bit) nothrow pure @safe scope
     in (bit != Bit.zero)
    {
        bits ~= bit;
        return this;
    }
    
    ///
    nothrow pure @safe unittest
    {
        auto array = BitArray([Bit.one]);
        array ~= Bit.one;
        assert(array.bits == [Bit.one, Bit.one]);
        array ~= Bit.unknown;
        assert(array.bits == [Bit.one, Bit.one, Bit.unknown]);
    }

    @property size_t length() const @nogc nothrow pure @safe scope
    {
        return bits.length;
    }

    @property size_t opDollar() const @nogc nothrow pure @safe scope
    {
        return length;
    }

    @property ref inout(Bit) opIndex(size_t i) inout @nogc nothrow pure @safe return scope
        in (i < length)
    {
        return bits[i];
    }

    @property inout(BitArray) dup() inout nothrow pure @safe scope
    {
        return BitArray(bits.dup);
    }

    int opCmp()(auto ref const(BitArray) rhs) const @nogc nothrow pure @safe scope
    {
        import std.algorithm : cmp;
        return bits.cmp(rhs.bits);
    }
    
    ///
    nothrow pure @safe unittest
    {
        assert(BitArray([Bit.zero]) < BitArray([Bit.one]));
        assert(BitArray([Bit.zero]) < BitArray([Bit.zero, Bit.one]));
    }

    string toString() const pure @safe scope
    {
        import std.conv : to;
        return bits.to!string;
    }
}

struct CounterExample
{
	enum Result
	{
		inProgress,
		impossible,
		possible
	}

	BitArray bits;
	Rational cofficient = Rational(1, 1);
	Rational bias = Rational(0, 1);

	Result calculate() nothrow pure @safe scope
	{
		auto newBits = bits.dup;

        // 3n = 2n + n
        newBits <<= 1;
        newBits.add(bits);
		cofficient *= 3;

        // 3n + 1
        newBits.add(oneArray);
		bias += 1;

		// shift zeros
		size_t zeros = 0;
		foreach (i; 0 .. newBits.length)
		{
			if (newBits[i] != Bit.zero)
			{
				break;
			}
			++zeros;
		}

        newBits >>= zeros;
		cofficient /= (1 << zeros);
		bias /= (1 << zeros);

		bits = newBits;

        if (!cofficient.moreThan1)
        {
            return Result.impossible;
        }
        else if (bits[0] == Bit.unknown)
        {
            return Result.possible;
        }
        else
        {
            return Result.inProgress;
        }
	}

    ///
    nothrow pure @safe unittest
    {
        auto e = CounterExample(BitArray([Bit.one, Bit.zero, Bit.unknown]));
        assert(e.calculate() == Result.impossible);

        e = CounterExample(BitArray([Bit.one, Bit.one, Bit.unknown]));
        assert(e.calculate() == Result.inProgress);
        assert(e.calculate() == Result.possible);
    }

    string toString() const pure @safe scope
    {
        import std.string : format;
        return format("%s(%s + %s)", bits, cofficient, bias);
    }

private:
    enum oneArray = BitArray([Bit.one]);
}
