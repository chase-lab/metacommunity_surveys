## Automatic data quality testing
### Testing
These tests are ran automatically before every commit thanks to a pre-commit hook.
### Automatising
At the root of the working directory, a bash scripts calls `metacommunity_surveys/tests/testthat.R`
that runs the tests.
Git knows about if because a `pre-commit` file was added inside the `./.git/hooks/` folder. In its most basic form, this scripts contains the following lines:
```
#!/bin/sh
 Rscript tests/testthat.R

```
