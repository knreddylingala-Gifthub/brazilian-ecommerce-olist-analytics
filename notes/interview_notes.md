# Interview Preparation & Project Notes

### 1. Project Background
- **What is Olist?** Olist is a Brazilian e-commerce department store marketplace that connects small businesses across Brazil to major sales channels.
- **Goal:** Analyze logistics performance, revenue growth, customer satisfaction, and seller geographical distribution.

### 2. Key Decisions & Rationale
- **Why clean in Python instead of Excel?** Excel cannot easily join 9 relational tables with over 100k rows without performance degradation. `pandas` handles multi-table merging and memory management efficiently.
- **Why use SQL for aggregations?** Database engines are optimized for filtering, joining, and aggregating structured data before loading it into Power BI, reducing BI refresh times.
