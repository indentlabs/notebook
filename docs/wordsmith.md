# Wordsmith

Wordsmith is the word-choice panel in the document editor (hammer icon). While it's
open, highlighting a word in the editor looks it up: meanings, similar and
opposite words, related words, rhymes and near rhymes, pronunciation, and how many
times the word appears in the current document. With the panel closed, the hammer
button in the formatting toolbar opens it for the selected word.

It's a reference tool only. It never changes the writer's text.

## Data sources

All lookups are answered from our own database (`wordsmith_entries`). Nothing calls
a third-party service at request time, so there are no API costs, rate limits or
outside outages to worry about.

The table is built from three open-licensed datasets, downloaded once at import time
as pinned npm packages and checked against their published integrity hashes
(see `Wordsmith::Sources`):

| Dataset | Package | Provides | License |
|---|---|---|---|
| WordNet 3.1 (Princeton University) | `wordnet-db@3.1.14` | Definitions, examples, synonyms, antonyms | WordNet License (free use with attribution) |
| CMU Pronouncing Dictionary | `cmu-pronouncing-dictionary@3.0.0` | Pronunciation, syllables, rhymes | BSD-style / ISC |
| Moby Thesaurus (Grady Ward) | `moby@1.1.2` | Broader "related words" | Public domain |

The WordNet license requires its copyright notice to be shown wherever the data is
used. The panel footer does this, so don't remove it.

## Setup

After running migrations, build the table:

```bash
rake wordsmith:import
```

This takes a minute or two, replaces the table's contents in one transaction (the
panel keeps working with the old data until it commits), and is safe to re-run.
It produces about 240k rows (~100MB). Re-run it after migrations that change the table, such as adding `frequency`. Until it has run, the panel tells writers
Wordsmith isn't available yet.

The import peaks at around 1GB of memory. On Heroku, run it on a larger one-off dyno:

```bash
heroku run --size=standard-2x rake wordsmith:import
```

To import without network access (or to try different data), extract the three
packages into one directory (`wordnet-db/`, `cmu-pronouncing-dictionary/`, `moby/`)
and set `WORDSMITH_SOURCE_DIR` to it.

## Code map

- `app/services/wordsmith/sources.rb`: downloads and verifies the pinned packages
- `app/services/wordsmith/importer.rb`: parses the datasets into `wordsmith_entries`
- `app/services/wordsmith/lookup.rb`: answers a lookup (base forms, rhymes, IPA)
- `app/controllers/wordsmith_controller.rb`: `GET /wordsmith/lookup?q=`
- `app/views/documents/_wordsmith_sidebar.html.erb`: the panel
- `app/assets/javascripts/document_wordsmith.js`: shared Alpine store, selection
  tracking, toolbar button
