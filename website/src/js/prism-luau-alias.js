// Client module to register a Luau Prism language.
// This creates `Prism.languages.luau` by cloning `lua` and adding Luau-specific
// tokens (types, export/type keywords, and type annotations). It runs in the
// browser after Prism is available.
function tryRegister() {
  try {
    const Prism = window.Prism || (window.require && window.require('prismjs'));
    if (!Prism || !Prism.languages) return false;

    if (Prism.languages.luau) return true; // already registered

    if (Prism.languages.lua && Prism.util && Prism.util.clone) {
      const base = Prism.languages.lua;
      const luau = Prism.util.clone(base);

      Prism.languages.insertBefore('luau', 'keyword', {
        'luau-keyword': {
          pattern: /\b(?:type|export|interface|const|let|using|and|or|not)\b/,
          alias: 'keyword'
        }
      });

      Prism.languages.insertBefore('luau', 'function', {
        'luau-type-annotation': {
          pattern: /(::|:)\s*[A-Za-z_][A-Za-z0-9_<>\[\].]*/,
          alias: 'symbol'
        }
      });

      Prism.languages.luau = luau;
      return true;
    } else if (Prism.languages.lua) {
      Prism.languages.luau = Prism.languages.lua;
      return true;
    }
  } catch (e) {
    // ignore
  }
  return false;
}

function reHighlight() {
  try {
    const Prism = window.Prism || (window.require && window.require('prismjs'));
    if (!Prism || !Prism.highlightElement) return;
    document.querySelectorAll('pre code[class*="language-"]').forEach((block) => {
      Prism.highlightElement(block);
    });
  } catch (e) {
    // ignore
  }
}

export default function registerLuau() {
  // Try immediately
  if (tryRegister()) {
    reHighlight();
    return;
  }

  // Retry a few times with delays in case Prism hasn't loaded yet
  let attempts = 0;
  const maxAttempts = 6;
  const interval = setInterval(() => {
    attempts += 1;
    if (tryRegister()) {
      reHighlight();
      clearInterval(interval);
    } else if (attempts >= maxAttempts) {
      clearInterval(interval);
    }
  }, 500);

  // Also observe DOM to re-highlight dynamically added code blocks
  try {
    const observer = new MutationObserver((mutations) => {
      let found = false;
      for (const m of mutations) {
        if (m.addedNodes && m.addedNodes.length) {
          found = true; break;
        }
      }
      if (found) reHighlight();
    });
    observer.observe(document.body, {childList: true, subtree: true});
  } catch (e) {
    // ignore
  }
}

// Run on import so Docusaurus' clientModules will execute the registration
try {
  // eslint-disable-next-line no-undef
  if (typeof window !== 'undefined') {
    registerLuau();
  }
} catch (e) {
  // ignore
}
