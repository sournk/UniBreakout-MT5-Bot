//+------------------------------------------------------------------+
//| Make color lighter
//+------------------------------------------------------------------+
int GetRValue(color clr) { return (clr >> 16) & 0xFF; }
int GetGValue(color clr) { return (clr >> 8) & 0xFF; }
int GetBValue(color clr) { return clr & 0xFF; }
color RGB(int r, int g, int b)
{
   return (color)(((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF));
}

color LightenColor(color inputColor, double lightenFactor = 0.3)
{
   int r = GetRValue(inputColor);
   int g = GetGValue(inputColor);
   int b = GetBValue(inputColor);

   r = (int)(r + (255 - r) * lightenFactor);
   g = (int)(g + (255 - g) * lightenFactor);
   b = (int)(b + (255 - b) * lightenFactor);

   return RGB(r, g, b);
}
