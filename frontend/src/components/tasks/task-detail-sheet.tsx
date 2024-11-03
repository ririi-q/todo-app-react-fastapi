import { useState, useEffect } from 'react'
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@/components/ui/sheet'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Checkbox } from '@/components/ui/checkbox'

import { Task } from '@/types/task'
interface TaskDetailSheetProps {
  task: Task | null
  isOpen: boolean
  onOpenChange: (open: boolean) => void
  onUpdate: (task: Task) => void
}

export const TaskDetailSheet = ({
  task,
  isOpen,
  onOpenChange,
  onUpdate,
}: TaskDetailSheetProps) => {
  const [title, setTitle] = useState('')
  const [done, setDone] = useState(false)

  useEffect(() => {
    if (task) {
      setTitle(task.title)
      setDone(task.done)
    }
  }, [task])

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (task) {
      onUpdate({
        ...task,
        title,
        done,
      })
      onOpenChange(false)
    }
  }

  return (
    <Sheet open={isOpen} onOpenChange={onOpenChange}>
      <SheetContent>
        <SheetHeader>
          <SheetTitle>タスクの詳細</SheetTitle>
          <SheetDescription>タスクの情報を編集できます。</SheetDescription>
        </SheetHeader>

        <form onSubmit={handleSubmit} className="space-y-4 mt-4">
          <div className="space-y-2">
            <Label htmlFor="title">タイトル</Label>
            <Input
              id="title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
            />
          </div>

          <div className="flex items-center space-x-2">
            <Checkbox
              id="done"
              checked={done}
              onCheckedChange={(checked) => setDone(checked as boolean)}
            />
            <Label htmlFor="done">完了</Label>
          </div>

          <Button type="submit" className="w-full">
            更新
          </Button>
        </form>
      </SheetContent>
    </Sheet>
  )
}
