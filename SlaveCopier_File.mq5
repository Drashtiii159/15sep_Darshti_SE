//+------------------------------------------------------------------+
//| SlaveCopier_File.mq5                                             |
//| Slave-side trade copier (multi-trade, string-based type)         |
//+------------------------------------------------------------------+
#property strict
#property version   "3.50"
#property copyright "OpenAI GPT-5"

#include <Trade/Trade.mqh>
CTrade trade;

input string FileName         = "master_trades.jsonl";
input double LotMultiplier    = 1.0;
input bool   LogToJournal     = true;
input int    CheckIntervalSec = 1;

ulong lastFilePos = 0;

// Map master tickets to slave tickets
struct TicketMap
{
   ulong masterTicket;
   ulong slaveTicket;
};
TicketMap ticketMapping[];

//+------------------------------------------------------------------+
//| Add ticket mapping                                               |
//+------------------------------------------------------------------+
void AddTicketMapping(ulong masterTicket, ulong slaveTicket)
{
   int sz = ArraySize(ticketMapping);
   ArrayResize(ticketMapping, sz + 1);
   ticketMapping[sz].masterTicket = masterTicket;
   ticketMapping[sz].slaveTicket = slaveTicket;
   
   if (LogToJournal)
      PrintFormat("[SLAVE] Mapped master ticket %I64u -> slave ticket %I64u", masterTicket, slaveTicket);
}

//+------------------------------------------------------------------+
//| Find slave ticket by master ticket                               |
//+------------------------------------------------------------------+
ulong FindSlaveTicket(ulong masterTicket)
{
   for (int i = 0; i < ArraySize(ticketMapping); i++)
   {
      if (ticketMapping[i].masterTicket == masterTicket)
         return ticketMapping[i].slaveTicket;
   }
   return 0;
}

//+------------------------------------------------------------------+
//| Extract JSON value                                               |
//+------------------------------------------------------------------+
string GetJsonValue(string json, string key)
{
   int p = StringFind(json, "\"" + key + "\":");
   if (p < 0)
      return "";
   p += StringLen(key) + 3;
   if (p >= StringLen(json))
      return "";

   // Handle string values
   if (StringGetCharacter(json, p) == '\"')
   {
      p++;
      int e = StringFind(json, "\"", p);
      if (e < 0)
         return "";
      return StringSubstr(json, p, e - p);
   }

   // Handle numeric values
   int e = StringFind(json, ",", p);
   if (e < 0)
      e = StringFind(json, "}", p);
   if (e < 0)
      e = StringLen(json);

   return StringSubstr(json, p, e - p);
}

//+------------------------------------------------------------------+
//| Lowercase helper (StringToLower is void-returning in MQL5)       |
//+------------------------------------------------------------------+
string ToLowerCase(string text)
{
   StringToLower(text);
   return text;
}

//+------------------------------------------------------------------+
//| Process each JSON line                                           |
//+------------------------------------------------------------------+
void ProcessLine(string line)
{
   StringTrimLeft(line);
   StringTrimRight(line);
   if (line == "")
      return;

   string action = GetJsonValue(line, "action");
   if (action == "")
      return;

   if (action == "open")
   {
      ulong masterTicket = (ulong)StringToInteger(GetJsonValue(line, "ticket"));
      string sym   = GetJsonValue(line, "symbol");
      double lots  = StringToDouble(GetJsonValue(line, "lots")) * LotMultiplier;
      string typeS = ToLowerCase(GetJsonValue(line, "type"));

      if (lots <= 0.0 || sym == "" || masterTicket == 0)
      {
         if (LogToJournal)
            PrintFormat("[SLAVE] Invalid open data: ticket=%I64u, sym=%s, lots=%.2f", masterTicket, sym, lots);
         return;
      }

      // Check if we already processed this master ticket
      if (FindSlaveTicket(masterTicket) != 0)
      {
         if (LogToJournal)
            PrintFormat("[SLAVE] Already processed master ticket %I64u", masterTicket);
         return;
      }

      bool success = false;
      ulong slaveTicket = 0;
      
      if (typeS == "buy")
      {
         success = trade.Buy(lots, sym);
         if (success)
         {
            slaveTicket = trade.ResultOrder();
            if (LogToJournal)
               PrintFormat("[SLAVE] BUY %s %.2f (master ticket: %I64u, slave ticket: %I64u)", 
                          sym, lots, masterTicket, slaveTicket);
         }
         else
         {
            if (LogToJournal)
               PrintFormat("[SLAVE] Failed to BUY %s %.2f - Error: %d", sym, lots, GetLastError());
         }
      }
      else if (typeS == "sell")
      {
         success = trade.Sell(lots, sym);
         if (success)
         {
            slaveTicket = trade.ResultOrder();
            if (LogToJournal)
               PrintFormat("[SLAVE] SELL %s %.2f (master ticket: %I64u, slave ticket: %I64u)", 
                          sym, lots, masterTicket, slaveTicket);
         }
         else
         {
            if (LogToJournal)
               PrintFormat("[SLAVE] Failed to SELL %s %.2f - Error: %d", sym, lots, GetLastError());
         }
      }
      
      if (success && slaveTicket > 0)
      {
         AddTicketMapping(masterTicket, slaveTicket);
      }
   }
   else if (action == "close")
   {
      ulong masterTicket = (ulong)StringToInteger(GetJsonValue(line, "ticket"));
      if (masterTicket == 0)
      {
         if (LogToJournal)
            Print("[SLAVE] Invalid close command - no ticket");
         return;
      }

      ulong slaveTicket = FindSlaveTicket(masterTicket);
      if (slaveTicket == 0)
      {
         if (LogToJournal)
            PrintFormat("[SLAVE] No slave ticket found for master ticket %I64u", masterTicket);
         return;
      }

      // Find and close the position by slave ticket
      for (int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong posTicket = PositionGetTicket(i);
         if (posTicket == slaveTicket)
         {
            if (PositionSelectByTicket(posTicket))
            {
               string sym = PositionGetString(POSITION_SYMBOL);
               bool success = trade.PositionClose(sym);
               if (success)
               {
                  if (LogToJournal)
                     PrintFormat("[SLAVE] Closed %s (master ticket=%I64u, slave ticket=%I64u)", 
                                sym, masterTicket, slaveTicket);
               }
               else
               {
                  if (LogToJournal)
                     PrintFormat("[SLAVE] Failed to close %s (slave ticket=%I64u) - Error: %d", 
                                sym, slaveTicket, GetLastError());
               }
            }
            break;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Read newly appended lines from master file                       |
//+------------------------------------------------------------------+
void ReadNewLines()
{
   int h = FileOpen(FileName, FILE_READ | FILE_COMMON | FILE_TXT | FILE_ANSI);
   if (h == INVALID_HANDLE)
   {
      if (LogToJournal)
         PrintFormat("[SLAVE] Cannot open file %s - Error: %d", FileName, GetLastError());
      return;
   }

   FileSeek(h, 0, SEEK_END);
   ulong endPos = (ulong)FileTell(h);
   
   if (endPos <= lastFilePos)
   {
      FileClose(h);
      return;
   }

   FileSeek(h, (long)lastFilePos, SEEK_SET);

   while (!FileIsEnding(h))
   {
      string line = FileReadString(h);
      if (line == "")
         break;
      ProcessLine(line);
   }

   lastFilePos = (ulong)FileTell(h);
   FileClose(h);
}

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("✅ Slave copier started (string type mode).");
   
   // Initialize file position to current end (don't process old trades)
   int h = FileOpen(FileName, FILE_READ | FILE_COMMON | FILE_TXT | FILE_ANSI);
   if (h != INVALID_HANDLE)
   {
      FileSeek(h, 0, SEEK_END);
      lastFilePos = (ulong)FileTell(h);
      FileClose(h);
      if (LogToJournal)
         PrintFormat("[SLAVE] Starting from file position: %I64u", lastFilePos);
   }
   
   EventSetTimer(CheckIntervalSec);
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Timer: read file periodically                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   ReadNewLines();
}

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   Print("🟡 Slave copier stopped.");
}
