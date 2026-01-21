# CSetFileParser - Парсер SET-файлов MetaTrader 5

## Описание

Класс для чтения и парсинга SET-файлов MetaTrader 5, которые содержат параметры индикаторов и экспертов. Поддерживает конвертацию параметров в массив `MqlParam` для использования с функцией `iCustom()`.

## Формат SET-файлов

SET-файлы MetaTrader 5 имеют следующий формат:

```
; Комментарий (строки начинающиеся с точки с запятой)
ParameterName=Value||Start||Step||Stop||Optimize
```

### Поля параметра:

- **ParameterName** - имя параметра
- **Value** - текущее значение параметра
- **Start** - начальное значение для оптимизации (опционально)
- **Step** - шаг оптимизации (опционально)
- **Stop** - конечное значение для оптимизации (опционально)
- **Optimize** - флаг оптимизации: Y/N или 1/0 (опционально)

### Примеры:

```
; Полный формат с параметрами оптимизации
MAPeriod=14||10||2||50||Y

; Только значение, без оптимизации
MAShift=0

; С параметрами оптимизации, но оптимизация выключена
AppliedPrice=1||0||1||6||N
```

## Использование

### 1. Базовое использование

```mql5
#include <DKStdLib/Common/CSetFileParser.mqh>

// Создаем парсер
CSetFileParser parser;

// Загружаем SET-файл
if(parser.LoadFromFile("MyIndicator.set")) {
    // Конвертируем в MqlParam
    MqlParam params[];
    if(parser.ConvertToMqlParams(params)) {
        // Создаем индикатор с параметрами из SET-файла
        int handle = iCustom(_Symbol, _Period, "MyIndicator", params);
    }
}
```

### 2. Использование в торговом боте

```mql5
class CUniversalBot {
private:
    CSetFileParser m_set_parser;
    int m_indicator_handle;
    
public:
    bool InitIndicator(string indicator_name, string set_file) {
        // Загружаем параметры из SET-файла
        if(!m_set_parser.LoadFromFile(set_file)) {
            Print("Ошибка загрузки SET-файла");
            return false;
        }
        
        // Конвертируем в MqlParam
        MqlParam params[];
        if(!m_set_parser.ConvertToMqlParams(params)) {
            Print("Ошибка конвертации параметров");
            return false;
        }
        
        // Создаем индикатор
        m_indicator_handle = iCustom(_Symbol, _Period, indicator_name, params);
        
        return (m_indicator_handle != INVALID_HANDLE);
    }
};
```

### 3. Получение информации о параметрах

```mql5
CSetFileParser parser;
parser.LoadFromFile("settings.set");

// Количество параметров
int count = parser.GetParamsCount();

// Перебор всех параметров
for(int i = 0; i < count; i++) {
    string name = parser.GetParamName(i);
    string value = parser.GetParamValue(i);
    string type = parser.GetParamType(i);
    
    Print(name, " = ", value, " (", type, ")");
    
    // Проверка параметров оптимизации
    if(parser.IsOptimizationEnabled(i)) {
        string start, step, stop;
        parser.GetOptimizationParams(i, start, step, stop);
        Print("  Оптимизация: ", start, " -> ", stop, " шаг ", step);
    }
}

// Вывод всех параметров в лог
parser.PrintAll();
```

## Методы класса

### Основные методы

- `bool LoadFromFile(string filename)` - загрузить и распарсить SET-файл
- `bool ConvertToMqlParams(MqlParam &params[])` - конвертировать в массив MqlParam
- `int GetParamsCount()` - получить количество параметров
- `void PrintAll()` - вывести все параметры в лог

### Методы доступа к параметрам

- `string GetParamName(int index)` - получить имя параметра
- `string GetParamValue(int index)` - получить значение параметра
- `string GetParamType(int index)` - получить тип параметра (int/double/string/bool)
- `bool IsOptimizationEnabled(int index)` - проверить, включена ли оптимизация
- `bool GetOptimizationParams(int index, string &start, string &step, string &stop)` - получить параметры оптимизации

## Поиск SET-файлов

Класс автоматически ищет SET-файлы в следующих папках:

1. Полный путь (если указан)
2. `MQL5/Files/`
3. `MQL5/Presets/`
4. `Tester/`

## Определение типов

Класс автоматически определяет типы параметров:

- **int** - целые числа (например: 14, -5, 100)
- **double** - числа с точкой (например: 1.5, 0.01, -3.14)
- **bool** - true/false
- **string** - всё остальное

## Примеры SET-файлов

### Пример 1: Moving Average

Файл: `CustomMA_Example.set`
```
; Custom Moving Average Parameters
MAPeriod=14||10||2||50||Y
MAShift=0||0||1||5||N
MAMethod=0||0||1||3||Y
AppliedPrice=1||0||1||6||N
```

### Пример 2: Donchian Channel

Файл: `DonchianChannel_Example.set`
```
; Donchian Channel Parameters
Period=20||10||5||50||Y
Shift=0||0||1||3||N
ChannelMode=0
```

### Пример 3: Pivot Points

Файл: `PivotPoints_Example.set`
```
; Pivot Points Parameters
PivotType=0||0||1||2||Y
Timeframe=16408
ShowHistory=true
```

## Тестирование

Для тестирования парсера запустите скрипт:

```bash
test/TestCSetFileParser.mq5
```

Скрипт:
1. Загрузит SET-файл
2. Распарсит параметры
3. Конвертирует в MqlParam
4. Создаст тестовый индикатор
5. Выведет результаты в лог

## Создание SET-файлов

### Способ 1: Через MetaEditor/MetaTrader

1. Откройте любой эксперт/индикатор
2. Настройте параметры в диалоге
3. Нажмите кнопку "Сохранить"
4. Файл сохранится в `MQL5/Presets/`

### Способ 2: Вручную

Создайте текстовый файл с расширением `.set` в папке `MQL5/Files/` или `MQL5/Presets/`

## Особенности

- ✅ Автоматическое определение типов параметров
- ✅ Поддержка параметров оптимизации
- ✅ Пропуск комментариев (`;`)
- ✅ Поддержка bool значений (true/false)
- ✅ Поиск файлов в нескольких папках
- ✅ Подробное логирование процесса загрузки

## Интеграция с UniBreakout Bot

В вашем боте можно использовать так:

```mql5
// В параметрах бота
input string InpIndicatorName = "MyIndicator";
input string InpIndicatorSetFile = "MyIndicator.set";
input int    InpIndicatorBuffer = 0;

// В классе бота
CSetFileParser m_parser;

bool OnInit() {
    MqlParam params[];
    
    // Загружаем параметры из SET-файла
    if(m_parser.LoadFromFile(InpIndicatorSetFile)) {
        m_parser.ConvertToMqlParams(params);
    }
    
    // Создаем индикатор
    int handle = iCustom(_Symbol, _Period, InpIndicatorName, params);
    
    return (handle != INVALID_HANDLE);
}
```

## Лицензия

Copyright 2026, Denis K.
