import { useState, useEffect } from 'react'
import { TasksTable } from '@/components/tasks/table'
import { NewTaskForm } from '@/components/tasks/new-task-form'
import { Task, TaskCreate } from '@/types/task'
import { api } from '@/lib/api'
import { TaskFilterArea } from '@/components/tasks/task-filter-area'

export default function TasksPage() {
  const [tasks, setTasks] = useState<Task[]>([])
  const [loading, setLoading] = useState(true)
  const [globalFilter, setGlobalFilter] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')

  useEffect(() => {
    const fetchTasks = async () => {
      try {
        const data = await api.getTasks(1) // 現状は固定のユーザーID: 1を使用
        setTasks(data)
      } catch (error) {
        console.error('タスクの取得に失敗しました:', error)
      } finally {
        setLoading(false)
      }
    }

    fetchTasks()
  }, [])

  const addTask = async (task: TaskCreate) => {
    try {
      const newTask = await api.createTask(1, task) // 現状は固定のユーザーID: 1を使用
      setTasks([...tasks, newTask])
    } catch (error) {
      console.error('タスクの追加に失敗しました:', error)
    }
  }

  const updateTask = async (task: Task) => {
    try {
      const updatedTask = await api.updateTask(1, task) // 現状は固定のユーザーID: 1を使用
      setTasks(tasks.map((t) => (t.id === task.id ? updatedTask : t)))
    } catch (error) {
      console.error('タスクの更新に失敗しました:', error)
    }
  }

  const deleteTask = async (task: Task) => {
    try {
      await api.deleteTask(1, task.id) // 現状は固定のユーザーID: 1を使用
      setTasks(tasks.filter((t) => t.id !== task.id))
    } catch (error) {
      console.error('タスクの削除に失敗しました:', error)
    }
  }

  if (loading) return <div>読み込み中...</div>

  return (
    <div className="container mx-auto py-15 grid gap-4">
      <div className="flex justify-between items-center">
        <TaskFilterArea
          globalFilter={globalFilter}
          setGlobalFilter={setGlobalFilter}
          statusFilter={statusFilter}
          setStatusFilter={setStatusFilter}
        />
        <NewTaskForm addTask={addTask} />
      </div>
      <TasksTable
        tasks={tasks}
        addTask={addTask}
        updateTask={updateTask}
        deleteTask={deleteTask}
        globalFilter={globalFilter}
        statusFilter={statusFilter as 'all' | 'done' | 'undone'}
      />
    </div>
  )
}
