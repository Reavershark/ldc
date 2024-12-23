module core.internal.util.alignment;

pure nothrow @nogc:


T alignUp(size_t alignment = size_t.sizeof, T)(T base)
{
    enum mask = alignment - 1;
    static assert(alignment > 0 && (alignment & mask) == 0, "alignment must be a power of 2");
    auto b = cast(size_t) base;
    b = (b + mask) & ~mask;
    return cast(T) b;
}

unittest
{
    assert(1.alignUp == size_t.sizeof);
    assert(31.alignUp!16 == 32);
    assert(32.alignUp!16 == 32);
    assert(33.alignUp!16 == 48);
    assert((-9).alignUp!8 == -8);
}


version (BigEndian)
{
    // Adjusts a size_t-aligned pointer for types smaller than size_t.
    T* adjustForBigEndian(T)(T* p, size_t size)
    {
        return size >= size_t.sizeof ? p :
            cast(T*) ((cast(void*) p) + (size_t.sizeof - size));
    }
}
