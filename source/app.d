import std.stdio;
import std.traits : isIntegral;
import std.range : isInputRange;
import std.array : array;
import std.conv : to;

@safe pure nothrow @nogc {
    /// 偶数の場合true
    bool even(T)(T value) if(isIntegral!T) {
        return (value & (cast(T)1)) == 0;
    }

    ///
    unittest {
        assert(!1.even);
        assert(2.even);
        assert(!1213.even);
        assert(1214.even);
    }

    /// 奇数の場合true
    bool odd(T)(T value) if(isIntegral!T) {return !value.even;}

    ///
    unittest {
        assert(1.odd);
        assert(!2.odd);
        assert(1213.odd);
        assert(!1214.odd);
    }
}

/// ビット列を取り出すRange
struct Bits(T) if(isIntegral!T) {
    this(T value) {this.value_ = value;}
    @property @safe pure nothrow @nogc const {
        bool front() {return value_.odd;}
        bool empty() {return value_ == 0;}
    }
    @safe nothrow @nogc void popFront() {value_ >>= (cast(T)1);}
private:
    T value_;
}

///
unittest {
    auto bits = Bits!uint(0b1010).array;
    assert(bits == [false, true, false, true], to!string(bits));
}
static assert(isInputRange!(Bits!(uint)));

void main() {
}

