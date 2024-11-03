import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
  Sheet,
  SheetClose,
  SheetContent,
  SheetDescription,
  SheetFooter,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from '@/components/ui/sheet'
import { TaskCreate } from '@/types/task'

interface NewTaskFormProps {
  addTask: (task: TaskCreate) => Promise<void>
}

export const NewTaskForm: React.FC<NewTaskFormProps> = ({ addTask }) => {
  const [title, setTitle] = useState('')

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    await addTask({ title, done: false })
    setTitle('') // フォームをリセット
  }

  return (
    <div>
      <Sheet>
        <SheetTrigger asChild>
          <Button className="font-bold">新規タスク</Button>
        </SheetTrigger>
        <SheetContent>
          <SheetHeader>
            <SheetTitle>新規タスク</SheetTitle>
            <SheetDescription>新しいタスクを作成します。</SheetDescription>
          </SheetHeader>
          <form onSubmit={handleSubmit} className="space-y-4 mt-4">
            <div className="space-y-2">
              <Label htmlFor="title" className="text-right">
                タイトル
              </Label>
              <Input
                id="title"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                className="col-span-3"
              />
            </div>
            <SheetFooter>
              <SheetClose asChild>
                <Button type="submit" className="w-full">
                  作成
                </Button>
              </SheetClose>
            </SheetFooter>
          </form>
        </SheetContent>
      </Sheet>
    </div>
  )
}
