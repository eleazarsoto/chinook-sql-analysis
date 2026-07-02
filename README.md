# Chinook SQL Analysis 🎵

SQL analysis of the **Chinook database** — a digital music store dataset (SQLite) — covering 17 queries from basic filtering to multi-table JOINs, aggregations, date functions, and subqueries.

> Part of my Data Analytics portfolio. Also see my [Northwind SQL project](https://github.com/eleazarsoto) (39 queries).

## 📊 Dataset

Chinook models a digital music store with 11 tables:

| Area | Tables |
|---|---|
| Catalog | `artists` (275) → `albums` (347) → `tracks` (3,503), plus `genres`, `media_types` |
| Playlists | `playlists` (18) ↔ `playlist_track` (8,715) — many-to-many |
| Sales | `customers` (59) → `invoices` (412) → `invoice_items` (2,240) |
| Staff | `employees` (8) — self-referencing hierarchy + support-rep link to customers |

## 🛠️ Skills demonstrated

- Filtering and string concatenation (`WHERE`, `<>`, `IN`, `||`, aliases)
- Multi-table `JOIN`s, including a 3-table chain (employees → customers → invoices)
- `LEFT JOIN` vs `INNER JOIN` — keeping empty groups in the result
- `COUNT(*)` vs `COUNT(column)` — correct zero counts with NULLs
- Grouping by primary key instead of name to handle duplicate labels
- Date handling with `date()` and `strftime()`, safe date-range filtering
- Aggregations (`COUNT`, `SUM`, `AVG`, `ROUND`) with `GROUP BY` / `ORDER BY`
- Scalar subqueries (values above the average)
- Sanity checks: cross-validating partial sums against table totals

## 💡 Selected findings

- **Pricing is binary**: all video content (TV Shows, Sci-Fi, Drama…) sells at $1.99; every music genre is flat at $0.99.
- **Sales team**: three Sales Support Agents cover 100% of customers; Jane Peacock leads with $833.04 of the $2,328.60 total.
- **2009 vs 2013**: fewer invoices in 2013 (80 vs 83) but *higher* revenue ($450.58 vs $449.46) — the average ticket grew.
- **Data quirks**: four playlist names are duplicated under different IDs, and two playlists are empty — handled with `GROUP BY PlaylistId` + `LEFT JOIN`.

## 📁 Files

- [`chinook_queries.sql`](chinook_queries.sql) — all queries, commented, with expected results and business notes
- `chinook.db` — SQLite database (source: [Chinook Database](https://github.com/lerocha/chinook-database))

## 🔧 Tools

SQLite · SQLiteViz · Git/GitHub

---
**Eleazar Soto** — Data Analyst | Music Producer
[LinkedIn](https://www.linkedin.com/in/eleazar-soto-data/) · [GitHub](https://github.com/eleazarsoto)
