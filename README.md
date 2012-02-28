Simple Assembler-like Language and Interpreter
==============================================

Can do jumps, conditions, calculations and other stuff a tiny language should be able to do.

Executes code that looks like this:

    *==========[ stack test ]===========*
    *construct for a subroutine call*
    let,n,7
    let,@rj,_pc
    add,@rj,2
    jmp,@fac
    out,n  *print result*
    end    *end here*
    *=========[ subroutines ]=========*
    @fac *calculates faculty of n, uses t, uses the stack, result in n*
      pus,n
      sub,n,1
      jig,n,1,@fac
      @facloop
        pop,t
        mul,n,t
      jig,_ss,0,@facloop
    jmp,@rj
    *===================================*

