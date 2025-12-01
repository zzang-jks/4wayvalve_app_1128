#include <atomic.h>
#include <ctimerlib.h>
#include "defines.h"

/** Timer1 INT3 handler for LIN AA frame timeout */
INTERRUPT void _CTIMER0_3_INT(void)
{
	system_timer_ISR();
}

void ctimer0_init(uint16_t period)
{
	CTimer0_AutoloadInit(eTimerCPUClockDivisionBy16, period);
	ENTER_SECTION(ATOMIC_SYSTEM_MODE);
	CTimer0_Int3_Enable();
	EXIT_SECTION();
}

void ctimer0_start(void)
{
	CTimer0_Start();
}

void ctimer0_stop(void)
{
    CTimer0_Stop();
}
