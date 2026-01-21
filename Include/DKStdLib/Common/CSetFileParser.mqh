//+------------------------------------------------------------------+
//|                                               CSetFileParser.mqh |
//|                                        Copyright 2026, Denis K.  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Denis K."
#property link      ""
#property version   "1.00"

//+------------------------------------------------------------------+
//| Класс для парсинга SET-файлов MetaTrader 5                       |
//| Формат: ParamName=Value||Start||Step||Stop||Optimize             |
//+------------------------------------------------------------------+
class CSetFileParser {
private:
    //+------------------------------------------------------------------+
    //| Структура для хранения параметра из SET-файла                    |
    //+------------------------------------------------------------------+
    struct SSetParam {
        string name;              // Имя параметра
        string value;             // Текущее значение
        string type;              // Тип: int, double, string, bool
        
        // Параметры оптимизации
        string opt_start;         // Начальное значение
        string opt_step;          // Шаг
        string opt_stop;          // Конечное значение
        bool   opt_enabled;       // Включена ли оптимизация (Y/N)
    };
    
    SSetParam m_params[];         // Массив параметров
    
    //+------------------------------------------------------------------+
    //| Определение типа значения по содержимому                         |
    //+------------------------------------------------------------------+
    string DetectValueType(string value) {
        // Проверяем на boolean
        string v_lower = value;
        StringToLower(v_lower);
        if(v_lower == "true" || v_lower == "false") 
            return "bool";
        
        // Проверяем на число с точкой
        if(StringFind(value, ".") >= 0) 
            return "double";
        
        // Проверяем на целое число (может быть отрицательным)
        bool is_digit = true;
        int start = 0;
        if(StringLen(value) > 0 && StringSubstr(value, 0, 1) == "-")
            start = 1;
            
        for(int i = start; i < StringLen(value); i++) {
            ushort ch = StringGetCharacter(value, i);
            if(ch < '0' || ch > '9') {
                is_digit = false;
                break;
            }
        }
        
        if(is_digit && StringLen(value) > start) 
            return "int";
        
        // Иначе строка
        return "string";
    }
    
    //+------------------------------------------------------------------+
    //| Очистка строки от пробелов                                       |
    //+------------------------------------------------------------------+
    void TrimString(string &str) {
        StringTrimLeft(str);
        StringTrimRight(str);
    }
    
public:
    //+------------------------------------------------------------------+
    //| Конструктор                                                      |
    //+------------------------------------------------------------------+
    CSetFileParser() {
        ArrayFree(m_params);
    }
    
    //+------------------------------------------------------------------+
    //| Деструктор                                                       |
    //+------------------------------------------------------------------+
    ~CSetFileParser() {
        ArrayFree(m_params);
    }
    
    //+------------------------------------------------------------------+
    //| Загрузка и парсинг SET-файла                                     |
    //+------------------------------------------------------------------+
    bool LoadFromFile(string filename) {
        ArrayFree(m_params);
        
        // Ищем файл в разных папках
        string paths[] = {
            filename,                           // Полный путь
            "Files\\" + filename,               // MQL5/Files/
            "..\\Presets\\" + filename,         // MQL5/Presets/
            "..\\..\\Tester\\" + filename       // Tester/
        };
        
        int file_handle = INVALID_HANDLE;
        string used_path = "";
        
        for(int i = 0; i < ArraySize(paths); i++) {
            ResetLastError();
            file_handle = FileOpen(paths[i], FILE_READ|FILE_TXT|FILE_ANSI);
            if(file_handle != INVALID_HANDLE) {
                used_path = paths[i];
                break;
            }
        }
        
        if(file_handle == INVALID_HANDLE) {
            Print("❌ CSetFileParser: Не удалось открыть SET-файл: ", filename);
            Print("   Последняя ошибка: ", GetLastError());
            Print("   Файл должен быть в: MQL5/Files/ или MQL5/Presets/");
            return false;
        }
        
        Print("✅ CSetFileParser: Загружаем SET-файл: ", used_path);
        
        int count = 0;
        int line_num = 0;
        
        while(!FileIsEnding(file_handle)) {
            string line = FileReadString(file_handle);
            line_num++;
            TrimString(line);
            
            // Пропускаем пустые строки
            if(StringLen(line) == 0)
                continue;
            
            // Пропускаем комментарии (начинаются с ";")
            if(StringSubstr(line, 0, 1) == ";")
                continue;
            
            // Ищем разделитель "="
            int separator = StringFind(line, "=");
            if(separator < 0) {
                Print("⚠️ CSetFileParser: Строка ", line_num, " не содержит '=': ", line);
                continue;
            }
            
            // Извлекаем имя параметра
            string param_name = StringSubstr(line, 0, separator);
            TrimString(param_name);
            
            if(StringLen(param_name) == 0) {
                Print("⚠️ CSetFileParser: Строка ", line_num, " имеет пустое имя параметра");
                continue;
            }
            
            // Извлекаем остальную часть строки после "="
            string param_data = StringSubstr(line, separator + 1);
            TrimString(param_data);
            
            // Разбиваем по "||" для получения полей оптимизации
            string fields[];
            int fields_count = StringSplit(param_data, StringGetCharacter("||", 0), fields);
            
            // Если StringSplit не работает с "||", делаем вручную
            if(fields_count <= 1) {
                fields_count = 0;
                int pos = 0;
                int next_pos = 0;
                
                while(true) {
                    next_pos = StringFind(param_data, "||", pos);
                    
                    if(next_pos < 0) {
                        // Последнее поле
                        string last_field = StringSubstr(param_data, pos);
                        TrimString(last_field);
                        ArrayResize(fields, fields_count + 1);
                        fields[fields_count] = last_field;
                        fields_count++;
                        break;
                    }
                    
                    string field = StringSubstr(param_data, pos, next_pos - pos);
                    TrimString(field);
                    ArrayResize(fields, fields_count + 1);
                    fields[fields_count] = field;
                    fields_count++;
                    
                    pos = next_pos + 2; // Пропускаем "||"
                }
            }
            
            // Создаем новый параметр
            ArrayResize(m_params, count + 1);
            m_params[count].name = param_name;
            
            // Значение (обязательное поле)
            if(fields_count > 0) {
                m_params[count].value = fields[0];
                TrimString(m_params[count].value);
                m_params[count].type = DetectValueType(m_params[count].value);
            }
            
            // Параметры оптимизации (опциональные)
            if(fields_count > 1) {
                m_params[count].opt_start = fields[1];
                TrimString(m_params[count].opt_start);
            }
            
            if(fields_count > 2) {
                m_params[count].opt_step = fields[2];
                TrimString(m_params[count].opt_step);
            }
            
            if(fields_count > 3) {
                m_params[count].opt_stop = fields[3];
                TrimString(m_params[count].opt_stop);
            }
            
            if(fields_count > 4) {
                string opt_flag = fields[4];
                TrimString(opt_flag);
                StringToUpper(opt_flag);
                m_params[count].opt_enabled = (opt_flag == "Y" || opt_flag == "YES" || opt_flag == "1");
            }
            else {
                m_params[count].opt_enabled = false;
            }
            
            // Вывод информации о параметре
            Print("  📋 [", count+1, "] ", param_name, " = ", m_params[count].value, 
                  " (", m_params[count].type, ")");
            if(fields_count > 1) {
                Print("      Оптимизация: ", (m_params[count].opt_enabled ? "ВКЛ" : "ВЫКЛ"),
                      " | Start=", m_params[count].opt_start,
                      " Step=", m_params[count].opt_step,
                      " Stop=", m_params[count].opt_stop);
            }
            
            count++;
        }
        
        FileClose(file_handle);
        Print("✅ CSetFileParser: Всего загружено параметров: ", count);
        return count > 0;
    }
    
    //+------------------------------------------------------------------+
    //| Конвертация в массив MqlParam для iCustom                        |
    //+------------------------------------------------------------------+
    bool ConvertToMqlParams(MqlParam &params[]) {
        int count = ArraySize(m_params);
        if(count == 0) {
            Print("❌ CSetFileParser: Нет параметров для конвертации");
            return false;
        }
        
        ArrayResize(params, count);
        
        for(int i = 0; i < count; i++) {
            if(m_params[i].type == "int") {
                params[i].type = TYPE_INT;
                params[i].integer_value = (long)StringToInteger(m_params[i].value);
            }
            else if(m_params[i].type == "double") {
                params[i].type = TYPE_DOUBLE;
                params[i].double_value = StringToDouble(m_params[i].value);
            }
            else if(m_params[i].type == "bool") {
                params[i].type = TYPE_BOOL;
                string v = m_params[i].value;
                StringToLower(v);
                params[i].integer_value = (v == "true" || v == "1") ? 1 : 0;
            }
            else { // string
                params[i].type = TYPE_STRING;
                StringToCharArray(m_params[i].value, params[i].string_value);
            }
        }
        
        Print("✅ CSetFileParser: Конвертировано параметров в MqlParam: ", count);
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Получить количество параметров                                   |
    //+------------------------------------------------------------------+
    int GetParamsCount() { 
        return ArraySize(m_params); 
    }
    
    //+------------------------------------------------------------------+
    //| Получить имя параметра по индексу                                |
    //+------------------------------------------------------------------+
    string GetParamName(int index) {
        if(index < 0 || index >= ArraySize(m_params)) 
            return "";
        return m_params[index].name;
    }
    
    //+------------------------------------------------------------------+
    //| Получить значение параметра по индексу                           |
    //+------------------------------------------------------------------+
    string GetParamValue(int index) {
        if(index < 0 || index >= ArraySize(m_params)) 
            return "";
        return m_params[index].value;
    }
    
    //+------------------------------------------------------------------+
    //| Получить тип параметра по индексу                                |
    //+------------------------------------------------------------------+
    string GetParamType(int index) {
        if(index < 0 || index >= ArraySize(m_params)) 
            return "";
        return m_params[index].type;
    }
    
    //+------------------------------------------------------------------+
    //| Проверить, включена ли оптимизация для параметра                 |
    //+------------------------------------------------------------------+
    bool IsOptimizationEnabled(int index) {
        if(index < 0 || index >= ArraySize(m_params)) 
            return false;
        return m_params[index].opt_enabled;
    }
    
    //+------------------------------------------------------------------+
    //| Получить параметры оптимизации                                   |
    //+------------------------------------------------------------------+
    bool GetOptimizationParams(int index, string &start, string &step, string &stop) {
        if(index < 0 || index >= ArraySize(m_params)) 
            return false;
            
        start = m_params[index].opt_start;
        step = m_params[index].opt_step;
        stop = m_params[index].opt_stop;
        
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Вывести все параметры в лог                                      |
    //+------------------------------------------------------------------+
    void PrintAll() {
        Print("=== SET File Parameters (", ArraySize(m_params), ") ===");
        for(int i = 0; i < ArraySize(m_params); i++) {
            Print("[", i, "] ", m_params[i].name, " = ", m_params[i].value, 
                  " (", m_params[i].type, ")");
            if(m_params[i].opt_enabled) {
                Print("    Opt: Start=", m_params[i].opt_start, 
                      " Step=", m_params[i].opt_step,
                      " Stop=", m_params[i].opt_stop);
            }
        }
    }
};
//+------------------------------------------------------------------+
