/*
 * dcm_driver.h
 *
 *  Created on: 2025. 5. 20.
 *      Author: mctp
 */

#ifndef CODE_SRC_DCM_DRIVER_H_
#define CODE_SRC_DCM_DRIVER_H_
#include <stdint.h>
#include "defines.h"
#include "app_sensor.h"

typedef struct
{
    uint16_t none_check_cnt;
    uint16_t last_pulse_cnt;
    uint16_t one_period_cnt;
    uint16_t timeout_state;
} gmr_sensor_t;

#define STALL_MASK_TEMPORARY 0x01u
#define STALL_MASK_PERMENT 0x02u

#define FAULT_MASK_PHASE_A_OPEN 0x01u
// #define FAULT_MASK_PHASE_B_OPEN             0x02u
#define FAULT_MASK_PHASE_A_SHORT 0x10u
// #define FAULT_MASK_PHASE_B_SHORT            0x20u
#define FAULT_MASK_OVER_CURRENT 0x40u

typedef enum
{
    FAULT_NONE = 0,
    FAULT_OPEN,
    FAULT_SHORT,
    FAULT_OC,
    FAULT_STALL,
    FAULT_TIMEOUT,
    FAULT_VALVE
} tMotFault;

#define C_MOT_MAXDUTY_SET C_PWMOUT_MAX_DUTY
#define C_MOT_TESTDUTY_SET (C_PWMOUT_MAX_DUTY * 0.8)
#define C_MOT_MINDUTY_SET (C_PWMOUT_MAX_DUTY * 0.25)
#define C_MOT_STARTDUTY_SET (C_PWMOUT_MAX_DUTY * 0.1)

#define C_MOT_ON_HYSTERISYS (1.0f * C_GMR_ANGLE_SCALE_FACTOR)
#define C_MOT_OFF_HYSTERISYS (0.3f * C_GMR_ANGLE_SCALE_FACTOR)

typedef enum
{
    MOTION_INIT,
    MOTION_STOPPED,
    MOTION_ACC,
    MOTION_RUNNING,
    MOTION_DEC,
    MOTION_PAUSE,
    MOTION_STALL,
    MOTION_FAULT
} tMotState;

#define OPEN_DETECT_CURRENT 20u //20mA
#define OPEN_DETECT_TIMEOUT 500u

#define OVER_CURRNET_DETECT_CURRENT 1500u //1.5A
#define OVER_CURRNET_DETECT_TIMEOUT 300u
#define STALL_DETECT_TIMEOUT        100u

/* local variables */
struct
{
    tMotState state;
    tMotState lastState;
    uint16_t initStatus;
    uint16_t elapsedTime;
    uint16_t requestStop;    /* 0: No request, 1: Request stop */
    int16_t speed;           /* current speed [PPS] */
    tMotDirection direction; /* 1 : forward, -1 : backward */
    tMotDirection lastDirection;
    uint16_t runTimeOut; /*  */
    uint16_t holdTime;
    struct
    {
        int16_t current;
        int16_t target;
        int16_t lastTarget;
        int16_t Delta;
        uint8_t newTarget;
        uint8_t posReached;
    } pos;

    struct
    {
        uint16_t enable;
        uint16_t outThreshold; /*  */
        uint16_t accDuty;      /* acceleration duty */
    } softStart;
    struct
    {
        uint8_t enable;
        uint8_t completed;
        uint16_t inThreshold; /*  */
        uint16_t dccDuty;     /* dcceleration duty */
    } softStop;

    struct
    {
        uint16_t enable;  /*  */
        uint16_t duty;    /* */
        uint16_t maxDuty; /* */
        uint16_t minDuty; /* */
    } out;

    struct
    {
        int16_t rawCurrent;      /* motor current [mA] */
        int16_t filteredCurrent; /* filtered motor current through LPF [mA] */
    } meas;

    struct
    {
        uint8_t flag;
        uint8_t enable;
        uint16_t maskTimer;
        uint16_t stallCnt; /* stall counter */
        uint16_t halfThd;
        uint16_t threshold; /* stall threshold [mA] */
        uint16_t obstrCnt;
    } stall;

    struct
    {
        uint8_t flag; /* fault flag */
        uint8_t ocEnable;
        uint8_t openEnable;

        uint8_t shortEnable;

        uint8_t ocDetectCheck;
        uint16_t ocDetectCnt;

        uint8_t openDetectCheck;
        uint16_t openDetectCnt;
    } fault;

} motor;

struct
{
    tSensorCondition moving;
    uint8_t delay;
    int8_t filterPeriod;
    int8_t filterCnt;
    int16_t delta;
    int16_t thd;
    int16_t lastDeg;
} sensor;

void MotRequestHardStop(void);
void MotClearHardStop(void);
void MotSetTargetPosition(int16_t targetPos);
void MotSetCurrentPosition(int16_t currentPos);
int16_t MotGetTargetPosition(void);
int16_t MotGetCurrentPosition(void);
void MotSetParam(int16_t sensorThd, int16_t stallThd);
void MotSetSoftStartAcc(uint16_t acc);
void MotSetMaxDuty(uint16_t duty);
tMotState MotGetState(void);
uint8_t MotGetStallState(void);
uint8_t MotGetFaultState(void);
uint8_t SensorGetState(void);
int16_t SensorGetDelta(void);
void MotClearStallFlag(uint16_t type);
void MotClearFaultFlag(uint16_t type);
void app_mot_init(void);
void app_motor_task(void);
void motor_ctrl_handler(void);
void setFaultDetect(uint8_t tFault, uint8_t tDetectCheck, uint8_t tDetectCnt);

#endif /* CODE_SRC_DCM_DRIVER_H_ */
