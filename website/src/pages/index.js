import React from 'react';
import Layout from '@theme/Layout';
import styles from './index.module.css';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';

function Home() {
  const {siteConfig = {}} = useDocusaurusContext();
  return (
    <Layout title={siteConfig.title || 'Home'} description={siteConfig.tagline || 'Welcome'}>
      <main className={styles.hero}>
        <div className={styles.inner}>
          {/* hero tagline */}
          <h1 className={styles.taglineLarge}>{siteConfig.tagline || 'Documentation site'}</h1>

          <section className={styles.features}>
            <div className={styles.feature}>
              <h3>Easy to learn</h3>
              <p>A simple and flexible API allows you to do less learning and more developing.</p>
            </div>
            <div className={styles.feature}>
              <h3>Flexible and scalable</h3>
              <p>Seam is built for projects of any size; be one person or one hundred, and it will scale with you.</p>
            </div>
            <div className={styles.feature}>
              <h3>Great for animation</h3>
              <p>Smooth animations that feel natural and responsive are built-in to this library.</p>
            </div>
            <div className={styles.feature}>
              <h3>Light as feathers</h3>
              <p>Seam has a small footprint with excellent performance, even when compared to other state managers.</p>
            </div>
          </section>

          <section className={styles.ctaSection}>
            <h3>It's time to make games better</h3>
            <p>It's open-source and free, so give it a spin and see what you think. You can always get support here: https://discord.gg/k5MaZEU8sm</p>
          </section>

          <div className={styles.buttons}>
            <a href="/docs/getting-started" className={styles.button}>API</a>
            <a href="/blog" className={styles.buttonSecondary}>Blog</a>
          </div>
        </div>
      </main>
    </Layout>
  );
}

export default Home;
