; we need QF_UFBV for this proof
(set-logic QF_UFBV)

; insert the auto-generated code here
%%

; declare state variables s1
(declare-fun s1 () intmult_s)

(assert (= (|intmult_n product| s1)
		   (bvmul
		     (|intmult_n a| s1)
		     (|intmult_n b| s1))))

; is there such a model?
(check-sat)
;(get-model)
