export function convertToArray(value: string, numBytes: number = 4): number[] {
    const result: number[] = [];

    if (value.startsWith("0x")) {
        value = value.slice(2);
    }
    const size = 2 * numBytes;
    const num = Math.ceil(value.length / size);

    for (let i = 0; i < num; i++) {
        const row = value.slice(i * size, (i + 1) * size);
        result.push(parseInt(row, 16));
    }

    return result.reverse();
}


export function getLinkToTransaction(hash: string) {
    return `https://nile.tronscan.io/#/transaction/${hash}`;
}


export function sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
}
