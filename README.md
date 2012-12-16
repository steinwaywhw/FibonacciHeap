FibonacciHeap
=============

It's kind of too difficult for me to implement a formal linear version heap. It is especially complex to deal with linear resource in a node that contains indexes of related nodes.

Since I can't make it before the due, I simply wrapped basic memory related C code in ATS, and implement the heap function in ATS only. I feel disappointed for the failure, but I do need further practice to understand linear resource and its usage. Will and Alex have provided many useful tips and their understanding about linear resource, but I just couldn't make it. Sorry again.

Current version:

There is actually NO type constrains at all. The user have to use the code on their own risks. If they use it in a correct way, the code is OK. Otherwise, even it is typechecked, it won't run correctly. It's simply a ATS version of C code.

Problem:

It's straight forward to encode a single link list using linear types, since there will be only one pointer points to a resource. But what happens when I want a target to be pointed by multiple sources? How to properly manage them using linear types?