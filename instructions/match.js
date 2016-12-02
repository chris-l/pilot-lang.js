/*jslint node:true,indent:2*/
'use strict';

module.exports = function (instruction) {
  var matchesList, self = this, answer;

  answer = self.answer.toLowerCase();
  self.left = '';
  self.match = '';
  self.right = '';
  matchesList = instruction.matches.reduce(function (list, item, index) {
    var matchTxt, matchRegExp, splitted;

    matchTxt = item.reduce(function (str, part) {
      if (typeof part === 'string') {
        return str + part.replace(/([\*\\\.\[\]\?])/g, '\\$1');
      }
      if (part.wildcard === '*') {
        return str + '.*?';
      }
      if (part.wildcard === '?') {
        return str + '.';
      }
      return str;
    }, '');

    matchRegExp = new RegExp('(' + matchTxt + ')', 'i');
    splitted = answer.split(matchRegExp);

    if (splitted.length === 3) {
      list.push(index);
      self.left = splitted[0];
      self.match = splitted[1];
      self.right = splitted[2];
    }

    return list;
  }, []);

  self.matched = matchesList.length > 0 ? 1 : 0;
};

