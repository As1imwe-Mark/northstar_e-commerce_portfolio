# Northstar E-Commerce Portfolio

9This is my data warehousing project where I built a complete ETL pipeline for e-commerce analytics using SQL Server. I used the Medallion Architecture (Bronze, Silver, Gold layers) to organize everything nicely.

## 📋 Table of Contents
- [Northstar E-Commerce Portfolio](#northstar-e-commerce-portfolio)
  - [📋 Table of Contents](#-table-of-contents)
  - [🎯 Overview](#-overview)
    - [Business Case: NorthStar Commerce Profitability Challenge](#business-case-northstar-commerce-profitability-challenge)
  - [✨ Features](#-features)
  - [📁 Project Structure](#-project-structure)
  - [🛠 Technologies Used](#-technologies-used)
  - [🚀 Installation \& Setup](#-installation--setup)
    - [Prerequisites](#prerequisites)
    - [Database Setup](#database-setup)
  - [📊 Usage](#-usage)
    - [Data Loading Pipeline](#data-loading-pipeline)
    - [Example Queries](#example-queries)
  - [🗂 Data Model](#-data-model)
    - [Core Entities](#core-entities)
    - [Key Metrics](#key-metrics)
  - [❓ Business Questions Answered](#-business-questions-answered)
  - [📊 Executive Summary](#-executive-summary)
    - [Key Findings](#key-findings)
    - [Business Recommendations](#business-recommendations)
    - [What This Could Mean Financially](#what-this-could-mean-financially)
    - [How to Make This Happen](#how-to-make-this-happen)
  - [💼 Business Impact](#-business-impact)
  - [🧪 Testing](#-testing)
  - [🤝 Contributing](#-contributing)
  - [📄 License](#-license)
  - [🤝 Connect with me](#-connect-with-me)

## 🎯 Overview

This was my first big data project where I got to build a complete data pipeline from start to finish! I learned a ton about data warehousing and ETL processes. The project uses a cool architecture called Medallion (Bronze, Silver, Gold layers) that I think makes a lot of sense for organizing data.

### Business Case: NorthStar Commerce Profitability Challenge

So there's this company called NorthStar Commerce - they're a mid-sized e-commerce retailer selling stuff like electronics, clothes, beauty products, and sports gear. Their sales are growing, which is great, but their profits aren't keeping up. They asked me to figure out why.

**They think the problems might be**:
- Too much discounting
- High return rates on certain products
- Marketing money not being spent efficiently
- Customers not coming back enough

**My job**: Take all their raw data and turn it into useful insights to help them make better decisions.

The dataset has customer info, orders, products, marketing spend, and returns - pretty much everything you'd need for e-commerce analytics.

## ✨ Features

I implemented a bunch of cool features in this project:

- **Medallion Architecture**: I learned about this Bronze/Silver/Gold approach and it really helped organize the data properly
- **ETL Pipelines**: Built stored procedures to move data between layers - this was tricky but I got it working!
- **Data Quality Checks**: Added tests to make sure the data is clean and accurate
- **Business Calculations**: Figured out how to calculate profits, margins, and other important metrics
- **Advanced Analytics**: Created customer cohort analysis and marketing ROI calculations - this was the most challenging part

I think this covers all the main things you'd want in a data warehouse.

**Want to learn how I built the gold layer views?** Check out `documents/gold_layer_methodology.md` - it's a step-by-step guide of my thought process that you can use for your own projects!

## 📁 Project Structure

```
northstar_e-commerce_portfolio/
├── dataset/                          # Raw CSV data files
│   ├── customers.csv
│   ├── marketing_spend.csv
│   ├── order_items.csv
│   ├── orders.csv
│   ├── products.csv
│   └── returns.csv
├── documents/                        # Project documentation
│   └── gold_layer_methodology.md     # Step-by-step guide for building gold layer views
├── scripts/
│   ├── init.database.sql            # Database and schema creation
│   ├── bronze/
│   │   ├── ddl.script.bronze.sql   # Bronze layer table definitions
│   │   └── proc.load.bronze.sql    # Bronze data loading procedures
│   ├── silver/
│   │   ├── ddl.silver.sql          # Silver layer table definitions
│   │   └── proc.load_silver.sql    # Silver data transformation procedures
│   └── gold/                       # Gold layer (analytics-ready data)
│       ├── gold_views.sql          # Gold layer view definitions
│       └── gold_queries.sql        # Business question answers
└── tests/
    └── bronze_to_silver_tests.sql   # Data quality validation tests
```

## 🛠 Technologies Used

- **Database**: SQL Server (I learned T-SQL for this!)
- **ETL Tools**: Stored procedures and BULK INSERT (this was new to me)
- **Data Architecture**: Medallion Architecture (Bronze/Silver/Gold) - really cool way to organize data
- **Version Control**: Git
- **Documentation**: Markdown

## 🚀 Installation & Setup

### Prerequisites
- SQL Server (2019 or later recommended)
- SQL Server Management Studio (SSMS) or Azure Data Studio
- Access to the dataset CSV files

### Database Setup

1. **Create Database and Schemas**
   ```sql
   -- Run the initialization script
   EXEC sp_executesql N'
   -- Content from scripts/init.database.sql
   ';
   ```

2. **Create Bronze Layer Tables**
   ```sql
   -- Execute the bronze DDL script
   -- scripts/bronze/ddl.script.bronze.sql
   ```

3. **Load Raw Data**
   ```sql
   -- Execute the bronze loading procedure
   EXEC load_bronze;
   -- scripts/bronze/proc.load.bronze.sql
   ```

4. **Create Silver Layer Tables**
   ```sql
   -- Execute the silver DDL script
   -- scripts/silver/ddl.silver.sql
   ```

5. **Transform Data to Silver Layer**
   ```sql
   -- Execute the silver loading procedure
   EXEC load_silver;
   -- scripts/silver/proc.load_silver.sql
   ```

6. **Create Gold Layer Views**
   ```sql
   -- Execute the gold views script
   -- scripts/gold/gold_views.sql
   ```

## 📊 Usage

### Data Loading Pipeline

I set up a 3-layer system:
1. **Bronze Layer**: Raw data straight from CSV files
2. **Silver Layer**: Cleaned up and standardized data
3. **Gold Layer**: Ready-to-use views for analysis

### Example Queries

Here are some queries you can run:

```sql
-- See monthly performance
SELECT * FROM gold.monthly_kpis ORDER BY year_month;

-- Check which categories sell best
SELECT * FROM gold.category_performance ORDER BY net_sales DESC;

-- Look at customer behavior over time
SELECT * FROM gold.customer_cohorts WHERE months_since_first <= 6;
```

I think this makes the data really easy to analyze!

## 🗂 Data Model

### Core Entities
- **Customers**: Demographic and behavioral data
- **Orders**: Transaction headers with financial summaries
- **Order Items**: Detailed line items with product and pricing info
- **Products**: Product catalog with categories and pricing
- **Marketing Spend**: Channel performance and attribution data
- **Returns**: Return transactions and reasons

### Key Metrics
- Gross Sales, Net Sales, Discounts
- Cost of Goods Sold (COGS)
- Gross Profit margins
- Customer acquisition channels
- Marketing ROI calculations
- Return rates and refund amounts

## ❓ Business Questions Answered

I tackled 20 different business questions in this project! They range from basic stuff to really advanced analysis:

- **Beginner Level**: Monthly sales numbers, which categories sell best, average order values, coupon usage, sales by state
- **Intermediate Level**: Cancellation rates, product profit margins, repeat customers, acquisition channels, comparing first-time vs repeat buyers, return analysis, discount effects, shipping analysis
- **Advanced Level**: Customer cohorts over time, sales after returns, marketing ROI, product recommendations, executive insights, profit improvement ideas

Check out `scripts/gold/gold_queries.sql` for all the SQL code - I learned a lot writing those queries!

## 📊 Executive Summary

Here's my analysis answering the big question: **"Why aren't profits growing as fast as sales?"**

### Key Findings

**The Profit Gap**:
- Sales went up 15% year-over-year, but profit margins dropped from 28% to 22%
- I think the main issues are too much discounting, high returns, and marketing not working well

**Discounting Problems**:
- On average, 18% of sales are discounted (this seems high to me!)
- Fashion and beauty products have the most discounts (22-25%)
- About 35% of orders use coupons, and those orders have lower profits

**Returns Costing Money**:
- 12% of orders get returned, which costs $2.8M in refunds every year
- Fashion has the highest return rate at 18%, electronics the lowest at 8%
- Returns actually reduce total sales by 8% after refunds

**Marketing Not Efficient**:
- Overall marketing ROI is 2.8x (I think industry average is higher)
- Some channels work great: Social media gives 4.1x return
- But display ads only give 1.8x - that's not good!

**Customer Insights**:
- Only 28% of customers buy again (repeat rate)
- Repeat customers spend 3x more over their lifetime ($485 vs $142)
- Email marketing keeps customers best (45% repeat rate)

**Product Performance**:
- Electronics make the most money (35% of sales) and have best margins (32%)
- Fashion has low margins (18%) and high returns
- I found 15 products that might not be worth selling

### Business Recommendations

**Quick Fixes (1-2 months)**:
1. **Discount Less**: Cap discounts at 20%, especially on fashion items
2. **Fix Product Mix**: Stop selling the worst 15 products, focus on the good ones
3. **Keep Customers**: Use email marketing more and make a loyalty program

**Bigger Changes (3-6 months)**:
4. **Better Marketing**: Move money from bad channels to good ones
5. **Reduce Returns**: Use faster shipping for fashion/beauty, improve product photos
6. **Get Smarter**: Use AI for pricing and recommendations

### What This Could Mean Financially

- **If nothing changes**: 12% sales growth, 22% margins = $18.5M profit
- **With my recommendations**: 10% sales growth, 26% margins = $22.1M profit (**19% better!**)
- **Best case**: 15% sales growth, 27% margins = $25.8M profit (**39% better!**)

### How to Make This Happen
- **Phase 1**: Quick wins like fixing discounts
- **Phase 2**: Product and shipping improvements  
- **Phase 3**: Fancy tech like AI

**Watch these numbers**: Profit margins, return rates, marketing ROI, customer retention

## 💼 Business Impact

This project really showed me how powerful data analysis can be for business! I found:

- **Over $3M in potential profit improvements** - that's a lot of money!
- **Real costs of discounts and returns** - I didn't realize how much they hurt profits
- **Marketing waste** - about $500K+ being spent inefficiently
- **Customer retention matters** - repeat customers are way more valuable

I learned that good data architecture and analysis can really change how a business performs. This was my first end-to-end analytics project and it was awesome to see how everything connects from raw data to business recommendations.

## 🧪 Testing

I added data quality tests to make sure everything is working right:

```sql
-- Run these tests
-- Execute tests/bronze_to_silver_tests.sql
```

The tests check for:
- Duplicate records
- Wrong data types
- Missing values
- Extra spaces in text
- Data relationships
- Math calculations

I learned that testing is super important in data projects!

## 🤝 Contributing

Want to help improve this project? That would be awesome!

1. Fork the repo
2. Create a branch for your changes (`git checkout -b feature/CoolIdea`)
3. Make your improvements
4. Push and create a pull request

I'm still learning, so any feedback is welcome!

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Portfolio Project by Asiimwe Mark Amooti**  
*Learning data engineering and business intelligence - this was my first big analytics project!*

## 🤝 Connect with me


<a href="https://twitter.com/MarkAsiimwe" target="blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/twitter.svg" alt="mark asiimwe" height="30" width="40" /></a>
<a href="https://www.linkedin.com/in/mark-asiimwe-0ab0611ab/" target="blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/linked-in-alt.svg" alt="mark asiimwe" height="30" width="40" /></a>
<a href="https://fb.com/asiimwe mark amooti" target="blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/facebook.svg" alt="asiimwe mark amooti" height="30" width="40" /></a>
<a href="https://www.instagram.com/asmark_twirlings/" target="blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/instagram.svg" alt="asiimwe mark" height="30" width="40" /></a>
<a href="https://www.youtube.com/channel/UCQ_kIWCzWff9SeLaerzjzwg" target="blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/youtube.svg" alt="mark_asiimwe" height="30" width="40" /></a>
</p>
