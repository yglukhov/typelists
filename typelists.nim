import macros

proc getTupleImpl(t: typedesc[tuple]): NimNode =
    getTypeImpl(t)[1].getTypeImpl()

macro typeListLen*(t: typedesc[tuple]): int =
    t.getTupleImpl().len

proc recursiveReplace*(n: NimNode, occurence: string, withNode: NimNode) =
    for i in 0 ..< n.len:
        let c = n[i]
        if c.kind == nnkIdent:
            if $c == occurence:
                n[i] = copyNimTree(withNode)
        else:
            recursiveReplace(c, occurence, withNode)

macro typeListFromValues*(values: varargs[typed]): untyped =
    result = newNimNode(nnkPar)
    for v in values:
        result.add(newCall(newIdentNode("type"), v))

macro typeListMapIt*(t: typedesc[tuple], predicate: untyped): untyped =
    let impl = t.getTupleImpl()
    result = newNimNode(nnkPar)
    for i in 0 ..< impl.len:
        let it = impl[i]
        let pred = copyNimTree(predicate)
        recursiveReplace(pred, "it", it)
        result.add(pred)

macro makeTypeListIt*(size: static[int], predicate: untyped): untyped =
    result = newNimNode(nnkPar)
    for i in 0 ..< size:
        let pred = copyNimTree(predicate)
        recursiveReplace(pred, "it", newLit(i))
        result.add(pred)

macro typeListTypeAt*(t: typedesc[tuple], pos: static[int]): untyped =
    t.getTupleImpl()[pos]

macro typeListTypeRepr*(t: typed): untyped =
    newLit(repr(t.getTypeImpl()[1].getTypeImpl()))

macro typeListFindIt*(t: typedesc[tuple], predicate: untyped): untyped =
    let impl = t.getTupleImpl()
    result = newNimNode(nnkWhenStmt)
    for i in 0 ..< impl.len:
        let it = impl[i]
        let pred = copyNimTree(predicate)
        recursiveReplace(pred, "it", it)
        let elifBranch = newNimNode(nnkElifExpr)
        elifBranch.add(pred, newLit(i))
        result.add(elifBranch)

    result.add(newNimNode(nnkElseExpr).add(newLit(-1)))

macro tupleRemoveElemsMasked(t: typedesc[tuple], mask: static[openarray[bool]]): untyped =
    let impl = t.getTupleImpl()
    assert(impl.len == mask.len)
    result = newNimNode(nnkPar)
    for i in 0 ..< impl.len:
        if mask[i]:
            result.add(impl[i])

macro makeTupleFilterMask(t: typedesc[tuple], predicate: untyped): untyped =
    let impl = t.getTupleImpl()
    result = newNimNode(nnkBracket)
    for i in 0 ..< impl.len:
        let it = impl[i]
        let pred = copyNimTree(predicate)
        recursiveReplace(pred, "it", it)
        result.add(pred)
    # echo "MASK: ", treeRepr(result)

template typeListFilterIt*(t: typedesc[tuple], predicate: untyped): untyped =
    tupleRemoveElemsMasked(t, makeTupleFilterMask(t, predicate))

macro typeListAppend*(t: typedesc[tuple], v: untyped): untyped =
    result = t.getTupleImpl().copyNimTree()
    result.add(v)

macro typeListAppendTuple*(t1: typedesc[tuple], t2: typedesc[tuple]): untyped =
    result = t1.getTupleImpl().copyNimTree()
    for c in t2.getTupleImpl().copyNimTree(): result.add(c)

template typeListFind*(t: typedesc, v: typedesc): int = typeListFindIt(t, it is v)

proc countBools(b: openarray[bool]): int =
    for bb in b:
        if bb: inc result

template typeListCountIt*(t: typedesc[tuple], predicate: untyped): int =
    block:
        const r = countBools(makeTupleFilterMask(t, predicate))
        r

macro typeListDel*(t: typedesc[tuple], a, b: static[int]): untyped =
    let impl = t.getTupleImpl()
    result = newNimNode(nnkPar)
    for i in 0 ..< impl.len:
        if i < a or i > b:
            result.add(impl[i])
