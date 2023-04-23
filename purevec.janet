# purevec - Persistent vectors in pure Janet

# Written in 2023 by ML.

# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.

# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

(def PVEC-MAX 32)

(defn- pvec/len [pvec]
  (dec (length pvec)))

(defn pvec/depth
  `Returns the depth of the tree representing this vector.`
  [pvec]
  (first pvec))

(defn- pvec/full? [pvec]
  (and (= (pvec/len pvec) PVEC-MAX)
       (or (= (pvec/depth pvec) 0) (pvec/full? (last pvec)))))

(defn- pvec/new-node [depth elem]
  (if (= depth 0)
    [0 elem]
    [depth (pvec/new-node (dec depth) elem)]))

(defn pvec/empty?
  `Returns true if the value is an empty pvec.`
  [pvec]
  (= pvec [0]))

(defn pvec/conj
  `Returns a new pvec with elem appended to the end.`
  [pvec elem]
  (cond
    (pvec/full? pvec)
    [(inc (pvec/depth pvec)) pvec (pvec/new-node (pvec/depth pvec) elem)]
    (= (pvec/depth pvec) 0)
    [;pvec elem]
    (and (not= (pvec/depth pvec) 0) (pvec/full? (last pvec)))
    [;pvec (pvec/new-node (dec (pvec/depth pvec)) elem)]
    # else
    [;(tuple/slice pvec 0 -2) (pvec/conj (last pvec) elem)]))

(defn pvec/pop
  `Returns a new pvec with the last element removed.`
  [pvec]
  (cond
    (pvec/empty? pvec)
    pvec
    (= (pvec/depth pvec) 0)
    (tuple/slice pvec 0 -2)
    # else
    (do
      (def popped (pvec/pop (last pvec)))
      (cond
        (pvec/empty? popped)
        (cond (= (pvec/len pvec) 2)
              (get pvec 1)
              (= (pvec/len pvec) 1)
              popped
              (tuple/slice pvec 0 -2))
        (= (inc (pvec/depth popped)) (pvec/depth pvec))
        [;(tuple/slice pvec 0 -2) popped]
        # else
        (do
          (def depth (dec (pvec/depth pvec)))
          (defn new-node [node]
            (if (= (pvec/depth node) depth)
              node
              (new-node [(inc (pvec/depth node)) node])))
          [;(tuple/slice pvec 0 -2) (new-node popped)])))))

(defn- pvec/set- [pvec n elem]
  (if (= (pvec/depth pvec) 0)
    (do
      (when (>= n (pvec/len pvec))
        (error "Index out of bounds"))
      [;(tuple/slice pvec 0 (inc n))
       elem
       ;(tuple/slice pvec (+ n 2))])
    (do
      (def divisor (math/pow PVEC-MAX (pvec/depth pvec)))
      (def current-n (math/floor (/ n divisor)))
      (def new-n (% n divisor))
      (when (> current-n (pvec/len pvec))
        (error "Index out of bounds"))
      [;(tuple/slice pvec 0 (inc current-n))
       (pvec/set- (get pvec (inc current-n)) new-n elem)
       ;(tuple/slice pvec (+ current-n 2))])))

(defn pvec/set
  `Returns a new pvec with the nth element set to elem. Errors when out of bounds.`
  [pvec n elem]
  (when (or (not (int? n)) (< n 0))
    (error "Index out of bounds"))
  (pvec/set- pvec n elem))

(defn pvec/get
  `Gets the nth element of the vector, or nil when out of bounds.`
  [pvec n]
  (if (= (pvec/depth pvec) 0)
    (get pvec (inc n))
    (do
      (def divisor (math/pow PVEC-MAX (pvec/depth pvec)))
      (def current-n (math/floor (/ n divisor)))
      (def new-n (% n divisor))
      (if (> current-n (pvec/len pvec))
        nil
        (pvec/get (get pvec (inc current-n)) new-n)))))

(defn pvec/length
  `The number of elements in the vector.`
  [pvec]
  (if (= (pvec/depth pvec) 0)
    (pvec/len pvec)
    (do
      (def power (math/pow PVEC-MAX (pvec/depth pvec)))
      (+ (* power (dec (pvec/len pvec))) (pvec/length (last pvec))))))

(defn pvec/first
  `The first element of the vector.`
  [pvec]
  (pvec/get pvec 0))

(defn pvec/last
  `The last element of the vector.`
  [pvec]
  (pvec/get pvec (dec (pvec/length pvec))))

(defn pvec/iter
  `Returns a coroutine iterating over the elements of the vector.`
  [pvec]
  (coro
   (defn recur [pvec]
     (if (= (pvec/depth pvec) 0)
       (for i 1 (length pvec)
         (yield (get pvec i)))
       (for i 1 (length pvec)
         (recur (get pvec i)))))
   (recur pvec)))

(defn pvec/new
  `Creates a new pvector and uses conj to append all args to it.`
  [& args]
  (var result [0])
  (each elem args
    (set result (pvec/conj result elem)))
  result)

(defn pvec/tostring
  `Converts a pvec to a string. This does not work recursively.`
  [pvec]
  (def buf @"")
  (with-dyns [*out* buf]
    (prin "<pvec")
    (each elem (pvec/iter pvec)
      (prin " " elem))
    (prin ">"))
  (freeze buf))

(defn pvec/toprettystring
  `Converts a pvec to a string, pretty printing its elements. This does not work recursively.`
  [pvec]
  (def buf @"")
  (with-dyns [*out* buf]
    (prin "<pvec")
    (each elem (pvec/iter pvec)
      (prin " ")
      (prinf "%p" elem))
    (prin ">"))
  (freeze buf))

(defn pvec/prin
  `Prints a persistent vector without a trailing newline. This does not work recursively.`
  [pvec]
  (prin (pvec/tostring pvec)))

(defn pvec/print
  `Prints a persistent vector. This does not work recursively.`
  [pvec]
  (print (pvec/tostring pvec)))

(defn pvec/pp
  `Pretty-prints a persistent vector. This does not work recursively.`
  [pvec]
  (print (pvec/toprettystring pvec)))
