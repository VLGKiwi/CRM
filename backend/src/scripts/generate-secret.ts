import crypto from 'crypto';

// Generate a random string of 64 bytes (512 bits)
const secret = crypto.randomBytes(64).toString('hex');

console.log('Generated JWT Secret:');
console.log(secret);
console.log('\nGenerated JWT Refresh Secret:');
console.log(crypto.randomBytes(64).toString('hex'));
