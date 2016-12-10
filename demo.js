/*jslint browser:true, indent:2*/
/*global pilotCreator*/
(function (global) {
  'use strict';
  var area, pilot, buffer = '', sent = false;

  area = document.querySelector('#output');
  area.addEventListener('keydown', function (e) {

    // Prevent backspace if the buffer is empty
    if (e.which === 8) {
      if (buffer.length > 0) {
        buffer = buffer.substr(0, buffer.length - 1);
      } else {
        e.preventDefault();
      }
    }

    // Ignore the arrow keys
    if ([37, 38, 39, 40].indexOf(e.keyCode) > -1) {
      e.preventDefault();
    }
  });

  area.addEventListener('paste', function (e) {
    e.preventDefault();
  });

  area.addEventListener('keypress', function (e) {
    var chr = String.fromCharCode(e.which);

    e.preventDefault();
    area.scrollTop = area.scrollHeight;
    area.value += chr;

    // Pressing enter sets "sent" as true
    if (e.which === 13) {
      sent = true;
      return;
    }

    // Append the char to the buffer
    buffer += chr;
  }, false);

  // Print text on the textarea
  function print(x) {
    area.value += x;
    area.scrollTop = area.scrollHeight;
    area.focus();
  }

  // Read the input
  function input(fn) {
    var inter;

    sent = false;
    buffer = '';
    print(':');
    inter = setInterval(function () {
      if (sent === true) {
        sent = false;
        fn(buffer);
        buffer = '';
        clearInterval(inter);
      }
    }, 0);
  }

  // Create the PILOT instance
  pilot = pilotCreator(input, print);

  // Listener for the "Run" button
  document.querySelector('#run').addEventListener('click', function () {
    try {
      pilot.execute(document.querySelector('#code').value);
    } catch (e) {
      print(e);
      print('\n');
    }
  });

  // Yes, set the pilot object as global
  global.pilot = pilot;

}(this));
