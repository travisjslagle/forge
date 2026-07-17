# Budget CSV Importers

These notes describe CSV export formats observed during early Budget Forge
planning. They should capture importer behavior without committing raw financial
CSV files or transaction rows.

## Source Files Reviewed

Local sample files reviewed on 2026-07-17:

- Chase checking sample: 6 rows
- PNC joint account sample: 10 rows
- Discover credit card recent activity: 8 rows
- Chase credit card activity: 5 rows

Do not commit these CSVs to git. Keep raw files in local private storage only.

## Chase Checking

Observed headers:

```text
Details, Posting Date, Description, Amount, Type, Balance
```

Initial importer mapping:

| Normalized Field | Source Field | Notes |
| --- | --- | --- |
| `source_account` | configured account | `chase_checking` |
| `posted_date` | `Posting Date` | Format observed as `MM/DD/YYYY` |
| `description` | `Description` | Preserve original text |
| `amount` | `Amount` | Negative values are debits |
| `transaction_type` | `Type` | Bank-provided type |
| `balance` | `Balance` | May be blank on pending/recent rows |

Notes:

- `Details` appears to distinguish debit/credit-style row direction.
- Some descriptions include transfers or payments to other accounts.
- Balance should be optional.

## Chase Credit Card

Observed headers:

```text
Transaction Date, Post Date, Description, Category, Type, Amount, Memo
```

Initial importer mapping:

| Normalized Field | Source Field | Notes |
| --- | --- | --- |
| `source_account` | configured account | `chase_credit_card` |
| `transaction_date` | `Transaction Date` | Format observed as `MM/DD/YYYY` |
| `posted_date` | `Post Date` | Format observed as `MM/DD/YYYY` |
| `description` | `Description` | Preserve original text |
| `source_category` | `Category` | Bank-provided category |
| `transaction_type` | `Type` | Sale/payment/etc. |
| `amount` | `Amount` | Purchases observed as negative; payments positive |
| `memo` | `Memo` | Optional |

Notes:

- Credit card payments should probably be categorized as `Transfer` or excluded
  from spending totals after review.
- Bank-provided categories are useful hints, not final categories.

## PNC Joint Account

Observed headers:

```text
Transaction Date, Transaction Description, Amount, Category, Balance
```

Initial importer mapping:

| Normalized Field | Source Field | Notes |
| --- | --- | --- |
| `source_account` | configured account | `pnc_joint_checking` |
| `posted_date` | `Transaction Date` | Format observed as `YYYY-MM-DD` |
| `description` | `Transaction Description` | Preserve original text |
| `amount` | `Amount` | Currency-formatted strings like `-$12.34` |
| `source_category` | `Category` | Bank-provided category |
| `balance` | `Balance` | Currency-formatted strings |

Notes:

- Importer needs currency parsing for dollar signs, commas, and quoted values.
- Descriptions may include masked account/card fragments; store as imported but
  avoid sending full descriptions to external services.

## Discover Credit Card

Observed headers:

```text
Trans. Date, Post Date, Description, Amount, Category
```

Initial importer mapping:

| Normalized Field | Source Field | Notes |
| --- | --- | --- |
| `source_account` | configured account | `discover_credit_card` |
| `transaction_date` | `Trans. Date` | Format observed as `MM/DD/YYYY` |
| `posted_date` | `Post Date` | Format observed as `MM/DD/YYYY` |
| `description` | `Description` | Preserve original text |
| `amount` | `Amount` | Purchases observed as positive |
| `source_category` | `Category` | Bank-provided category |

Notes:

- Discover uses positive amounts for purchases in the observed activity file.
- Normalization should convert spending to the shared app convention.

## Shared Normalization Decisions

Use one internal amount convention across all importers:

```text
negative = money leaving the household
positive = money entering the household or reducing debt
```

That means some credit card imports may need account-aware sign handling.

Preserve these raw fields where available:

- original description
- source category
- source transaction type
- source file name
- source row number

The initial duplicate hash should include:

```text
source_account + posted_date + normalized_amount + normalized_description
```

If collisions appear later, add transaction date, source type, or row-level
source metadata.

## Importer Build Order

1. Chase credit card
2. Chase checking
3. PNC joint checking
4. Discover credit card

Chase credit card is a good first importer because it includes transaction
date, post date, source category, type, amount, and memo fields.
