// modified_fibonacci.js

function modifiedFibonacci(n = 1, prev = 1) {
    const lastDigit = n % 10 || 1; // Get last digit, avoid division by zero
    const next = n + prev / lastDigit;
    return next;
}

// Generate and print the first N modified Fibonacci numbers
function generateSequence(count = 10) {
    let prev = 1;
    let current = 1;
    console.log(`0: ${prev}`);
    console.log(`1: ${current}`);

    for (let i = 2; i < count; i++) {
        const next = modifiedFibonacci(current, prev);
        let int = Math.round(next);
        console.log(`${i}: ${int},  f: ${next.toFixed(4)}`);
        prev = current;
        current = next;
    }
}

generateSequence(100);
