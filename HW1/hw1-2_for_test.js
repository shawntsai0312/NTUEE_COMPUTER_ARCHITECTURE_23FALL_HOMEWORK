const readline = require('readline').createInterface({
    input: process.stdin,
    output: process.stdout
});

const ciphertext = (shift, plaintext) => {
    // alphabet : ASCII + shift (+-26) range : 97-122 or 0x62-0x7A
    // space : start from 0 to 9
    let textArr = [...plaintext];
    let spaceCounter = -1;
    textArr = textArr.map(e => {
        if (e == ' ') {
            spaceCounter++;
            return spaceCounter + 48;    // '0' = 48
        } else {
            let newASCII = e.charCodeAt(0) + shift;
            if (newASCII > 122) {        // 'z' = 122
                return newASCII - 26
            } else if (newASCII < 97) {  // 'a' = 97
                return newASCII + 26
            } else {
                return newASCII
            }
        }
    })
    return textArr;
}

readline.question('Please input shift : ', shiftAns => {
    readline.question('Please input plaintext : ', textAns => {
        let cipherASCII = ciphertext(parseInt(shiftAns, 10), textAns);
        let cipherString = cipherASCII.map(e => {
            return String.fromCharCode(e)
        }).join('')
        // console.log(cipherASCII);
        console.log(cipherString);
        readline.close();
    })
})
