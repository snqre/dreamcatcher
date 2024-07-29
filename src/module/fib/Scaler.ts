

class S {
    public static calculate(tick: number): number {
        if (tick <= 1) {
            return tick;
        }
        let a = 0;
        let b = 1;
        for (let i = 2; i <= tick; i += 1) {
            let next = a + b;
            a = b;
            b = next;
        }
        return b;
    }
}

console.log(S.calculate(14))