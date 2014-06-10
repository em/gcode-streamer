#!/usr/bin/env node

var serialport = require('serialport');
var SerialPort = serialport.SerialPort;
var repl = require("repl");
var program = require('commander');
var exec = require('child_process').spawn;

program
  .version(require('./package.json').version)
  .usage('[options] <file ...>')

program.parse(process.argv);

var args = {
  baud: 115200,
  portname: '/dev/tty.usbserial-DA00CQJ0',
  parity: 'none',
  stopbits: 1,
  databits: 8,
  rtscts: true,
  xon: true,
  flowControl: true
};

var openOptions = {
  baudRate: args.baud,
  dataBits: args.databits,
  parity: args.parity,
  stopBits: args.stopbits,
  parser: serialport.parsers.readline("\n") 
};

var port = new SerialPort(args.portname, openOptions);

var queue = [];

if(program.args.length > 0) {
  var a = Array.prototype.slice(program.args)
  exec(a, function (error, stdout, stderr, stdin) {
    if (error !== null) {
      console.log('exec error: ' + error);
    }
    else {
      stream(stdin, stdout);
    }
  });
}
else {
  stream(process.stdin, process.stdout);
}

function stream(stdin, stdout) {

  port.on("open", function () {

    port.flush();

    var closing = false;
    var sending = false;

    function dequeue() {
      var cmd = queue.shift();

      if(!cmd) {
        if(closing) {
          process.exit(0);
        }
        return;
      }

      sending = true;
      port.write(cmd, function (err) {
        if (err) {
          console.log(err);
        }
        sending = false;
      });
    }

    function eval(cmd, context, filename, callback) {
      cmd = cmd.slice(1,-2) + '\n';
      queue.push(cmd);

      if(!sending) {
        dequeue();
      }

      if(cmd.match(/M30/i)) {
        closing = true;
        // port.close();
      }
    }

    port.on('data', function (data) {
      console.log(data);
      dequeue();
    });

    port.on('error', function (err) {
      console.log(err);
    });

    port.on('close', function () {
      process.exit(0);
    });

    repl.start({
      prompt: "",
      input: stdin,
      output: stdout,
      eval: eval,
      ignoreUndefined: true
    });
  });
}
