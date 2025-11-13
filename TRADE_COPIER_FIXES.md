# MQL5 Trade Copier - Critical Fixes Applied

## Problems Identified

### 1. **Slave Not Reading Master Ticket**
- **Issue**: Slave was trying to close positions using the master's ticket number, but slave positions have different ticket numbers
- **Fix**: Implemented ticket mapping system to track master ticket → slave ticket relationships

### 2. **Missing Ticket in JSON**
- **Issue**: Master was sending ticket in JSON but slave wasn't extracting it for open actions
- **Fix**: Slave now extracts and stores master ticket for mapping

### 3. **Timer Interval**
- **Issue**: Slave had `CheckIntervalSec = 0` which might cause issues
- **Fix**: Changed default to 1 second for reliable checking

### 4. **No Duplicate Prevention**
- **Issue**: Slave could process the same trade multiple times
- **Fix**: Added check to prevent processing already-mapped master tickets

### 5. **Poor Error Handling**
- **Issue**: No feedback when operations fail
- **Fix**: Added detailed error logging with GetLastError()

## Key Changes in SlaveCopier_File.mq5

### 1. Ticket Mapping System
```mql5
struct TicketMap
{
   ulong masterTicket;
   ulong slaveTicket;
};
TicketMap ticketMapping[];
```

### 2. Enhanced Open Processing
- Extracts master ticket from JSON
- Creates slave position
- Maps master ticket to slave ticket
- Prevents duplicate processing

### 3. Fixed Close Processing
- Looks up slave ticket using master ticket
- Closes correct slave position
- Provides detailed logging

### 4. Better Initialization
- Sets initial file position to end (avoids processing old trades)
- Uses 1-second timer interval

## How It Works Now

### Opening Trades
1. Master opens position (ticket #12345)
2. Master writes: `{"action":"open","ticket":12345,"symbol":"EURUSD","lots":0.10,"type":"buy"}`
3. Slave reads JSON, extracts master ticket 12345
4. Slave opens position (gets ticket #67890)
5. Slave maps: 12345 → 67890

### Closing Trades
1. Master closes position #12345
2. Master writes: `{"action":"close","ticket":12345}`
3. Slave reads JSON, finds master ticket 12345
4. Slave looks up mapping: 12345 → 67890
5. Slave closes position #67890

## Testing Checklist

- [ ] Place master file in: `C:\Users\[YourUser]\AppData\Roaming\MetaQuotes\Terminal\Common\Files\`
- [ ] Attach MasterCopier_File.mq5 to master chart
- [ ] Attach SlaveCopier_File.mq5 to slave chart
- [ ] Open position on master → Check slave opens position
- [ ] Open multiple positions → Check all copied
- [ ] Close one specific position → Check only that position closes on slave
- [ ] Close all positions → Check all close on slave
- [ ] Check Experts tab for detailed logs

## Configuration

### Master Settings
```
FileName = "master_trades.jsonl"
LogToJournal = true
```

### Slave Settings
```
FileName = "master_trades.jsonl"  // Must match master
LotMultiplier = 1.0               // Adjust for different account sizes
LogToJournal = true               // Enable detailed logging
CheckIntervalSec = 1              // Check file every 1 second
```

## Common Issues & Solutions

### Issue: Slave not copying trades
- **Check**: Both EAs using same FileName
- **Check**: File exists in Common Files folder
- **Check**: AutoTrading enabled on both terminals
- **Check**: Experts tab for error messages

### Issue: Wrong position closes
- **Check**: Ticket mapping in logs
- **Check**: Multiple slaves not interfering
- **Solution**: Each slave maintains its own mapping

### Issue: Duplicate trades
- **Check**: Only one slave EA per terminal
- **Check**: File position tracking working
- **Solution**: Restart slave EA to reset position

## Advanced Features

### Lot Multiplier
Set `LotMultiplier = 0.5` on slave to trade half the master's lot size
Set `LotMultiplier = 2.0` to trade double

### Multiple Slaves
Each slave maintains independent ticket mapping, so multiple slaves can copy the same master

### Symbol Mapping
To add symbol translation (e.g., EURUSD → EURUSDm), modify the `ProcessLine()` function in slave

## File Location
Both master and slave must access the same file:
`C:\Users\[YourUser]\AppData\Roaming\MetaQuotes\Terminal\Common\Files\master_trades.jsonl`

The FILE_COMMON flag ensures this shared location is used.
