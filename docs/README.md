Generating Documentation
========================

The Amsterdam Schema Specification is written using
[Bikeshed](https://github.com/tabatkins/bikeshed).

We will be installing Bikeshed into a separate virtual environment
to prevent version clashes between its dependencies
and that of the `amsterdam-schema` project itself.
We will be calling this virtual environment `dvenv`
which stands for `docs venv`

To generate an HTML version of the specification
(assuming you're in the `docs` directory):

```bash
cd ..
python3.9 -m venv dvenv
source dvenv/bin/activate
pip install -U pip setuptools wheel
pip install bikeshed
cd docs
bikeshed spec ams-schema-spec.bs ams-schema-spec.html
open ams-schema-spec.html
```

After this initial installation
all you need to do to regenerate the specification
is to:

* activate the environment: `source dvenv/bin/activate`
* change to the `docs` directory: `cd docs`
* and run the bikeshed command: `bikeshed spec ams-schema-spec.bs ams-schema-spec.html`

The `bikeshed` command can be repeated as often as necessary.
A better solution,
while working on the specification,
would be to use Bikeshed's `watch` subcommand.
It regenerates the HTML upon every document save:

```bash
bikeshed watch ams-schema-spec.bs ams-schema-spec.html
```

to watch as mentioned above while serving the docs on localhost:

```bash
bikeshed serve ams-schema-spec.bs ams-schema-spec.html --port 1234
```

Bikeshed is very picky about its input.
In case of errors it will not (re)generate the document.
To force Bikeshed to generate a document in the presence of errors,
use the `-f` flag to the `spec` or `watch` subcommands.
This should only be used during development
and not for generating the final output;
that should be error free.

Although Bikeshed itself has [extensive documentation](https://tabatkins.github.io/bikeshed/),
it is not the most author friendly documentation.
To see how Bikeshed is used
look at the [source](https://github.com/tabatkins/bikeshed/blob/master/docs/index.bs)
of the Bikeshed documentation.

*IMPORTANT* Don't forget to activate the regular virtual environment `venv`
if you want to:

* bump this project's version
* use the publishing functionality of `amsterdam-schema`. (see `README.md` in project root)

Once a new version of the documentation has been committed it will be published at:

* https://acc.schemas.data.amsterdam.nl/docs/ams-schema-spec.html
* https://schemas.data.amsterdam.nl/docs/ams-schema-spec.html (after approval in Jenkins)
