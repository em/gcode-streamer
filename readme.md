# Gcode Streamer

A simple utility I use to stream and REPL Gcode to my personal CNC machine which uses the [TinyG](https://github.com/synthetos/TinyG) driver but should work fine with grbl too. I wasn't able to find anything already made that really worked well.

My own serial port and baud rate are hardcoded. Feel free to use it as a basis for communicating with your own CNC machine. 

1. It keeps an internal queue of lines from stdin.

2. It waits for a response from the driver before sending the next line.
   This is important in serial i/o to not exceed the rx buffer which will result in corrupted data.

3. It closes the serial port (gracefully) when it sees an M30 

 
