/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2026 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include "lcd.h"
#include <string.h> 
#include <stdio.h>
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
// Button pins (PB0..2)
#define BTN1_PIN      GPIO_PIN_0
#define BTN2_PIN      GPIO_PIN_1
#define BTN3_PIN      GPIO_PIN_2
#define BTN_PORT      GPIOB

// LCD control
#define RS_PIN        GPIO_PIN_0
#define RS_PORT       GPIOA
#define ENB_PIN       GPIO_PIN_1
#define ENB_PORT      GPIOA
#define LCD_PORTS     {GPIOA, GPIOA, GPIOA, GPIOA}
#define LCD_PINS      {GPIO_PIN_2, GPIO_PIN_3, GPIO_PIN_4, GPIO_PIN_5}
/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

/* USER CODE BEGIN PV */
Lcd_HandleTypeDef lcd;

volatile uint8_t btn1_flag = 0;
volatile uint8_t btn2_flag = 0;
volatile uint8_t btn3_flag = 0;

volatile uint8_t button_event_occurred = 0;

volatile uint8_t was_multi = 0;



/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);

/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */
void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
    static uint32_t last_time[3] = {0};   // debounce timers for PB0..PB2
    uint32_t now = HAL_GetTick();
    GPIO_PinState state;

    switch (GPIO_Pin)
    {
        case BTN1_PIN:
            if (now - last_time[0] > 50)   // 50 ms debounce
            {
                last_time[0] = now;
                state = HAL_GPIO_ReadPin(BTN_PORT, BTN1_PIN);
                if (state == GPIO_PIN_RESET)       // active low → pressed
                {
                    if (btn1_flag == 0)
                    {
                        btn1_flag = 1;
                        button_event_occurred = 1;
                    }
                }
                else                                 // released
                {
                    if (btn1_flag == 1)
                    {
                        btn1_flag = 0;
                        button_event_occurred = 1;
                    }
                }
            }
            break;

        case BTN2_PIN:
            if (now - last_time[1] > 50)
            {
                last_time[1] = now;
                state = HAL_GPIO_ReadPin(BTN_PORT, BTN2_PIN);
                if (state == GPIO_PIN_RESET)
                {
                    if (btn2_flag == 0)
                    {
                        btn2_flag = 1;
                        button_event_occurred = 1;
                    }
                }
                else
                {
                    if (btn2_flag == 1)
                    {
                        btn2_flag = 0;
                        button_event_occurred = 1;
                    }
                }
            }
            break;

        case BTN3_PIN:
            if (now - last_time[2] > 50)
            {
                last_time[2] = now;
                state = HAL_GPIO_ReadPin(BTN_PORT, BTN3_PIN);
                if (state == GPIO_PIN_RESET)
                {
                    if (btn3_flag == 0)
                    {
                        btn3_flag = 1;
                        button_event_occurred = 1;
                    }
                }
                else
                {
                    if (btn3_flag == 1)
                    {
                        btn3_flag = 0;
                        button_event_occurred = 1;
                    }
                }
            }
            break;

        default:
            break;
    }
}
/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{

  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
	GPIOB->ODR |= (BTN1_PIN | BTN2_PIN | BTN3_PIN);

  /* USER CODE BEGIN 2 */
	
	Lcd_PortType ports[] = LCD_PORTS;
    Lcd_PinType pins[]   = LCD_PINS;
    lcd = Lcd_create(ports, pins, RS_PORT, RS_PIN, ENB_PORT, ENB_PIN, LCD_4_BIT_MODE);
    Lcd_clear(&lcd);
		
	Lcd_cursor(&lcd, 0, 0);
    Lcd_string(&lcd, "Ready           ");
    Lcd_cursor(&lcd, 1, 0);
    Lcd_string(&lcd, "                ");
		
	uint8_t prev_count = 0;
    uint8_t prev_btn1 = 0, prev_btn2 = 0, prev_btn3 = 0;
		
		
		

		
  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
		
		
		if (button_event_occurred ||
            btn1_flag != prev_btn1 ||
            btn2_flag != prev_btn2 ||
            btn3_flag != prev_btn3)
        {
            button_event_occurred = 0;   

            uint8_t cnt = btn1_flag + btn2_flag + btn3_flag;

            uint8_t single_sensor = 0;
            if (cnt == 1)
            {
                if (btn1_flag) single_sensor = 1;
                else if (btn2_flag) single_sensor = 2;
                else single_sensor = 3;
            }

            if (cnt >= 2)
                was_multi = 1;
            else if (cnt == 0)
                was_multi = 0;

            char lcd_line1[17] = "";
            char lcd_line2[17] = "";

            if (cnt >= 2)
            {
                strcpy(lcd_line1, "Multiple Interf");
                strcpy(lcd_line2, "erence         ");
            }
            else if (cnt == 0)
            {
                strcpy(lcd_line1, "Ready           ");
                strcpy(lcd_line2, "                ");
            }
            else   
            {
                if (was_multi)
                {
                    strcpy(lcd_line1, "Ready           ");
                    strcpy(lcd_line2, "                ");
                }
                else
                {
                    sprintf(lcd_line1, "Sensor %d       ", single_sensor);
                    strcpy(lcd_line2, "                ");
                }
            }

            Lcd_clear(&lcd);
            Lcd_cursor(&lcd, 0, 0);
            Lcd_string(&lcd, lcd_line1);
            Lcd_cursor(&lcd, 1, 0);
            Lcd_string(&lcd, lcd_line2);

            prev_count = cnt;
            prev_btn1 = btn1_flag;
            prev_btn2 = btn2_flag;
            prev_btn3 = btn3_flag;
        }

        HAL_Delay(10);   
		
		
	}
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_NONE;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_HSI;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV1;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_0) != HAL_OK)
  {
    Error_Handler();
  }
}

/**
  * @brief GPIO Initialization Function
  * @param None
  * @retval None
  */
static void MX_GPIO_Init(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};
  /* USER CODE BEGIN MX_GPIO_Init_1 */

  /* USER CODE END MX_GPIO_Init_1 */

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOD_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_0|GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3
                          |GPIO_PIN_4|GPIO_PIN_5, GPIO_PIN_RESET);

  /*Configure GPIO pins : PA0 PA1 PA2 PA3
                           PA4 PA5 */
  GPIO_InitStruct.Pin = GPIO_PIN_0|GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3
                          |GPIO_PIN_4|GPIO_PIN_5;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

  /*Configure GPIO pins : PB0 PB1 PB2 */
  GPIO_InitStruct.Pin = GPIO_PIN_0|GPIO_PIN_1|GPIO_PIN_2;
  GPIO_InitStruct.Mode = GPIO_MODE_IT_RISING_FALLING;
  GPIO_InitStruct.Pull = GPIO_PULLUP;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /* EXTI interrupt init*/
  HAL_NVIC_SetPriority(EXTI0_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(EXTI0_IRQn);

  HAL_NVIC_SetPriority(EXTI1_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(EXTI1_IRQn);

  HAL_NVIC_SetPriority(EXTI2_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(EXTI2_IRQn);

  /* USER CODE BEGIN MX_GPIO_Init_2 */

  /* USER CODE END MX_GPIO_Init_2 */
}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}
#ifdef USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
