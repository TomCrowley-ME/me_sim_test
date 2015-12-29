/*
** Binary semaphore Producer/Consumer test
*/
#include <stdio.h>
#include "common_types.h"
#include "osapi.h"

/* Task 1 */
#define TASK_1_ID         1
#define TASK_1_STACK_SIZE 1024
#define TASK_1_PRIORITY   101

#define TIMER_ENTRY 0x001
#define TIMER_EXIT  0x002
#define TASK_ENTRY  0x003
#define TASK_EXIT   0x004

uint32 task_1_stack[TASK_1_STACK_SIZE];
uint32 task_1_id;

void task_1(void)
{
    uint32  status;
    uint32  events;

    OS_printf("Starting task 1\n");

    OS_TaskRegister();

    while(1)
    {

        OS_printf("TASK 1: waiting on any events 0x00000005\n");
        status = OS_EventReceive(0x00000005, OS_EVENT_ANY, OS_PEND, &events);
        if ( status != OS_SUCCESS )
        {
           OS_printf("TASK 1:Error calling OS_EventReceive\n");
           exit(-1);
        }
        OS_printf("TASK 1: got events 0x%08X\n", events);

        OS_printf("TASK 1: waiting on any events 0x00000005\n");
        status = OS_EventReceive(0x00000005, OS_EVENT_ANY, OS_PEND, &events);
        if ( status != OS_SUCCESS )
        {
           OS_printf("TASK 1:Error calling OS_EventReceive\n");
           exit(-1);
        }
        OS_printf("TASK 1: got events 0x%08X\n", events);

        OS_printf("TASK 1: waiting on all events 0x00000018\n");
        status = OS_EventReceive(0x00000018, OS_EVENT_ALL, OS_PEND, &events);
        if ( status != OS_SUCCESS )
        {
           OS_printf("TASK 1:Error calling OS_EventReceive\n");
           exit(-1);
        }
        OS_printf("TASK 1: got events 0x%08X\n", events);

        OS_printf("TASK 1: checking for event 0x00000020\n");
        status = OS_EventReceive(0x00000020, OS_EVENT_ANY, OS_CHECK, &events);
        if ( status != OS_SUCCESS )
        {
           OS_printf("TASK 1:Error calling OS_EventReceive\n");
           exit(-1);
        }
        OS_printf("TASK 1: got events 0x%08X\n", events);
    }
}

void OS_Application_Startup(void)
{
   uint32             status;

   OS_API_Init();

   OS_printf("OS Application Startup\n");

   /*
   ** Create the event receiving task.
   */
   status = OS_TaskCreate( &task_1_id, "Task 1", task_1, task_1_stack, TASK_1_STACK_SIZE, TASK_1_PRIORITY, 0);
   if ( status != OS_SUCCESS )
   {
      OS_printf("Error creating Task 1\n");
   }
   else
   {
      OS_printf("Created Task 1\n");
   }

   for (;;)
   {
       OS_printf("MAIN: sending event 0x00000001\n");
       OS_EventSend(task_1_id, 0x00000001);

       OS_TaskDelay(2000);

       OS_printf("MAIN: sending event 0x00000004\n");
       OS_EventSend(task_1_id, 0x00000004);

       OS_TaskDelay(2000);

       OS_printf("MAIN: sending event 0x00000008\n");
       OS_EventSend(task_1_id, 0x00000008);

       OS_TaskDelay(2000);

       OS_printf("MAIN: sending event 0x00000020\n");
       OS_EventSend(task_1_id, 0x00000020);

       OS_TaskDelay(2000);

       OS_printf("MAIN: sending event 0x00000010\n");
       OS_EventSend(task_1_id, 0x00000010);

       OS_TaskDelay(2000);
   }
}
