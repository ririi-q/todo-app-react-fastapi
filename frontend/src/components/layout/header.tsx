import { Link } from 'react-router-dom'
import { Button } from "@/components/ui/button"

const Header = () => {
  return (
    <header className="border-b">
      <div className="container mx-auto px-4 py-3">
        <nav className="flex items-center justify-between">
          <div className="flex items-center gap-6">
            <Link to="/" className="text-xl font-bold">
              ToDo Manager
            </Link>
            <div className="flex gap-4">
              <Link to="/">
                <Button variant="ghost">ホーム</Button>
              </Link>
              <Link to="/tasks">
                <Button variant="ghost">タスク一覧</Button>
              </Link>
            </div>
          </div>
          <div className="flex items-center gap-4">
            <Button variant="outline">ログイン</Button>
          </div>
        </nav>
      </div>
    </header>
  )
}

export default Header 