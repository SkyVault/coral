import tables

proc memoize*[A, B](f: proc(a: A): B): proc(a: A): B =
  ## Returns a memoized version of the given procedure.
  var cache = initTable[A, B]()

  result = proc(a: A): B =
    if cache.hasKey(a):
      result = cache[a]
    else:
      result = f(a)
      cache[a] = result