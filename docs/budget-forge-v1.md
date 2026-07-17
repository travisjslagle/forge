# Budget Forge V1

Budget Forge is a local-first budgeting tool for importing financial CSVs,
normalizing transactions, categorizing spend, and reviewing household trends.

It should be useful before any AI is involved. Local LLM help can be added as an
optional categorization assistant after the import and review loop is solid.

## Goals

- Import CSV exports from personal and household accounts.
- Normalize different bank CSV formats into one transaction model.
- Deduplicate transactions across repeat imports.
- Categorize transactions with explicit rules first.
- Suggest categories for unknown merchants with a local LLM later.
- Keep financial data local to Forge.
- Make monthly spending easy to review.

## Accounts For V1

- Chase checking
- Chase credit card
- Joint PNC household account

Each account source should have its own importer profile because banks use
different CSV headers, date formats, signs for debits/credits, and description
fields.

## Tech Stack

- Python
- FastAPI for the web app and import API
- SQLite for storage
- HTMX or simple server-rendered templates for the UI
- Docker Compose for deployment on Forge
- Optional local LLM endpoint on the gaming PC for category suggestions

The app should live in a separate repo, likely `budget-forge`, while
`forge-infra` remains the repo for host setup and shared services.

Budget Forge is the first useful wedge of the broader Forge product direction.
It should be built as a clean app with callable import, categorization, report,
backup, and audit services so a future assistant or mobile client can use the
same behavior without scraping the UI.

## Data Location On Forge

```text
/srv/forge-data/budget/
  budget.db
  imports/
    raw/
    archive/
  backups/
```

The raw CSV files are sensitive. They should not be committed to git, copied
into this repo, or sent to an external API.

## Expected Data Size

Budget Forge is expected to be small. The transaction database and CSV exports
are not storage-heavy unless the project later starts saving receipt photos,
statement PDFs, or long AI audit logs.

Rough estimates for three accounts:

| Data Type | 1 Year | 5 Years |
| --- | ---: | ---: |
| SQLite transaction database | 5-25 MB | 25-150 MB |
| Raw/archived CSVs | 1-20 MB | 5-100 MB |
| App logs with rotation | 10-200 MB | Depends on retention |
| Encrypted backups | 500 MB-5 GB | 3-25 GB |

Reserve 25-50 GB for Budget Forge and its backups on Forge. That should be
comfortable for many years unless the scope expands to documents or images.

## Encryption And Access

Financial CSVs and the SQLite database are sensitive, even when the app is
local-only.

V1 security decisions:

- Keep Budget Forge reachable only on the LAN and Tailscale.
- Do not expose Budget Forge to the public internet.
- Store app data outside git under `/srv/forge-data/budget`.
- Restrict data directory permissions to the Forge service user.
- Never commit raw CSVs, SQLite databases, exported statements, or backups.
- Encrypt backup archives before copying them off Forge.
- Move only encrypted backups to other machines or cloud storage.

Full-disk encryption would be ideal on a future reinstall, but it is not
required before building the first version. For v1, the biggest practical wins
are narrow network exposure, Linux file permissions, and encrypted backups.

SQLCipher or another encrypted SQLite layer is deferred unless the need becomes
clear. It adds complexity, and it does not replace encrypted backups or access
control.

## Backup Policy

Budget Forge should make backups boring and visible from the beginning.

V1 backup decisions:

- Create a timestamped SQLite backup before every import that mutates data.
- Keep local quick-restore backups under `/srv/forge-data/budget/backups`.
- Include the SQLite database and archived imports in backup archives.
- Encrypt backup archives before moving them off Forge.
- Copy encrypted backups to at least one other machine, such as the Windows
  desktop or gaming PC.
- Add optional offsite encrypted backups later.

Suggested retention:

- Daily backups for 14 days
- Weekly backups for 8 weeks
- Monthly backups for 12 months

The eventual backup tool should probably be `restic` because it provides
encryption, deduplication, pruning, and restore checks. The first version can
start with a simple script that performs a SQLite backup, creates an archive,
encrypts it, and prunes old files.

Restore testing matters. At least monthly, restore a backup into a temporary
folder and verify that the database opens.

## Initial Categories

- Income
- Groceries
- Restaurants
- Gas
- Utilities
- Housing
- Insurance
- Medical
- Subscriptions
- Shopping
- Travel
- Transfer
- Debt Payment
- Fees
- Uncategorized

These should be editable later, but hardcoded categories are fine for the first
working version.

## Import Flow

1. Upload or place a CSV export in the import folder.
2. Choose the source account/importer profile.
3. Parse the CSV into raw rows.
4. Normalize rows into a common transaction shape.
5. Detect duplicates.
6. Apply merchant/category rules.
7. Mark unknown transactions as `Uncategorized`.
8. Show an import review screen before final save.
9. Save approved transactions.
10. Archive the imported CSV.

## Transaction Model

The first schema can stay intentionally plain:

```text
transactions
  id
  source_account
  source_file
  posted_date
  description
  merchant
  amount
  category
  category_source
  review_status
  external_hash
  created_at
  updated_at
```

Add a simple audit table early:

```text
audit_events
  id
  actor
  action
  resource_type
  resource_id
  metadata_json
  created_at
```

Examples include imported CSVs, categorized transactions, changed merchant
rules, generated reports, created backups, and local LLM suggestion requests.

`category_source` should distinguish values such as `rule`, `manual`,
`llm_suggestion`, and `uncategorized`.

`review_status` should distinguish values such as `pending`, `approved`, and
`needs_review`.

`external_hash` should be generated from stable imported fields, likely:

```text
source_account + posted_date + amount + normalized_description
```

## Categorization Order

1. Exact merchant rules
2. Description keyword rules
3. Previous manual decisions for the same merchant
4. Optional local LLM suggestion
5. Uncategorized

The app should learn from manual corrections by saving a merchant rule or
merchant memory entry.

## Local LLM Boundary

LLM categorization should be optional and local. The first likely setup is:

- Forge runs Budget Forge.
- The gaming PC runs Ollama, LM Studio, or a similar local inference server.
- Budget Forge sends small categorization prompts over the LAN or Tailscale.

Only send the minimum necessary fields:

```text
merchant
description
amount
date
allowed categories
```

Do not send:

- Full CSV files
- Account numbers
- User names
- Balances
- Raw statement text
- Authentication data

LLM output should always be treated as a suggestion. A human review step should
approve or correct the category before the app trusts it.

## First Useful Reports

- Monthly spend by category
- Monthly income versus spending
- Uncategorized transaction queue
- Merchant totals
- Recurring subscriptions
- Month-over-month category comparison

## V1 Non-Goals

- Bank login or Plaid-style account syncing
- External AI APIs
- Multi-user permission system
- Tax-grade accounting
- Investment tracking
- Receipt OCR
- Bill pay automation
- Public internet access

## Open Questions

- What exact CSV headers do Chase checking exports use?
- What exact CSV headers do Chase credit card exports use?
- What exact CSV headers do PNC exports use?
- Should transfers between accounts be hidden from spending reports by default?
- Should credit card payments be categorized as `Debt Payment`, `Transfer`, or
  excluded from spending totals?
- Should the first UI be optimized for desktop only, or also comfortable on
  mobile?
