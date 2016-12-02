/*jslint node: true, indent: 2, nomen:true */
'use strict';
var parser = require('../lib/pilot');

module.exports = function (self) {
  self.execute = function (source) {
    var ins, interval, ast;

    ast = parser.parse(source);
    self.labels = ast.reduce(function (list, ele, index) {
      if (ele.instruction === "Label") {
        list[ele.label] = index;
      }
      return list;
    }, {});

    function doProcess() {
      var current;

      if (self.waiting) {
        return;
      }
      current = ast[self.next];
      if (current && (current.conditioner === false ||
         ((current.conditioner === 'Y' && self.matched === 1) ||
          (current.conditioner === 'N' && self.matched === 0)))) {

        ins = current.instruction.toLowerCase();
        if (typeof self.instructions[ins] === 'function') {
          self.instructions[ins](current);
        }

      }
      self.next += 1;
      if (self.next > ast.length) {
        clearInterval(interval);
        return;
      }
    }
    interval = setInterval(doProcess.bind(self), 0);
  };
  self.instructions.accept = require("./accept.js").bind(self);
  self.instructions.type = require("./type.js").bind(self);
  self.instructions.match = require("./match.js").bind(self);
  self.instructions.jump = require("./jump.js").bind(self);
  self.instructions.compute = require("./compute.js").bind(self);
  self.instructions.end = require("./end.js").bind(self);
  self.instructions.use = require("./use.js").bind(self);
};

