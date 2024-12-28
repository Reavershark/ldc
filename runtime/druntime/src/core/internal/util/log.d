module core.internal.util.log;

nothrow @nogc:

template log(string name = "", string module_ = __MODULE__)
{
    void log(string fmt, Args...)(scope const Args args)
    {
        version (Windows)
            enum string endl = "\r\n";
        else
            enum string endl = "\n";

        enum string fmtPrefix = "[" ~ module_ ~ (name.length ? ":" ~ name : "") ~ "] ";
        enum string fmtSuffix = endl;
        enum string fmtComplete = fmtPrefix ~ fmt ~ fmtSuffix;

        if (__ctfe)
        {
            __ctfeWrite(fmtComplete); // log TODO: format
        }
        else
        {
            import core.atomic : atomicLoad;
            import core.stdc.stdio : fflush, fprintf, stderr;
            fprintf(atomicLoad(stderr), &fmtComplete[0], args);
            fflush(atomicLoad(stderr));
        }
    }
}