module.exports = function registerLuauPlugin() {
  return {
    name: 'register-luau-prism',
    async loadContent() {
      try {
        require('../../prism-register-luau.cjs');
      } catch (e) {
        // eslint-disable-next-line no-console
        console.warn('register-luau plugin failed to register luau', e && e.message ? e.message : e);
      }
    },
  };
};
