// modified_fibonacci.js

function rmf100(n) {
    if(n === 0) return [];
    if(n === 1) return [0];
    let a = [0, 1]
    while (a.length < n) {
        a.push(Math.round(a[a.length-1] +a[a.length-2] / (a[a.length-1] % 100 || 1)));
    }
    return a;
}

function modifiedFibonacci(n = 1, prev = 1, mod = 10) {
    const lastDigit = n % mod || 1; // Get the last digit, avoid division by zero
    const next = n + prev / lastDigit;
    return next;
}

function modifiedFibonacci2(n = 1, prev = 1, mod = 10) {
    const lastDigit = n % mod || 1; // Get the last digit, avoid division by zero
    const next = (n + prev) / lastDigit;
    return next;
}
function normalFibonacci(n = 1, prev = 1) {
    return n + prev;
}

// Generate and print the first N modified Fibonacci numbers
function generateSequence(count = 10) {
    let prev = 1;
    let current = 1;
    console.log(`0: ${prev}`);
    console.log(`1: ${current}`);

    let np = 1; let nc = 1;
    for (let i = 2; i < count; i++) {
        const next = modifiedFibonacci(current, prev, 100);
        let int = Math.round(next);
        const norm = normalFibonacci(nc, np);
        console.log(`${i}: ${int},  f: ${next.toFixed(4)} \t\t n: ${norm} \t dif: ${int - norm}`);
        prev = current;
        current = next;
        np = nc;
        nc = norm;
    }
}
let n = 256
generateSequence(n);
console.log(JSON.stringify(rmf100(n), null, 2));
console.log(JSON.stringify(rmf100(0), null, 2));
console.log(JSON.stringify(rmf100(1), null, 2));
console.log(JSON.stringify(rmf100(2), null, 2));
console.log(JSON.stringify(rmf100(3), null, 2));