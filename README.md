# UniBreakout-MT5-Bot

* Coding by Denis Kislitsyn | denis@kislitsyn.me | [kislitsyn.me](https://kislitsyn.me/personal/algo)
* Version: 1.01

## Что нового?
```
1.01: Session mode support (current day range)
1.00: First version (prev day range breakout/rebound)
```

## Описание стратегии

**UniBreakout-MT5-Bot** — универсальный торговый советник для торговли на пробой или отбой от уровней сессионного/дневного диапазона.

![Layout](img/UM001.%20Layout.png)


### Индикаторы

- Session Range (диапазон предыдущего дня или текущей сессии)
- ATR для расчета SL

### Принцип работы

Бот поддерживает два режима работы:
1. **Breakout** — торговля на пробой границ диапазона
2. **Rebound** — торговля на отбой от границ диапазона

Диапазон определяется по настройке Session Mode:
- **Previous Day** — диапазон предыдущего дня
- **Current Session** — диапазон текущей сессии (задаётся временем старта и длительностью)

1. **Вход BUY (Breakout)**:
   - Цена закрытия свечи выше верхней границы диапазона
   - Цена открытия была внутри или ниже границы

2. **Вход SELL (Breakout)**:
   - Цена закрытия свечи ниже нижней границы диапазона
   - Цена открытия была внутри или выше границы

3. **Режим Rebound**:
   - Сигналы инвертированы: пробой вверх — SELL, пробой вниз — BUY

4. **Выход**:
   - По SL/TP
   - TSL (Simple или ATR)



## Installation | Установка

Скопируйте файлы `.ex5` и папку `Include` в каталог данных терминала MT5.

## Bot's Input Parameters

#### 1. SESSION (S) — Параметры сессии

- **`S_STH`**: Session Start Hour (по умолчанию: `0`)
- **`S_STM`**: Session Start Min (по умолчанию: `0`)
- **`S_DUR`**: Session Duration min (по умолчанию: `1439`)
- **`S_MOD`**: Session Mode — `SESSION_MODE_PREV` (предыдущий день) или текущая сессия

#### 2. IN (I) — Параметры входа

- **`I_DIR_MOD`**: In Dir Mode — `SETUP_MODE_BREAKOUT` или `SETUP_MODE_REBOUND`
- **`I_SLTP_MOD`**: SL/TP Mode — `ATR`, `NEAREST`, `CENTER`, `OUTER`
- **`I_MM_MOD`**: Money Management Type (`FIXED_LOT`, `FIXED_RISK`, `PERCENT_BALANCE`, `PERCENT_EQUITY`)
- **`I_MM_VAL`**: MM Value (по умолчанию: `1.0`)
- **`I_ATR_PER`**: ATR Period (по умолчанию: `14`)
- **`I_ATR_MUL`**: ATR SL Multiplicator (по умолчанию: `2.0`)
- **`I_TP_RR`**: TP Risk/Reward (по умолчанию: `2.0`)

#### 3. OUT (O) — Параметры выхода

- **`O_TSL_MOD`**: TSL Mode — `Off`, `Simple`, `ATR`

#### 4. FILTER (F) — Фильтры

- **`F_ONE_PDD`**: Only one pos per day (по умолчанию: `true`)
- **`F_DIR_MOD`**: Trade direction — `Both`, `Buy`, `Sell`
