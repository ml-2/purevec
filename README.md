A persistent vector library implemented in pure Janet, released under the public domain. It is more of a curiosity than practical tool.

## Gotchas

### Silently Getting Invalid Results

The persistent vectors are implemented using a tree of tuples. This means that functions that work on tuples will seem to work at first glance but give invalid results. This includes functions such as `length`, `first`, `last`, `empty?`, `get`, etc. Instead, use `pvec/length`, `pvec/first`, `pvec/last`, `pvec/empty?`, and `pvec/get` respectively.

The built-in iteration functions such as `each` and `next` will also work incorrectly. To properly iterate, use `pvec/iter` which returns a coroutine that iterates over the vector.

There is also no way to recursively convert vectors to a pretty string because there is no way to tell the difference between vectors and tuples.

### Speed

This library is not very optimized and is much slower than the persistent vectors you might find in, say, Clojure. To give some sense of this, on my computer, it takes about 4 seconds to append a million elements to an initially empty vector.

It is O(log n) to append elements (using `pvec/conj`), remove elements from the end (using `pvec/pop`), to access elements at any index (using `pvec/get`), and to set an element at any index (using `pvec/set`).

These performance characteristics can be affected by the garbage collector, and so may be slower than stated on larger vectors. For example, when the garbage collector is disabled, it consistently takes 4 seconds on my computer to append 32^4 (~1_000_000) elements to a vector that already has over 32^4 elements (but less than 32^5 elements). When the garbage collector is enabled, however, it takes longer the longer the vector, taking 4 seconds for the first 32^4 elements, 7 for the next 32^4, then 9 seconds, then 11.

### Equality

Equality on vectors works as expected with =, and they can be used as keys in structs and tables. However, beware that vectors can be equal to some other tuples, for example the empty vector equals the tuple (0), so don't mix tuples and vectors as keys in the same table.

## Installation

To install locally for a project:

```
jpm install --local https://github.com/ml-2/purevec
```

To install globally:

```
jpm install https://github.com/ml-2/purevec
```

Alternatively, since it is public domain and the source is in a single file, you could copy the file purevec.janet in this repo into your project directly.

## API

Every function in purevec starts with `pvec/`, so it is safe to `use` the library instead of `import`ing it with a prefix.

```
(pvec/empty? pvec) :: Returns true if the value is an empty pvec.

(pvec/conj pvec elem) :: Returns a new pvec with elem appended to the end.

(pvec/pop pvec) :: Returns a new pvec with the last element removed.

(pvec/set pvec n elem) :: Returns a new pvec with the nth element set to elem. Errors when out of bounds.

(pvec/get pvec n) :: Gets the nth element of the vector, or nil when out of bounds.

(pvec/length pvec) :: The number of elements in the vector.

(pvec/first pvec) :: The first element of the vector.

(pvec/last pvec) :: The last element of the vector.

(pvec/iter pvec) :: Returns a coroutine iterating over the elements of the vector.

(pvec/new & args) :: Creates a new pvector and uses conj to append all args to it.

(pvec/tostring pvec) :: Converts a pvec to a string. This does not work recursively.

(pvec/pp pvec) :: Pretty-prints a persistent vector. This does not work recursively.
```
