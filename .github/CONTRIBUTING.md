flow for a new feature is:

1. branch feature branch off master
2. dev feature
3. submit PR
4. travis build is automatically run for that branch, reported on PR
5. merge PR into master
6. travis build automatically runs for master, deploys if tests still pass
