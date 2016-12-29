PILOT-lang.js
=============

This is a JavaScript based interpreter for the [PILOT language](https://en.wikipedia.org/wiki/PILOT).

After reading [an entry on the blog of Eric S Raymond](http://esr.ibiblio.org/?p=7244)
about a compiler he wrote for this language - called [ieee-pilot](https://gitlab.com/esr/ieee-pilot) -
and reading about his frustation parsing the PILOT code, I decided to try to write a parser, but
using a [PEG](https://en.wikipedia.org/wiki/Parsing_expression_grammar) generator instead.
(According to his entry, he uses [Bison](https://en.wikipedia.org/wiki/GNU_bison) on his compiler,
and I think that back then, when he created his compiler, PEG didn't existed yet).
The generator I used is [peg.js](https://pegjs.org).

After creating the parser, I created a (very simple) interpreter for it. This is still unfinished,
but is already mostly compatible with the IEEE specification, and several of the extentions added by ESR.

## Demo

Check the [browser version of the interpreter](https://chris-l.github.io/pilot-lang.js/).

## Use

This interpreter lacks it's own input/output mechanism and instead, the function to create an instance
of the interpreter requires to pass to it a function used for input (the one used for "Accept" instructions)
and another one used for output (the one used for the "Type" instructions, like T, TH, Y and N)

On the `demo/` directory, there is a command line version of the interpreter that uses nodejs,
and the browser version used on the online demo.

The nodejs version uses readline for intput and `process.stdout.write()` for output.

The browser version uses a textarea with event listeners for it's input/output.

The use is something like this:

```
var code = 'T :Some PILOT code';

function inputFunction(cb) {
  // Somehow, get the input text.
  var txt = ....;

  // It is assumed this is async, so we must
  // call the callback with the text once is available.
  cb(txt);
}

function outputFunction(txt) {
  // Print the text somehow.
}

var pilot = require('pilot-lang.js')(inputFunction, outputFunction);

pilot.execute(code);
```

## License

MIT
