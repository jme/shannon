# shannon.ml

This is a straightforward implementation of a basic Shannon Entropy calculator.

It's written in stock OCaml and uses a mutable Hashtbl for binning.

[Wikipedia entry on Shannon Entropy](http://en.wikipedia.org/wiki/Entropy_%28information_theory%29)

 

## howto
Run from command line, passing in a string or, with the -f flag, a filename.
Returns the basic Shannon Entropy in bits.

Uses Streams and is fairly fast; file IO will probably account for most of the run time.


###a few examples

Shannon Entropy of the string "1223334444" (also contained in the demo.txt file)
character count: 10
alphabet size: 4
value: 1.84643934467


the text of "The Time Machine", by H.G. Welles
character count: 178937
alphabet size: 70
value: 4.42227483271


"Alice in Wonderland", by Lewis Carroll
character count: 163783
alphabet size: 87
value: 4.5903438441


genome text of the Enterobacteria phage phiX174
character count: 5386
alphabet size: 4
value: 1.9845793595


executable binary file of the shannon program itself (linux x64)
character count: 439109
alphabet size: 255
value: 5.47700872144


## brief dev notes

After a couple of variations using persistent data structures data structures I just went ahead and settled on the mutable Hashtbl for in-place binning operations. 

In a similar nod to speed the core ops of the primary folds are pre-baked as much as possible.
Tested with files up to a few hundred MBs but should handle more nominally.


Also: the core operation code is similar to the simple string-only Shannon Entropy OCaml example I previously wrote for the [Rosetta Code site](http://rosettacode.org/wiki/Entropy)


## Prerequisites `

Written with standard OCaml 4.01, no extra libs required


## License

Copyright © 2014-2015 jm ervin

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



