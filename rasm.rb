#!/usr/bin/env ruby

class RASM
  def run(code, opts={})
    opts[:op_limit] ||= 9999
    opts[:debug] ||= false
    tokens = code.gsub(/(\*.*?\*)|[^a-z0-9\-@\._\n,]/,'').split("\n").reject(&:empty?)
    @vars,stack,i = {:_pc=>-1,:_oc=>0},[],0
    tokens.map!{|t| t.chars.first=='@' ?
                    (@vars[t.to_sym]=i-1;nil) :
                    (i+=1;t.split(',').map{|e|numeric?(e) ? e.to_i : e.to_sym})
               }.compact!
    while @vars[:_pc] < tokens.size-1
      @vars[:_pc] += 1
      @vars[:_oc] += 1
      @vars[:_ss] = stack.size
      raise 'too many operations!' if @vars[:_oc] > opts[:op_limit]
      cmd,a,b,c = tokens[@vars[:_pc]]
      puts "#{tokens[@vars[:_pc]]}\t#{@vars}" if opts[:debug]
      case cmd
        when :let; set(a, b)
        when :out; puts get(a)
        when :dbg; puts a
        when :add; set(a, get(a) + get(b))
        when :sub; set(a, get(a) - get(b))
        when :mul; set(a, get(a) * get(b))
        when :mod; set(a, get(a) % get(b))
        when :div; set(a, get(a) / get(b))
        when :jmp; @vars[:_pc] = get(a)
        when :jis; @vars[:_pc] = get(c) if get(a) < get(b)
        when :jig; @vars[:_pc] = get(c) if get(a) > get(b)
        when :jie; @vars[:_pc] = get(c) if get(a) == get(b)
        when :jiu; @vars[:_pc] = get(c) if get(a) != get(b)
        when :end; @vars[:_pc] = tokens.size
        when :pus; stack.push(get(a))
        when :pop; set(a, stack.pop)
        else raise "unknown command '#{cmd}' at #{tokens[@vars[:_pc]]}"
      end
    end
    @vars
  end

  private
  def get(s) (@vars.key?(s) ? @vars[s] : numeric?(s) ? s : 0).to_i end
  def set(s,v) @vars[s] = get(v) end
  def numeric?(n) true if Float(n) rescue false end
end

puts 'Example 1: pow(3,5)'

RASM.new.run('
*=== Main ===*
let,a,3            *arg 1 and result*
let,b,5            *arg 2*
let,@rj,_pc        *return address*
add,@rj,2
xxx,1,2
jmp,@power         *subroutine call*
out,a              *print result*
end
*=== Subroutines ===*
@power             *calculates pow(a,b) result in a. uses tmp*
  let,tmp,a
  @power1
    mul,a,tmp
    sub,b,1
    jig,b,1,@power1
  jmp,@rj          *return from subroutine*
')

puts 'Example 2: fac(7)'

RASM.new.run('
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
')

