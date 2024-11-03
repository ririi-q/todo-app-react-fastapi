import { TaskCreate, Task } from '../types/task'

const API_URL = 'http://localhost:8000'

export const api = {
  async getTasks(userId: number) {
    const response = await fetch(`${API_URL}/api/v1/users/${userId}/tasks`)
    if (!response.ok) throw new Error('Failed to fetch tasks')
    const data = await response.json()
    console.log(data)
    return data
  },

  async createTask(userId: number, task: TaskCreate) {
    const response = await fetch(`${API_URL}/api/v1/users/${userId}/tasks`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(task),
    })
    if (!response.ok) throw new Error('Failed to create task')
    const data = await response.json()
    console.log(data)
    return data
  },

  async updateTask(userId: number, task: Task) {
    const response = await fetch(`${API_URL}/api/v1/users/${userId}/tasks/${task.id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(task),
    })
    if (!response.ok) throw new Error('Failed to update task')
    const data = await response.json()
    console.log(data)
    return data
  },

  async deleteTask(userId: number, taskId: number) {
    const response = await fetch(`${API_URL}/api/v1/users/${userId}/tasks/${taskId}`, {
      method: 'DELETE',
    })
    if (!response.ok) throw new Error('Failed to delete task')
    const data = await response.json()
    console.log(data)
    return data
  }
} 

