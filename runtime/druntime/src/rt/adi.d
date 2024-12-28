/**
 * Implementation of dynamic array property support routines.
 *
 * Copyright: Copyright Digital Mars 2000 - 2015.
 * License: Distributed under the
 *      $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0).
 *    (See accompanying file LICENSE)
 * Authors:   Walter Bright
 * Source: $(DRUNTIMESRC rt/_adi.d)
 */

module rt.adi;

debug (rt_adi_trace) debug = trace;

debug (trace) private alias logTrace = imported!"core.internal.util.log".log!"trace";

/***************************************
 * Support for array equality test.
 * Returns:
 *      1       equal
 *      0       not equal
 */

extern (C) int _adEq2(void[] a1, void[] a2, TypeInfo ti)
{
    debug (trace) logTrace!"_adEq2(a1.length = %d, a2.length = %d)"(a1.length, a2.length);
    if (a1.length != a2.length)
        return 0;               // not equal
    if (!ti.equals(&a1, &a2))
        return 0;
    return 1;
}

@safe unittest
{
    debug (trace) logTrace!"array.Eq unittest";

    struct S(T) { T val; }
    alias String = S!string;
    alias Float = S!float;

    String[1] a = [String("hello"c)];

    assert(a != [String("hel")]);
    assert(a != [String("helloo")]);
    assert(a != [String("betty")]);
    assert(a == [String("hello")]);
    assert(a != [String("hxxxx")]);

    Float[1] fa = [Float(float.nan)];
    assert(fa != fa);
}

unittest
{
    debug (trace) logTrace!"struct.Eq unittest";

    static struct TestStruct
    {
        int value;

        bool opEquals(const TestStruct rhs) const
        {
            return value == rhs.value;
        }
    }

    TestStruct[] b = [TestStruct(5)];
    TestStruct[] c = [TestStruct(6)];
    assert(_adEq2(*cast(void[]*)&b, *cast(void[]*)&c, typeid(TestStruct[])) == false);
    assert(_adEq2(*cast(void[]*)&b, *cast(void[]*)&b, typeid(TestStruct[])) == true);
}
