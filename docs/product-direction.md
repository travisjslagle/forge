# Forge Product Direction

Forge is a private, local-first household system. The near-term version is a
home server that runs useful services. The longer-term direction is a private
context layer for money, schedule, messages, home status, reminders, and
assistant workflows.

The project can be valuable even if it only serves one household. If it becomes
useful to other households, the product thesis is that people may want a
personal assistant that is built around data ownership instead of cloud custody.

## Product Thesis

Forge should help answer questions like:

- What changed in my budget this month?
- What needs my attention today?
- What bills, calendar events, messages, or home status changes matter?
- What did the assistant read, infer, or act on?
- Where does my data live, and where is it backed up?

The product should emphasize:

- Private data stays private by default.
- The primary copy of household context lives on hardware the user controls.
- AI is optional and inspectable, not the foundation of trust.
- Workflows should be useful before AI is involved.
- Integrations should be explicit and permissioned.
- Backups and recovery are first-class product features.

## Wedge

Forge Budget is the first wedge because financial data is concrete, sensitive,
and recurring. A local budgeting assistant is useful on its own and creates a
good first test of the broader product idea.

The first milestone is not a broad home OS. It is:

```text
Private budgeting and household reports that run on Forge.
```

If that becomes useful enough to miss when it is off, the project earns the
right to expand.

## Platform-Shaped, Wedge-Scoped

Forge should be laid out like a future platform without making v1 heavy.

Suggested repo boundaries over time:

```text
forge-infra/          host setup, Docker, networking, backups
forge-budget/         first product app: imports, categorization, reports
forge-core/           later: identity, permissions, audit log, shared API
forge-connectors/     later: Gmail, calendar, phone, bank sync connectors
forge-mobile/         later: mobile client or reused scheduling/to-do app
```

For now, `forge-infra` and `forge-budget` are enough. The other names are
directional placeholders, not work to start immediately.

## Existing Mobile App

There is already a React Native scheduling/to-do app that links to Google
Calendar. It currently works with data saved on the mobile device and still has
some oddities and bugs to iron out, but it is a strong starting point for
scheduling, calendaring, and phone-facing interaction.

With some cleanup, it may become a useful Forge client shell because it already
has a semi-robust mobile app structure, a calendar integration, and a real UI
surface. That is different from making it the source of truth for Forge data.
Forge should own durable records, permissions, audit trails, and backups.

Good future uses:

- View Forge summaries from the phone.
- Receive reminders and status updates.
- Create tasks or reminders that sync back to Forge.
- Surface calendar-aware budget or household alerts.
- Act as a mobile client for the assistant.

Near-term cleanup questions:

- Which data should remain local-only on the phone?
- Which data should sync to Forge?
- Which mobile bugs or oddities affect trust in reminders and calendar views?
- What should happen when the phone is away from the home network?
- What actions should require explicit confirmation before writing back to
  Forge or Google Calendar?

Security cautions:

- Do not expose Forge directly to the public internet just to support the phone.
- Prefer LAN access when home and Tailscale or another private tunnel when away.
- Treat the phone as a client, not the source of truth.
- Use short-lived tokens or revocable app credentials when the mobile client
  talks to Forge.
- Avoid storing sensitive financial data permanently on the phone unless there
  is a clear need and local device protection is understood.
- Keep a visible audit trail for mobile-triggered actions.

The mobile app should not become the first dependency for Forge Budget. It is a
reasonable later client once the server-side data model and reports are useful.

## Assistant Direction

Forge can eventually have an interactive chatbot, but the assistant should be a
thin reasoning layer over explicit tools and data.

The assistant should be able to:

- Read approved local data stores.
- Call report functions instead of scraping UI screens.
- Explain why it answered a question a certain way.
- Show what data it used.
- Ask before taking actions that affect accounts, calendars, messages, or files.
- Log important reads, suggestions, and actions.

The assistant should not be the only way to use the product. Dashboards,
reports, imports, and backups should work without chat.

## Cloud Edge

Forge's edge over cloud products is not only that data sits on a physical drive.
The deeper edge is that the user owns the household operating context:

- Transactions
- Calendar context
- Reminders
- Home status
- Assistant memory
- Reports
- Preferences
- Backups
- Audit trails

Cloud tools can export data, but Forge should make the local copy the working
memory of the household.

## Validation

The first validation question is personal:

```text
Do I miss Forge Budget when it is off?
```

The second validation question is broader:

```text
Will a few other households trust a local device with sensitive data because the
privacy, usefulness, and recovery story are clear?
```

Signals worth watching:

- Weekly usage without forcing the habit
- Real decisions made from reports
- Reduced friction around budgeting or planning
- Willingness to connect sensitive data
- Clear trust in backup and recovery
- Low support burden after setup

## Non-Goals For Now

- Public internet exposure
- Broad app store or plugin marketplace
- Complex multi-user roles
- Paid appliance packaging
- Fully automated bank sync
- Phone SMS/call access
- Email-reading assistant
- Calendar-writing assistant

These are plausible later directions, but they should wait until the budgeting
wedge and local data model prove useful.
