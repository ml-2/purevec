(use /purevec)

(def original-interval (gcinterval))

(gcsetinterval 8_000_000_000)

(var x (pvec/new))

(var end-time nil)
(var start-time (os/time))

(for i 0 (* 32 32 32 32)
  (set x (pvec/conj x i)))

(set end-time (os/time))
(pp ["nocollect 32^4" (- end-time start-time)])
(flush)
(set start-time (os/time))

(for i 0 (* 32 32 32 32)
  (set x (pvec/conj x i)))

(set end-time (os/time))
(pp ["nocollect 32^4" (- end-time start-time)])
(flush)
(set start-time (os/time))

(for i 0 (* 32 32 32 32)
  (set x (pvec/conj x i)))

(set end-time (os/time))
(pp ["nocollect 32^4" (- end-time start-time)])
(flush)
(set start-time (os/time))

(for i 0 (* 32 32 32 32)
  (set x (pvec/conj x i)))

(set end-time (os/time))
(pp ["nocollect 32^4" (- end-time start-time)])
(flush)
(set start-time (os/time))

(for i 0 (* 32 32 32 32)
  (set x (pvec/conj x i)))

(set end-time (os/time))
(pp ["nocollect 32^4" (- end-time start-time)])
(flush)
(set start-time (os/time))

# Garbage collect and enable garbage collection

(set x (pvec/new))
(gccollect)

(set end-time (os/time))
(pp ["collection" (- end-time start-time)])
(flush)
(set start-time (os/time))

(gcsetinterval original-interval)

(for i 0 (* 32 32 32 32)
  (set x (pvec/conj x i)))

(set end-time (os/time))
(pp ["collect 32^4" (- end-time start-time)])
(flush)
(set start-time (os/time))

(for i 0 (* 32 32 32 32)
  (set x (pvec/conj x i)))

(set end-time (os/time))
(pp ["collect 32^4" (- end-time start-time)])
(flush)
(set start-time (os/time))

(for i 0 (* 32 32 32 32)
  (set x (pvec/conj x i)))

(set end-time (os/time))
(pp ["collect 32^4" (- end-time start-time)])
(flush)
(set start-time (os/time))

(for i 0 (* 32 32 32 32)
  (set x (pvec/conj x i)))

(set end-time (os/time))
(pp ["collect 32^4" (- end-time start-time)])
(flush)
(set start-time (os/time))
