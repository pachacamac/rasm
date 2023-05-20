/*credit goes to chatgpt for translating the old ruby code to js*/

class RASM {
    run(code, opts = {}) {
        opts.op_limit = opts.op_limit || 99999;
        opts.debug = opts.debug || console.debug;
        opts.output = opts.output || console.info;
        let tokens = code
            .replace(/(\*.*?\*)|[^a-z0-9-@._\n,]/g, "")
            .split("\n")
            .filter(e=>e);
        this.vars = { _pc: -1, _oc: 0 };
        let stack = [];
        let i = 0;
        tokens = tokens.map((t) =>
            t.charAt(0) === "@"
                ? ((this.vars[t] = i - 1), null)
                : ((i += 1),
                    t.split(",").map((e) =>
                        this.numeric(e) ? parseInt(e) : e)
                    )).filter(e=>e);
        while (this.vars._pc < tokens.length - 1) {
            this.vars._pc += 1;
            this.vars._oc += 1;
            this.vars._ss = stack.length;
            if (this.vars._oc > opts.op_limit) {
                throw new Error("too many operations!");
            }
            let [cmd, a, b, c] = tokens[this.vars._pc];
            opts.debug(tokens[this.vars._pc], this.vars); // for debug purposes only
            switch (cmd) {
                case "let":
                    this.set(a, b);
                    break;
                case "out":
                    opts.output(this.get(a));
                    break;
                case "dbg":
                    opts.debug(a);
                    break;
                case "add":
                    this.set(a, this.get(a) + this.get(b));
                    break;
                case "sub":
                    this.set(a, this.get(a) - this.get(b));
                    break;
                case "mul":
                    this.set(a, this.get(a) * this.get(b));
                    break;
                case "mod":
                    this.set(a, this.get(a) % this.get(b));
                    break;
                case "div":
                    this.set(a, this.get(a) / this.get(b));
                    break;
                case "jmp":
                    this.vars._pc = this.get(a);
                    break;
                case "jis":
                    if (this.get(a) < this.get(b)) {
                        this.vars._pc = this.get(c);
                    }
                    break;
                case "jig":
                    if (this.get(a) > this.get(b)) {
                        this.vars._pc = this.get(c);
                    }
                    break;
                case "jie":
                    if (this.get(a) === this.get(b)) {
                        this.vars._pc = this.get(c);
                    }
                    break;
                case "jiu":
                    if (this.get(a) !== this.get(b)) {
                        this.vars._pc = this.get(c);
                    }
                    break;
                case "end":
                    this.vars._pc = tokens.length;
                    break;
                case "pus":
                    stack.push(this.get(a));
                    break;
                case "pop":
                    this.set(a, stack.pop());
                    break;
                default:
                    throw new Error(
                        `unknown command '${cmd}' at ${ tokens[this.vars._pc]}`
                    );
            }
        }
        return this.vars;
    }

    get(s) {
        return this.vars.hasOwnProperty(s)
            ? this.vars[s]
            : this.numeric(s)
                ? parseInt(s)
                : 0;
    }

    set(s, v) {
        this.vars[s] = this.get(v);
    }

    numeric(n){
        return !isNaN(parseFloat(n)) && isFinite(n);
    }
}
