import React from 'react';
import {useLocation} from '@docusaurus/router';

// Simple Root wrapper that keys the content by the pathname so mounting a new
// page can be animated via CSS. This keeps things lightweight and avoids
// adding an animation library.
export default function Root({children}) {
  const location = useLocation();
  const prevRef = React.useRef(null);

  // Compute animation mode based on previous and current pathnames.
  // - Full animation when both prev and current are in the 'site' set
  //   (home, api, blog).
  // - Doc-inner animation when both prev and current are docs pages (/docs/*).
  const computeAnimationClass = (prev, current) => {
    if (!prev || !current) return '';

    const normalize = (p) => {
      try {
        // remove query/hash
        const u = p.split(/[?#]/, 1)[0];
        // strip trailing slash except for root
        if (u.length > 1 && u.endsWith('/')) return u.slice(0, -1);
        return u;
      } catch (e) {
        return p;
      }
    };

    const pPrev = normalize(prev);
    const pCur = normalize(current);

    const siteSet = new Set(['/', '/blog', '/docs/getting-started']);

    const isSite = (q) => siteSet.has(q);
    const isDocs = (q) => q.startsWith('/docs');

  // Trigger full-page animation only when navigating between site-level pages
  // (home, blog, api). For docs→site or site→docs we do not
  // play the full animation. If both are docs pages, animate only the
  // inner docs content.

  // if (isSite(pPrev) && isSite(pCur)) return 'route-transition-full';
  // if (isDocs(pPrev) && isDocs(pCur)) return 'route-transition-docInner';
  //   return '';
  // }; // Nvm I'm gonna disable this for now since it's a bit janky

  if (true)
    return ''; // Disables the transition animations
  };

  const animationClass = computeAnimationClass(prevRef.current, location.pathname);

  // Debug log for diagnosis
  React.useEffect(() => {
    try {
      // eslint-disable-next-line no-console
      console.log('[Root] nav from', prevRef.current, 'to', location.pathname, '=>', animationClass);
    } catch (e) {}
    // store current for next navigation
    prevRef.current = location.pathname;
  }, [location.pathname]);

  return (
    <div className={`route-transition-outer ${animationClass}`}>
      <div key={location.pathname} className="route-transition-wrapper">
        {children}
      </div>
    </div>
  );
}
