import ../typelists, unittest

suite "Typelists":
    test "1":
        type MyTup = (int, float)
        type TupleOf5Ints = makeTypeListIt(5, int)
        type TupleOf5IntsAndFloat = typeListAppend(TupleOf5Ints, float)
        type TupleOf5IntsAndFloatAndMyTup = typeListAppendTuple(TupleOf5IntsAndFloat, MyTup)
        type MyTup2 = (int, float, float, int)
        type MyTup2WithFloatsDeleted = typeListDel(MyTup2, 1, 2)
        type InvertFloatsanInts = typeListMapIt(MyTup2, when it is float: int else: float)
        type Foo = typeListFilterIt((int, float, int32), it isnot int)

        check:
            typeListTypeRepr(MyTup) == "(int, float)"
            typeListTypeRepr(TupleOf5Ints) == "(int, int, int, int, int)"
            typeListTypeRepr(TupleOf5IntsAndFloat) == "(int, int, int, int, int, float)"
            typeListTypeRepr(TupleOf5IntsAndFloatAndMyTup) == "(int, int, int, int, int, float, int, float)"
            typeListTypeRepr(MyTup2WithFloatsDeleted) == "(int, int)"
            typeListTypeRepr(InvertFloatsanInts) == "(float, int, int, float)"
            typeListTypeRepr(Foo) == "(float, int32)"

            typeListCountIt(MyTup2, it is float) == 2
            typeListCountIt(MyTup2, it is int) == 2

            typeListLen(TupleOf5Ints) == 5

            typeListLen(MyTup) == 2

            typeListFind(MyTup, float) == 1
            typeListFind(MyTup, int) == 0

            (typeListTypeAt(MyTup, 0) is int) == true
            (typeListTypeAt(MyTup, 1) is float) == true

    test "From values":
        var a: int
        let b = float(1.2)
        let c = "hello"
        type Foo = typeListFromValues(a, b, c)

        check:
            typeListTypeRepr(Foo) == "(int, float, string)"

    test "Iterator":
        type Foo = (int, float)
        var i = 0
        typeListForEachIt(Foo):
            if i == 0:
                assert(it is int)
            else:
                assert(it is float)
            inc i
