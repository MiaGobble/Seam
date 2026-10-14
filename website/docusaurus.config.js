// @ts-check
// `@type` JSDoc annotations allow editor autocompletion and type checking
// (when paired with `@ts-check`).
// There are various equivalent ways to declare your Docusaurus config.
// See: https://docusaurus.io/docs/api/docusaurus-config

import {themes as prismThemes} from 'prism-react-renderer';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Seam',
  tagline: 'The next evolution of states and animation on Roblox',
  favicon: 'img/favicon.ico',

  // Future flags, see https://docusaurus.io/docs/api/docusaurus-config#future
  future: {
    v4: true, // Improve compatibility with the upcoming Docusaurus v4
  },

  // Set the production url of your site here
  url: 'https://seaminterface.com',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'MiaGobble', // Usually your GitHub org/user name.
  projectName: 'Seam', // Usually your repo name.

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: './sidebars.js',
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            'https://github.com/MiaGobble/Seam/tree/main/website/',
        },
        blog: {
          showReadingTime: true,
          feedOptions: {
            type: ['rss', 'atom'],
            xslt: true,
          },
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            'https://github.com/MiaGobble/Seam/tree/main/website/',
          // Useful options to enforce blogging best practices
          onInlineTags: 'warn',
          onInlineAuthors: 'warn',
          onUntruncatedBlogPosts: 'warn',
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      // Replace with your project's social card
      image: 'img/seam.png',

      navbar: {
        //title: 'Seam',

        logo: {
          alt: 'Seam Logo',
          src: 'img/seam.png',
        },

        items: [
          {
            type: 'docSidebar',
            sidebarId: 'tutorialSidebar',
            position: 'left',
            label: 'API',
          },
          {to: '/blog', label: 'Blog', position: 'left'},
          {
            href: 'https://github.com/MiaGobble/Seam/',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },

      footer: {
        style: 'dark',
        links: [
          {
            title: 'Docs',
            items: [
              {
                label: 'API',
                to: '/docs/getting-started',
              },
            ],
          },
          {
            title: 'Community',
            items: [
              {
                label: 'Twitter',
                href: 'https://x.com/iGottic_Real',
              },
            ],
          },
          {
            title: 'More',
            items: [
              {
                label: 'Blog',
                to: '/blog',
              },
              {
                label: 'GitHub',
                href: 'https://github.com/MiaGobble',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Seam. Made by Mia Gobble.`,
      },

      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
        // Ensure Prism loads lua highlighting for Luau code fences (we'll alias luau -> lua in a client module)
        additionalLanguages: ['lua'],
      },
      // Load a small client module that aliases the 'luau' fence to Prism's 'lua' language
      clientModules: [require.resolve('./src/js/prism-luau-alias.js')],
      colorMode: {
        defaultMode: 'dark',
        disableSwitch: true,
        respectPrefersColorScheme: false,
      },
    }),
    // Register any build-time plugins here
    plugins: [
      // This plugin requires and registers a Luau grammar with Prism during the build
      './plugins/register-luau',
    ],
};

export default config;
