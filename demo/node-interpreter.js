#!/usr/bin/node

/**
 *
 * A simple nodejs-based PILOT command line interpreter.
 * It uses readline for input and process.stdout for output
 *
 * Use: node-interpreter.js filename.p
 */
/*jslint node: true, indent: 2, nomen:true */
'use strict';
var pilotCreator, pilot, fs, path, readline;

pilotCreator = require('../');
fs = require('fs');
path = require('path');
readline = require('readline');

function input(fn) {
  var rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  rl.question(':', function (ans) {
    fn(ans);
    rl.close();
    return;
  });
}

function output(txt) {
  process.stdout.write(txt);
}

pilot = pilotCreator(input, output);

if (process.argv[2] === undefined) {
  console.log('Use: ' + path.basename(process.argv[1]) + ' filename.p');
  process.exit();
}
fs.readFile(process.argv[2], 'utf8', function (err, src) {
  if (err) {
    console.log('here');
    throw new Error(err);
  }
  pilot.execute(src);
});

