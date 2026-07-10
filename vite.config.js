import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    vue({
      // Tanpa ini, Vue compiler mengubah src="/images/..." pada <img>
      // menjadi import modul, padahal file tersebut ada di folder public/
      // dan harusnya diakses langsung sebagai URL statis, bukan di-import.
      template: {
        transformAssetUrls: false
      }
    })
  ],
})