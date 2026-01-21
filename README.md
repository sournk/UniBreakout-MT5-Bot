# MACDMom-MT5-Bot

* Coding by Denis Kislitsyn | denis@kislitsyn.me | [kislitsyn.me](https://kislitsyn.me/personal/algo)
* Strategy from [ForexSystemRU](https://forexsystemru.com)
* Version: 1.00

## Что нового?
```
1.00: First version
```

## Описание стратегии

**MACDMom-MT5-Bot** — торговый советник на основе MACD, скользящей средней по MACD и индикатора Momentum.


### Индикаторы

- MACD с параметрами 5, 14, 1
- MA для MACD с периодом 14
- Momentum с периодом 96
- ATR для расчета SL

### Принцип работы

В ветке форума оригинальной стратегии описаны два разных варианта:
1. **Оригинальный**: Импульс Momentum должен быть предварительно подтвержден пересечением шкалы MACD средней по нему. 
2. **Упрощенный**. Иллюстрации к описанию оригинального варианта не совпадают с текстом. На картинках достаточно подтверждения, когда MACD просто пересекает нулевую линию.

!!! info
      Бот работает по полной оригинальной стратегии с использованием средней по MACD.

1. **Вход BUY**:
   - Гистограмма MACD пересекает MA снизу вверх
   - Momentum подтверждает восходящий импульс - имеет форму V на 3-х предыдущих свечах

2. **Вход SELL**:
   - Гистограмма MACD пересекает MA сверху вниз
   - Momentum подтверждает нисходящий импульс - имеет форму /\ на 3-х предыдущих свечах

3. **Выход**:
   - По SL/TP (SL по ATR)
   - Breakeven после достижения заданного RR

![Layout](img/UM001.%20Layout.png)   

## Installation | Установка

См. [README_INSTALL.md](README_INSTALL.md)

## Bot's Input Parameters

#### 1. INDICATOR (I) — Параметры индикаторов

- **`I_MACD_FEMA`**: MACD Fast EMA (по умолчанию: `5`)
- **`I_MACD_SEMA`**: MACD Slow EMA (по умолчанию: `14`)
- **`I_MACD_SMA`**: MACD SEMA (по умолчанию: `1`)
- **`I_MAM_PER`**: Период MA для MACD (по умолчанию: `14`)
- **`I_MAM_SHT`**: Сдвиг MA для MACD (по умолчанию: `0`)
- **`I_MOM_PER`**: Период Momentum (по умолчанию: `96`)
- **`I_ATR_PER`**: Период ATR для расчета SL (по умолчанию: `14`)

#### 2. SIGNAL (S) — Параметры сигнала

- **`S_MACD_DPT`**: Глубина поиска сигнала MACD (по умолчанию: `5`)

#### 3. TRADE (T) — Параметры торговли

- **`T_MM_MOD`**: Money Management Type (`FIXED_LOT`, `FIXED_RISK`, `PERCENT_BALANCE`, `PERCENT_EQUITY`)
- **`T_MM_VAL`**: MM Value (по умолчанию: `1.0`)
- **`T_SL_ATR_MUL`**: SL ATR Multiplicator (по умолчанию: `2.0`)
- **`T_TP_RR`**: TP Risk/Reward (по умолчанию: `2.0`)
- **`T_BE_RR`**: BE Risk/Reward, 0-off (по умолчанию: `1.0`)
