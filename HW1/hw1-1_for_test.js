const readline = require('readline').createInterface({
    input: process.stdin,
    output: process.stdout
});

const T = n => {
    if (n > 1) {
        return 5 * T(Math.floor(n / 2)) + 6 * n + 4;
    } else if (n == 1) {
        return 2;
    } else {
        return 0;
    }
}

readline.question('Please input an integer n : ', n => {
    console.log(`The answer is ${T(n)}`);
    readline.close();
})