status[to] = string
status[cc] = string
# status has two tasks and this is updating now 
status[tasks_attributes][0][id] = 36
status[tasks_attributes][0][working_hours] = 12
status[tasks_attributes][0][task_status] = complete
status[tasks_attributes][0][task_description] = string
status[tasks_attributes][0][billing_hours] = 7
status[tasks_attributes][0][images][] = <file_1>
status[tasks_attributes][0][images][] = <file_2>

status[tasks_attributes][1][id] = 37
status[tasks_attributes][1][working_hours] = 11
status[tasks_attributes][1][task_status] = complete
status[tasks_attributes][1][task_description] = string
status[tasks_attributes][1][billing_hours] = 7
status[tasks_attributes][1][images][] = <file_3>

# above task getting updated with id  and below will create new task
status[tasks_attributes][2][working_hours] = 5
status[tasks_attributes][2][task_status] = pending
status[tasks_attributes][2][task_description] = new task description
status[tasks_attributes][2][billing_hours] = 4
status[tasks_attributes][2][images][] = <file_4>
status[tasks_attributes][2][images][] = <file_5>
