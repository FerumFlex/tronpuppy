import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tsconfigPaths from 'vite-tsconfig-paths';
import { nodePolyfills } from 'vite-plugin-node-polyfills';


export default defineConfig({
  plugins: [
    react(),
    tsconfigPaths(),
    nodePolyfills()
  ],
  publicDir: 'public',
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './vitest.setup.mjs',
  },
  worker: {
    format: 'es', // Specify format, can also be 'iife' (immediately invoked function expression)
    plugins: [
      tsconfigPaths(),
      nodePolyfills()
    ],  // Optional: Add any plugins specifically for the worker
    define: {
      'process.env.NODE_DEBUG': '""',
    }
  },
  define: {
    'process.env.NODE_DEBUG': '""',
  },
});
