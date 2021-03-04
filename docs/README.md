Generating Documentation
========================

The Amsterdam Schema Specification is writting using [Bikeshed](https://github.com/tabatkins/bikeshed).
To generate an HTML version of the specification 
(assuming you're in the `docs` directory):

```bash
cd ../src
make install
cd docs
bikeshed spec ams-schema-spec.bs ams-schema-spec.html
open ams-schema-spec.html
```

Bikeshed has a `watch` command 
that allows you to work on the document 
while Bikeshed regenerates the HTML upon every document save:

```bash
bikeshed watch ams-schema-spec.bs ams-schema-spec.html
```

Bikeshed is very picky about its input.
In case of errors it will not (re)generate the document.
To force Bikeshed to generate a document in the presence of errors,
use the `-f` flag to the `spec` or `watch` command..
This should only be used during development
and not for generating the final output;
that should be error free.

Although Bikeshed itself has [extensive documentation](https://tabatkins.github.io/bikeshed/),
it is not the most author friendly documentation.
To see how Bikeshed is used 
look at the [source](https://github.com/tabatkins/bikeshed/blob/master/docs/index.bs) of the Bikeshed documentation.




