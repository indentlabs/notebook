Checklist to create a new content type:

- List all fields/types/relations out (for your sanity)
  - e.g. https://github.com/indentlabs/notebook/issues/258

- Generate models (with non-relation fields)
  - rails g model Character name:string
  - (can probably merge this with the below soon)
  - probably want to just put core attributes here eventually, after de-systemizing other fields
