import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'

import TasksPage from '@/pages/TasksPage'
import HomePage from '@/pages/HomePage'
import Layout from '@/components/layout/layout'
import './App.css'

function App() {
  return (
    <Router>
      <Layout>
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/tasks" element={<TasksPage />} />
        </Routes>
      </Layout>
    </Router>
  )
}

export default App
