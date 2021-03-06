/*
 * PILOT parser
 * ==========================
 * The parser of this project is based on PEG formalism, and was created with peg.js.
 * Try to copy/paste this on the online demo of pegjs (https://pegjs.org/online )
 * to see the parser on action!
 */
{
  function reduceText(str) {
    return str.reduce(function (arr, x) {
      var prev = arr.length - 1;
      if (prev > -1 && typeof x === 'string' && typeof arr[prev] === 'string') {
        arr[prev] += x;
        return arr;
      }
      arr.push(x);
      return arr;
    }, []);
  }
}

Begin
  = EmptyLine? statements:Statement* EmptyLine?
  {
    return statements.reduce(function (a, b) {
      if (!b) {
        return a;
      }
      return a.concat(b);
    }, []);
  }

EmptyLine
  = _ nl { return; }

Statement
  = RemarkBlock
  / TypesBlock
  / A
  / M
  / JM
  / J
  / E
  / U
  / C
  / PA
  / Label
  / NotImplemented

Text
  = txt:(Escaped / InternalIdentifier / IdentifierText / IntraLineComment / Char)*
  {
    return reduceText(txt);
  }

Escaped
  = '\\' char:[^\n]
  {
    return char;
  }

InternalIdentifier
  = '%' id:('answer' / 'left' / 'match' / 'right' / 'matched')
  {
    return {
      element : 'internal_ident',
      value : id
    };
  }

Char
  = [^\n]

IntraLineComment
  = _ '//' Char*
  { return ''; }

_ "whitespace"
  = [ \t]*

nl "newlines"
  = (_ !.) / (_ [\n\r])*

Assignment
  = AssignmentString
  / AssignmentNumeric

AssignmentString
  = id:StringIdent _ '=' text:Text nl
  {
    return {
      element : 'assignment',
      identifier : id,
      value : text
    };
  }

AssignmentNumeric
  = id:NumericIdent _ '=' _ value:NumericExpression _ nl
  {
    return {
      element     : 'assignment',
      identifier  : id,
      value       : value
    };
  }

BinaryOperation
  = left:Numeric _ operator:[+-\/\*%] _ right:NumericExpression
  {
    return {
      element   : 'BinaryOperation',
      left      : left,
      operator  : operator,
      right     : right
    };
  }

NumericParens
  = '(' _ out:NumericExpression _ ')'
  { return out; }

NumericExpression
  = BinaryOperation
  / Numeric

Numeric
  = NumericParens
  / Number
  / NumericIdent
  / InternalIdentifier

Conditioner
  = [YyNn]
  {
    return text().toUpperCase();
  }

Expression
  = '(' _ content:ExpressionContent _ ')'
  {
    return content;
  }
ExpressionContent
  = RelationalExpression
  / val:NumericExpression { return { type : 'mathExpression', expression : val }; }

RelationalOperator
  = '='
  / '<>'
  / '<'
  / '>'
  / '<='
  / '>='

RelationalExpression
  = left:Numeric _ operator:RelationalOperator _ right:NumericExpression
  {
    return {
      type      : 'relationalExpression',
      operator  : operator,
      left      : left,
      right     : right
    };
  }

Number "number"
  = [0-9]+
  {
    return parseInt(text(), 10);
  }

AthruZ
  = [a-zA-Z]

LimitedChar
  = [a-zA-Z0-9_]

LimitedString
  = str:(LimitedChar? LimitedChar? LimitedChar? LimitedChar? LimitedChar? LimitedChar? LimitedChar? LimitedChar? LimitedChar?)
  {
    return str.join('');
  }

StringIdent2
  =  '$' str:(AthruZ LimitedString) { return str; }
  / str:(AthruZ LimitedString) '$' { return str; }

StringIdent
  =  str:StringIdent2
  {
    return {
      element : 'string_ident',
      value : (str[0] + str[1]).toLowerCase()
    };
  }

NumericIdentHash
  = '#' str:(AthruZ LimitedString)
  { return (str[0] + str[1]).toLowerCase(); }

NumericIdentPlain
  = str:(AthruZ LimitedString)
  { return (str[0] + str[1]).toLowerCase(); }

NumericIdentText
  = varName:NumericIdentHash
  {
    return {
      element : 'numeric_ident',
      value : varName
    };
  }

NumericIdent
  = varName:( NumericIdentHash / NumericIdentPlain)
  {
    return {
      element : 'numeric_ident',
      value : varName
    };
  }

Identifier
  = NumericIdent
  / StringIdent

IdentifierText
  = NumericIdentText
  / StringIdent

R "Remark"
  = _ ('Remark'i / 'R'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ text:[^\n]* nl
  { return {
      instruction : 'Remark',
      conditioner : conditioner || false,
      expression : expression || false,
      content : text.join('')
    }
  }

REmpty
  =  _ conditioner:Conditioner? _ expression:Expression? _ ':' text:[^\n]* nl
  { return {
      instruction : 'Remark',
      continuation : true,
      content : text.join('')
    };
  }

RemarkBlock
  = block:(R REmpty*)
  {
    return (block[1] || []).reduce(function (a, b) {
      b.conditioner = block[0].conditioner;
      b.expression = block[0].expression;
      return a.concat(b);
    }, [ block[0] ]);
  }

Y
  = _ ('Yes'i / 'Y'i) _ expression:Expression? _ ':' text:Text IntraLineComment? nl
  {
    text.push("\n");
    return {
      instruction : 'Type',
      conditioner : 'Y',
      expression : expression || false,
      text : text
    }
  }

N
  = _ ('No'i / 'N'i) _ expression:Expression? _ ':' text:Text IntraLineComment? nl
  {
    text.push("\n");
    return {
      instruction : 'Type',
      conditioner : 'N',
      expression : expression || false,
      text : text
    }
  }

T
  = _ ('Type'i / 'T'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' text:Text IntraLineComment? nl
  {
    text.push("\n");
    return {
      instruction : 'Type',
      conditioner : conditioner || false,
      expression : expression || false,
      text : text
    }
  }

TH
  = _ ('TypeHang'i / 'TH'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' text:Text IntraLineComment? nl
  {
    return {
      instruction : 'TypeHang',
      conditioner : conditioner || false,
      expression : expression || false,
      text : text
    }
  }

TEmpty
  = _ ':' text:Text IntraLineComment? nl
  {
    return {
      instruction : 'Type',
      continuation : true,
      text : text
    };
  }

TypesBlock "Type"
  = block:((T / Y / N / TH) TEmpty*)
  {
    return (block[1] || []).reduce(function (a, b) {
      b.instruction = block[0].instruction;
      b.conditioner = block[0].conditioner;
      b.expression = block[0].expression;
      if (b.instruction !== 'TypeHang') {
        b.text.push("\n");
      }
      return a.concat(b);
    }, [ block[0] ]);
  }

A "Accept"
  = _ ('Accept'i / 'A'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ identifier:Identifier? IntraLineComment? nl
  {
    return {
      instruction : 'Accept',
      conditioner : conditioner || false,
      expression : expression || false,
      identifier : identifier || false
    };
  }
M "Match"
  = _ ('Match'i / 'M'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ matches:(matchStr matches*) IntraLineComment? nl
  {
     matches[1].unshift(matches[0]);
     return {
       instruction : 'Match',
       conditioner : conditioner || false,
       expression : expression || false,
       matches : matches[1]
     };
   }
matchWildCard
  = [\\*\?]
  {
    return { wildcard:text() };
  }
matchStr
  = str:(Escaped / InternalIdentifier / IdentifierText / matchWildCard / [^,!\|\n])*
  {
    return reduceText(str);
  }
matches
  = [,!\|] str:matchStr { return str; }

commas
  = _ ',' _

JM "JumpMatch"
  = _ ('JumpMatch'i / 'JM'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ labels:(Labl commas?)* IntraLineComment? nl
  {
     labels = labels.map(function (label) {
        return label[0];
     });
     return {
       instruction : 'JumpOnMatch',
       conditioner : conditioner || false,
       expression : expression || false,
       labels : labels
     };
   }
J "Jump"
  = _ ('Jump'i / 'J'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ label:Labl IntraLineComment? nl
  {
    return {
      instruction : 'Jump',
      conditioner : conditioner || false,
      expression : expression || false,
      label : label
    };
  }
E "End"
  = _ ('End'i / 'E'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ IntraLineComment? nl
  {
    return {
      conditioner : conditioner || false,
      expression : expression || false,
      instruction : 'End'
    };
  }
U "Use"
  = _ ('Use'i / 'U'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ label:Labl _ IntraLineComment? nl
  {
    return {
      instruction : 'Use',
      conditioner : conditioner || false,
      expression : expression || false,
      label : label
    };
  }
C "Compute"
  = _ ('Compute'i / 'C'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ assignment:Assignment _ IntraLineComment? nl
  {
    return {
      instruction : 'Compute',
      conditioner : conditioner || false,
      expression : expression || false,
      assignment : assignment
    };
  }
PA "Pause"
  = _ ('Pause'i / 'PA'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ duration:Number _ IntraLineComment? nl
  {
    return {
      instruction : 'Pause',
      conditioner : conditioner || false,
      expression : expression || false,
      duration : duration
    };
  }

NotImplemented "a-non-implemented-instruction"
  = ('CH'i / 'CA'i / 'CL'i / 'CE'i / 'PR'i / 'Problem'i / 'Link'i / 'L'i / 'System'i / 'XS'i / 'F'i / 'G'i) [^\n]* nl { return; }

Labl "Label"
  = '*' text:[^\n, \t]+
  { return text.join('').toLowerCase(); }

Label
  = _ text:Labl IntraLineComment? nl
  { return {
      instruction : 'Label',
      label : text
    };
  }
