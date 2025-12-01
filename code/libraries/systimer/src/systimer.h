/**
 * @file
 * @brief The software timer library definitions.
 * @internal
 *
 * @copyright (C) 2019-2021 Melexis N.V.
 *
 * Melexis N.V. is supplying this code for use with Melexis N.V. processor based microcontrollers only.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED OR STATUTORY,
 * INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.  MELEXIS N.V. SHALL NOT IN ANY CIRCUMSTANCES,
 * BE LIABLE FOR SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
 *
 * @endinternal
 *
 * @ingroup libraries
 *
 * @brief
 * @details
 * @{
 */

#ifndef SYSTIMER_H
#define SYSTIMER_H

#define CTIMER0_1MS 2000u

void ctimer0_init(uint16_t period);
void ctimer0_start(void);
void ctimer0_stop(void);

#endif /* SYSTIMER_H */

/* EOF */
