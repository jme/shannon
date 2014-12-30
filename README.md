# shannon.ml

This is a straightforward implementation of a basic Shannon Entropy calculator.

It's written in stock OCaml and uses a mutable Hashtbl for binning.

![it looks like this](/snaps/fig1c.png)

 

## howto
Run from command line, passing in a string or, with the -f flag, a filename.
Returns the basic Shannon Entropy in bits.

Uses Streams and is fairly fast; file IO will probably account for most of the run time.



## brief dev notes

After a couple of variations using persistent data structures data structures I just went ahead and settled on the mutable Hashtbl for in-place binning operations. 

In a similar nod to speed the core ops of the primary folds are pre-baked as much as possible.
Tested with files up to a few hundred MBs but should handle more nominally.


Also: the core operation code is similar to the simple string-only Shannon Entropy OCaml example I previously wrote for the Rosetta Code site.


## Prerequisites `

Written with standard OCaml 4.01, no extra libs required

Linux i86 build also available.


## License

Copyright © 2014 jm ervin



