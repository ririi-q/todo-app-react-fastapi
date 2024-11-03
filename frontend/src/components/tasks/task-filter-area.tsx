import { Input } from "@/components/ui/input"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"

interface TaskFilterAreaProps {
  globalFilter: string
  setGlobalFilter: (value: string) => void
  statusFilter: string
  setStatusFilter: (value: string) => void
}

export const TaskFilterArea = ({ 
  globalFilter, 
  setGlobalFilter,
  statusFilter,
  setStatusFilter
}: TaskFilterAreaProps) => {
  return (
    <div className="flex items-center gap-4">
      <Input
        placeholder="タスクを検索..."
        value={globalFilter ?? ""}
        onChange={(event) => setGlobalFilter(event.target.value)}
        className="w-[300px]"
      />
      <Select value={statusFilter} onValueChange={setStatusFilter}>
        <SelectTrigger className="w-[180px]">
          <SelectValue placeholder="ステータス" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="all">すべて</SelectItem>
          <SelectItem value="done">完了</SelectItem>
          <SelectItem value="undone">未完了</SelectItem>
        </SelectContent>
      </Select>
    </div>
  )
}