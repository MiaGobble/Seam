// Build-time registration of a Luau Prism grammar.
// This file runs in Node (CommonJS) during the Docusaurus build.
try {
  // Load Prism and the existing lua component
  const Prism = require('prismjs');
  require('prismjs/components/prism-lua');

  // If luau is already registered, do nothing
  if (!Prism.languages.luau) {
    // Clone lua as a base
    const util = Prism.util || require('prismjs/components/prism-util');
    const base = Prism.languages.lua;
    const luau = util && util.clone ? util.clone(base) : Object.assign({}, base);

    // Add Luau-specific keywords and mark them as keywords
    Prism.languages.insertBefore('luau', 'keyword', {
      'luau-keyword': {
        pattern: /\b(?:type|export|interface|const|let|using|and|or|not|typeof|never|local)\b/,
        alias: 'keyword'
      }
    });

    // Highlight simple type annotations like `: Type` or `:: Type`
    Prism.languages.insertBefore('luau', 'function', {
      'luau-type': {
        pattern: /(::|:)\s*[A-Za-z_][A-Za-z0-9_<>\[\].]*/,
        alias: 'class-name'
      }
    });

    // Register the language
    Prism.languages.luau = luau;
  }
} catch (e) {
  // Fail gracefully; building should continue even if registration fails
  // eslint-disable-next-line no-console
  console.warn('prism-register-luau: could not register luau grammar', e && e.message ? e.message : e);
}
