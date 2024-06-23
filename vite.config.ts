import { writeFileSync } from 'node:fs'
import { dirname, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'

import { defineConfig } from 'vite'
import dts from 'vite-plugin-dts'

export default defineConfig({
  build: {
    lib: {
      entry: resolve(dirname(fileURLToPath(import.meta.url)), './src/index.ts'),
      formats: ['es', 'cjs'],
      fileName: 'index',
    },
    minify: false,
  },
  plugins: [dts({
    include: ['./src/index.ts'],
    beforeWriteFile: (filePath, content) => {
      writeFileSync(filePath.replace('.d.ts', '.d.cts'), content)
      return { filePath, content }
    },
  })],
})
