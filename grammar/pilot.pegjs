/*
 * PILOT parser
 * ==========================
 */

Begin
  = Instruction*

Instruction
  = R
  / T
  / A
  / M
  / JM
  / J
  / E
  / Label

Char
  = [a-zA-Z0-9] { return text(); }

_ "whitespace"
  = [ \t]*

nl "newlines"
  = [\n\r]*




Conditioner
  = ('Y' / 'N')

Expression
  = '(' content:[^)]* ')'
  {
    return content.join('');
  }

R
  = 'R' _ conditioner:Conditioner? _ expression:Expression? _ ':' _ text:[^\n]* nl
  { return {
      type : 'Remark',
      conditioner : conditioner || false,
      expression : expression || false,
      content : text.join('')
    }
  }

T
  = 'T'? _ conditioner:Conditioner? _ expression:Expression? _ ':' _ text:[^\n]* nl
  { return {
      type : 'Type',
      conditioner : conditioner || false,
      expression : expression || false,
      content : text.join('')
    }
  }

A
  = 'A' _ conditioner:Conditioner? _ expression:Expression? _ ':' _ variable:[^\n]* nl
  {
    var output = {
      type : 'Accept',
      conditioner : conditioner || false,
      expression : expression || false,
      variable : false
    };
    if (variable.length > 0) {
      output.variable = variable.join('');
    }
    return output;
  }
M
  = 'M' _ conditioner:Conditioner? _ expression:Expression? _ ':' _ matches:[^\n]* nl
  {
     matches = matches.join('').split(/,\s*/);
     return {
       type : 'Match',
       conditioner : conditioner || false,
       expression : expression || false,
       matches : matches
     };
   }
commas
  = _ ',' _

JM
  = 'JM' _ conditioner:Conditioner? _ expression:Expression? _ ':' _ labels:(Lab commas?)* nl
  {
     labels = labels.map(function (label) {
        return label[0];
     });
     return {
       type : 'JumpOnMatch',
       conditioner : conditioner || false,
       expression : expression || false,
       labels : labels
     };
   }
J
  = 'J' _ conditioner:Conditioner? _ expression:Expression? _ ':' _ label:Lab nl
  {
    return {
      type : 'Jump',
      conditioner : conditioner || false,
      expression : expression || false,
      label : label
    };
  }
E
  = 'E' _ conditioner:Conditioner? _ expression:Expression? _ ':' _ nl
  {
    return {
      conditioner : conditioner || false,
      expression : expression || false,
      type : 'End'
    };
  }

Lab = '*' text:[^\n, \t]+
  { return text.join(''); }

Label
  = text:Lab nl
  { return {
      type : 'Label',
      label : text
    };
  }
