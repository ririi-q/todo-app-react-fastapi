import { ReactNode } from 'react'
import Header from './header'
import Footer from './footer'

interface LayoutProps {
  children: ReactNode
}

const Layout = ({ children }: LayoutProps) => {
  return (
    <div className="min-h-screen flex flex-col">
      <Header />
      <main className="flex-1 p-4">
        {children}
      </main>
      <Footer />
    </div>
  )
}

export default Layout 