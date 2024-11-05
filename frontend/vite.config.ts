import path from 'path'
import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react-swc'

export default defineConfig(() => {
  const environment = process.env.ENVIRONMENT || 'localhost'
  const env = loadEnv(environment, process.cwd(), '')
  return {
    plugins: [react()],
    resolve: {
      alias: {
        '@': path.resolve(__dirname, './src'),
      },
    },
    server: {
      port: 5173,
      host: '0.0.0.0',
      historyApiFallback: true,
    },
    optimizeDeps: {
      include: ['@radix-ui/react-checkbox'],
    },
    define: {
      'process.env': env,
    },
  }
})
