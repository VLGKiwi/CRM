import bcrypt from 'bcryptjs';

const password = 'admin123';
const existingHash = '$2a$10$XFE0DcAdWRMsUVEMPZxXU.K.6Oxe5kHww3lNMlYRKXqHNyPu4uGCa';

// Проверяем существующий хеш
bcrypt.compare(password, existingHash).then(isValid => {
    console.log('Existing hash check:', isValid);
});

// Создаем новый хеш
bcrypt.hash(password, 10).then(newHash => {
    console.log('New hash:', newHash);

    // Проверяем новый хеш
    bcrypt.compare(password, newHash).then(isValid => {
        console.log('New hash check:', isValid);
    });
});
