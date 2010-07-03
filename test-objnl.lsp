(load "ObjNL.lsp")

; ----------------------------------------------------------------------------------------------
; !Example Usage and Testing
; ----------------------------------------------------------------------------------------------

(define-macro (eval-print what)
	(println what " => " (eval what))
)
(define (header h)
	(println "\n" h "\n" (dup "-" (- (length h) 1)))
)

(global 'eval-print 'header)

(define (protocol:test) "hello!")

(new-class 'Foo ObjNL '(protocol))
(new-class 'Bar)

(context Foo)
(define (Foo:Foo _bar)
	(setf bar _bar)
	true
)
(context Bar)
(define (Bar:Bar _foo)
	(setf foo _foo)
	true ; don't allow ourselves to be deallocated
)
(define (dealloc)
	(println Bar:@self " deallocated!")
)
(context MAIN)

(setf f (instantiate Foo (instantiate Bar)))

(eval-print f)
(eval-print f:bar)
(println "f:bar:foo => ERROR! Use dot function instead!")

(header "Testing dot functions:")
(eval-print (. f bar foo))
(eval-print (set (.& f bar foo) f))
(eval-print (. f bar foo))
(eval-print (set (.& f bar foo bar num) 5))
(eval-print (. f bar num))
(eval-print (. f bar foo bar foo bar num))

(header "Testing ObjNL vars:")
(eval-print f:@super)
(eval-print f:@class)
(eval-print f:@self)
(eval-print Foo:@super)
(eval-print Foo:@class)
(eval-print Foo:@self)

(header "Testing 'implements?':")
(eval-print f:@interfaces)
(eval-print (implements? ObjNL f))
(eval-print (implements? Foo f))
(eval-print (implements? Bar f))
(eval-print (implements? ObjNL f:bar))
(eval-print (symbols protocol))
(eval-print (implements? protocol f))
(eval-print (implements? protocol f:bar))
(eval-print (add-interface protocol f:bar))
(eval-print (implements? protocol f:bar))
(eval-print (if (implements? protocol f) (f:test)))

(header "Testing deallocation:")
(eval-print (deallocate f:bar))
(eval-print (deallocate f))
(eval-print f)
(eval-print (context? f))
(catch (eval-print (symbols f)) 'result)
(when result
	(println result "\n   Ignore that error, it's a newLISP bug.")
	(println "   Just don't use an object after it has been deallocated.")
)

(header "Testing retain/release/autorelease:")
(eval-print (push-autorelease-pool))
(eval-print (setf b (instantiate Bar)))
(eval-print (autorelease b))
(eval-print @autorelease)
(eval-print (pop-autorelease-pool))

(header "Testing autorelease in a different context:")
(context 'Test)
(println "(context 'Test)")
(eval-print (push-autorelease-pool))
(eval-print (dotimes (_ 5) (autorelease (instantiate Bar))))
(eval-print (pop-autorelease-pool))
(context MAIN)
(println "(context MAIN)")
(exit)
