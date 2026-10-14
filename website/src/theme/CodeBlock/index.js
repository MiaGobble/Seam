import React from 'react';
import OriginalCodeBlock from '@theme-original/CodeBlock';

export default function CodeBlock(props) {
  // Use the original CodeBlock behavior. Luau grammar should be registered at build time.
  return <OriginalCodeBlock {...props} />;
}
