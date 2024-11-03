export type Task = {
    id: number
    title: string
    done: boolean
    created_at: string
    updated_at: string
    user_id: number
}

export type TaskCreate = {
    title: string
    done: boolean
}