import unittest
include nre

suite "captures":
  test "map capture names to numbers":
    check(getNameToNumberTable(initRegex("(?<v1>1(?<v2>2(?<v3>3))(?'v4'4))()")) == 
      { "v1" : 0, "v2" : 1, "v3" : 2, "v4" : 3 }.toTable())

  test "capture bounds are correct":
    let ex1 = initRegex("([0-9])")
    check("1 23".match(ex1).matchBounds == 0 .. 1)
    check("1 23".match(ex1).captureBounds[0].get == 0 .. 1)
    check("1 23".match(ex1, 1).matchBounds == 2 .. 3)
    check("1 23".match(ex1, 3).matchBounds == 3 .. 4)

    let ex2 = initRegex("()()()()()()()()()()([0-9])")
    check("824".match(ex2).captureBounds[0].get == 0 .. 0)
    check("824".match(ex2).captureBounds[10].get == 0 .. 1)

    let ex3 = initRegex("([0-9]+)")
    check("824".match(ex3).captureBounds[0].get == 0 .. 3)

  test "named captures":
    let ex1 = "foobar".match(initRegex("(?<foo>foo)(?<bar>bar)"))
    check(ex1.captures["foo"] == "foo")
    check(ex1.captures["bar"] == "bar")

    let ex2 = "foo".match(initRegex("(?<foo>foo)(?<bar>bar)?"))
    check(ex2.captures["foo"] == "foo")
    check(ex2.captures["bar"] == nil)

  test "named capture bounds":
    let ex1 = "foo".match(initRegex("(?<foo>foo)(?<bar>bar)?"))
    check(ex1.captureBounds["foo"] == Some(0..3))
    check(ex1.captureBounds["bar"] == None[Slice[int]]())

  test "capture count":
    let ex1 = initRegex("(?<foo>foo)(?<bar>bar)?")
    check(ex1.captureCount == 2)
    check(ex1.captureNameId == {"foo" : 0, "bar" : 1}.toTable())

  test "named capture table":
    let ex1 = "foo".match(initRegex("(?<foo>foo)(?<bar>bar)?"))
    check(ex1.captures.asTable == {"foo" : "foo", "bar" : nil}.toTable())
    check(ex1.captureBounds.asTable == {"foo" : Some(0..3), "bar" : None[Slice[int]]()}.toTable())
    check(ex1.captures.asTable("") == {"foo" : "foo", "bar" : ""}.toTable())

    let ex2 = "foobar".match(initRegex("(?<foo>foo)(?<bar>bar)?"))
    check(ex2.captures.asTable == {"foo" : "foo", "bar" : "bar"}.toTable())

  test "capture sequence":
    let ex1 = "foo".match(initRegex("(?<foo>foo)(?<bar>bar)?"))
    check(ex1.captures.asSeq == @["foo", nil])
    check(ex1.captureBounds.asSeq == @[Some(0..3), None[Slice[int]]()])
    check(ex1.captures.asSeq("") == @["foo", ""])

    let ex2 = "foobar".match(initRegex("(?<foo>foo)(?<bar>bar)?"))
    check(ex2.captures.asSeq == @["foo", "bar"])

