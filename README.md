# typelists [![Build Status](https://travis-ci.org/yglukhov/typelists.svg?branch=master)](https://travis-ci.org/yglukhov/typelists) [![nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble_js.png)](https://github.com/yglukhov/nimble-tag)
Typelists in Nim

## Usage

See more examples in the [test file](https://github.com/yglukhov/typelists/blob/master/tests/test1.nim)

```nim
import typelists, unittest

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
      typeListRepr(MyTup) == "(int, float)"
      typeListRepr(TupleOf5Ints) == "(int, int, int, int, int)"
      typeListRepr(TupleOf5IntsAndFloat) == "(int, int, int, int, int, float)"
      typeListRepr(TupleOf5IntsAndFloatAndMyTup) == "(int, int, int, int, int, float, int, float)"
      typeListRepr(MyTup2WithFloatsDeleted) == "(int, int)"
      typeListRepr(InvertFloatsanInts) == "(float, int, int, float)"
      typeListRepr(Foo) == "(float, int32)"

      typeListCountIt(MyTup2, it is float) == 2
      typeListCountIt(MyTup2, it is int) == 2

      typeListLen(TupleOf5Ints) == 5

      typeListLen(MyTup) == 2

      typeListFind(MyTup, float) == 1
      typeListFind(MyTup, int) == 0

      (typeListTypeAt(MyTup, 0) is int) == true
      (typeListTypeAt(MyTup, 1) is float) == true
```
