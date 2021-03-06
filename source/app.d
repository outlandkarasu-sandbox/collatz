import std.stdio;
import std.string : format;
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
        T value() {return value_;}
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
static assert(isInputRange!(Bits!uint));

/// コラッツ問題の処理を行うstruct
struct Collatz(T) if(isIntegral!T) {

    /// 計算結果の型
    struct Result {
        T cofficient;
        T n;
        T offset;
        @safe pure const {
            @property T value() nothrow @nogc {return cofficient * n + offset;}
            string toString() {return format("(%d,%d,%d)", cofficient, n, offset);}
        }
    }

    this(T value) {this.bits_ = Bits!T(value);}
    @property @safe pure nothrow @nogc const {
        Result front() {return typeof(return)(cofficient_, bits_.value, offset_);}
        bool empty() {return bits_.empty;}
    }
    @safe nothrow @nogc void popFront()
    in {
        assert(!empty);
    } body {
        // 初期値のビットを取り出し、偶奇性を判定
        // 奇数の場合はa(2x + 1)+b == 2ax + a + b
        // 偶数の場合は係数のみ倍
        if(bits_.front) {
            offset_ += cofficient_;
        }
        cofficient_ <<= ONE;

        // 係数が偶数であれば全体の偶奇性が係数・オフセットから判定できる
        // 判定できる限りは処理を進める
        while(cofficient_.even) {
            if(offset_.odd) {
                cofficient_ *= 3;
                offset_ *= 3;
                offset_ += 1;
            } else {
                cofficient_ >>>= ONE;
                offset_ >>>= ONE;
            }
        }

        // 次のビットへ
        bits_.popFront();
    }
private:
    enum ONE = cast(T) 1;
    Bits!T bits_;
    T cofficient_ = ONE;
    T offset_ = 0;
}

///
unittest {
    auto c = Collatz!uint(0b111);
    alias Result = typeof(c).Result;
    assert(!c.empty);
    assert(c.front == Result(1, 0));

    // (3(2n + 1) + 1) == (6n + 4) -> (3n + 2)
    c.popFront();
    assert(!c.empty);
    assert(c.front == Result(3, 2));

    // (3(2n + 1) + 2) == (6n + 5) -> (18n + 16) -> (9n + 8)
    c.popFront();
    assert(!c.empty);
    assert(c.front == Result(9, 8));

    c.popFront();
    assert(c.empty);
}

unittest {
    auto c = Collatz!uint(0b1001);
    alias Result = typeof(c).Result;
    assert(c.front == Result(1, 0));

    // 1
    c.popFront();
    assert(c.front == Result(3, 2));

    // 0
    c.popFront();
    assert(c.front == Result(3, 1));

    // 0
    c.popFront();
    assert(c.front == Result(9, 2));

    // 1
    c.popFront();
    assert(c.empty);
}

static assert(isInputRange!(Collatz!uint));

/// ユーティリティ関数
Collatz!T collatz(T)(T value) if(isIntegral!T) {return Collatz!T(value);}

void main() {
    enum BITS = 8;
    foreach(i; 0 .. BITS) {
        auto n = (2^^BITS-1) ^ (1 << i);
        auto r = collatz(n).array[$-1];
        writefln("%0*b %0*b %d", BITS, n, BITS * 2, r.value, r.value);
    }
    /*
    for(uint n = 27; n > 1;) {
        auto r = collatz(n).array[$-1];
        writefln("%s %b", r, r.value);
        n = r.value;
    }
    */
}

