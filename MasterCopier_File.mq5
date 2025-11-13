//+------------------------------------------------------------------+
//| MasterCopier_File.mq5                                            |
//| Multi-order copier with per-ticket open/close sync               |
//+------------------------------------------------------------------+
#property strict
#property version   "3.40"
#property copyright "OpenAI GPT-5"

#include <Trade/Trade.mqh>

input string FileName = "master_trades.jsonl";
input bool   LogToJournal = true;

struct TradeInfo
{
   ulong ticket;
   bool active;
};
TradeInfo knownTickets[];
CTrade trade;

//+------------------------------------------------------------------+
//| Write JSON line                                                  |
//+------------------------------------------------------------------+
void WriteJson(string text)
{
   int h = FileOpen(FileName, FILE_READ | FILE_WRITE | FILE_COMMON | FILE_TXT | FILE_ANSI);
   if (h == INVALID_HANDLE)
   {
      Print("❌ Cannot open ", FileName, " error:", GetLastError());
      return;
   }
   FileSeek(h, 0, SEEK_END);
   FileWrite(h, text);
   FileClose(h);
}

//+------------------------------------------------------------------+
//| Add or update ticket                                             |
//+------------------------------------------------------------------+
void MarkTicket(ulong ticket, bool active)
{
   for (int i = 0; i < ArraySize(knownTickets); i++)
   {
      if (knownTickets[i].ticket == ticket)
      {
         knownTickets[i].active = active;
         return;
      }
   }
   TradeInfo t;
   t.ticket = ticket;
   t.active = active;
   int sz = ArraySize(knownTickets);
   ArrayResize(knownTickets, sz + 1);
   knownTickets[sz] = t;
}

//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void OnTimer()
{
   // Get the list of all currently open tickets
   int total = PositionsTotal();
   ulong openTickets[];
   ArrayResize(openTickets, total);

   for (int pos = 0; pos < total; pos++)
   {
      ulong ticket = PositionGetTicket(pos);
      if (ticket == 0)
         continue;

      openTickets[pos] = ticket;

      bool found = false;
      for (int k = 0; k < ArraySize(knownTickets); k++)
      {
         if (knownTickets[k].ticket == ticket && knownTickets[k].active)
         {
            found = true;
            break;
         }
      }

      // New trade detected
      if (!found)
      {
         string sym   = PositionGetString(POSITION_SYMBOL);
         double vol   = PositionGetDouble(POSITION_VOLUME);
         double price = PositionGetDouble(POSITION_PRICE_OPEN);
         ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         string typeStr = (type == POSITION_TYPE_BUY ? "buy" : "sell");

         string json = StringFormat(
            "{\"action\":\"open\",\"ticket\":%I64u,\"symbol\":\"%s\",\"lots\":%.2f,"
            "\"price\":%.5f,\"type\":\"%s\",\"time\":%I64d}",
            ticket, sym, vol, price, typeStr, TimeCurrent());

         WriteJson(json);

         if (LogToJournal)
            PrintFormat("[MASTER] Open sent: %s %s %.2f", typeStr, sym, vol);

         MarkTicket(ticket, true);
      }
   }

   // Check for closed positions
   for (int i = 0; i < ArraySize(knownTickets); i++)
   {
      if (!knownTickets[i].active)
         continue;

      ulong t = knownTickets[i].ticket;
      bool stillOpen = false;

      for (int j = 0; j < total; j++)
      {
         if (openTickets[j] == t)
         {
            stillOpen = true;
            break;
         }
      }

      if (!stillOpen)
      {
         string json = StringFormat("{\"action\":\"close\",\"ticket\":%I64u}", t);
         WriteJson(json);
         knownTickets[i].active = false;

         if (LogToJournal)
            PrintFormat("[MASTER] Close sent: ticket=%I64u", t);
      }
   }
}


//+------------------------------------------------------------------+
int OnInit()
{
   Print("✅ Master copier started.");
   EventSetTimer(1);
   return INIT_SUCCEEDED;
}
void OnDeinit(const int reason)
{
   EventKillTimer();
   Print("🟡 Master copier stopped.");
}
