module.exports = {
  'users-permissions': {
    enabled: true,
    config: {
      jwtSecret: process.env.JWT_SECRET || 'sua-chave-super-secreta',
    },
  },
};