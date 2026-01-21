//+------------------------------------------------------------------+
//|                                      TestCSetFileParser.mq5      |
//|                                        Copyright 2026, Denis K.  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Denis K."
#property version   "1.00"
#property script_show_inputs

#include <DKStdLib/Common/CSetFileParser.mqh>

input string InpSetFileName = "CustomMA_Example.set"; // SET файл для теста

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
    Print("\n========================================");
    Print("🧪 Тест парсера SET-файлов");
    Print("========================================\n");
    
    CSetFileParser parser;
    
    // Загружаем SET-файл
    if(!parser.LoadFromFile(InpSetFileName)) {
        Print("❌ Ошибка загрузки SET-файла");
        return;
    }
    
    Print("\n--- Информация о параметрах ---");
    parser.PrintAll();
    
    // Конвертируем в MqlParam
    MqlParam params[];
    if(!parser.ConvertToMqlParams(params)) {
        Print("❌ Ошибка конвертации в MqlParam");
        return;
    }
    
    Print("\n--- MqlParam массив ---");
    for(int i = 0; i < ArraySize(params); i++) {
        string type_str = "";
        switch(params[i].type) {
            case TYPE_INT:    type_str = "INT"; break;
            case TYPE_DOUBLE: type_str = "DOUBLE"; break;
            case TYPE_STRING: type_str = "STRING"; break;
            case TYPE_BOOL:   type_str = "BOOL"; break;
            default:          type_str = "UNKNOWN"; break;
        }
        
        Print("[", i, "] Type: ", type_str);
        
        if(params[i].type == TYPE_INT || params[i].type == TYPE_BOOL) {
            Print("    Value (int): ", params[i].integer_value);
        }
        else if(params[i].type == TYPE_DOUBLE) {
            Print("    Value (double): ", params[i].double_value);
        }
        else if(params[i].type == TYPE_STRING) {
            string str_value;
            StringInit(str_value, ArraySize(params[i].string_value), 0);
            for(int j = 0; j < ArraySize(params[i].string_value); j++) {
                str_value += (char)params[i].string_value[j];
            }
            Print("    Value (string): ", str_value);
        }
    }
    
    // Пример создания индикатора с параметрами из SET-файла
    Print("\n--- Тест создания индикатора ---");
    
    // Для примера используем стандартную MA
    // В реальности здесь будет iCustom с вашим индикатором
    int ma_handle = iMA(_Symbol, _Period, 
                        (int)params[0].integer_value,     // period
                        (int)params[1].integer_value,     // shift
                        (ENUM_MA_METHOD)params[2].integer_value,  // method
                        (ENUM_APPLIED_PRICE)params[3].integer_value); // price
    
    if(ma_handle != INVALID_HANDLE) {
        Print("✅ Индикатор успешно создан с handle: ", ma_handle);
        
        // Получаем значение
        double ma_value[];
        ArraySetAsSeries(ma_value, true);
        if(CopyBuffer(ma_handle, 0, 0, 1, ma_value) > 0) {
            Print("   Текущее значение MA: ", ma_value[0]);
        }
        
        IndicatorRelease(ma_handle);
    }
    else {
        Print("❌ Ошибка создания индикатора");
    }
    
    Print("\n========================================");
    Print("✅ Тест завершен");
    Print("========================================\n");
}
//+------------------------------------------------------------------+
