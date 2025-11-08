# 🛍️ Retail Sales & Customer Insights Dashboard (Power BI + Python + SQL)

This project presents a comprehensive **Retail Sales & Customer Insights Dashboard** built using **Power BI**, **Python**, and **SQL Server**.
It analyzes multi-year retail sales data (2019–2025) to uncover insights into **revenue growth, profitability, and customer behavior**, enabling businesses to make informed, data-driven decisions.

---

## 🚀 Objective

To analyze large-scale retail data and uncover insights into **sales performance, product profitability, and customer retention trends**.
The project focuses on data cleaning, validation, transformation, and visualization to evaluate sales performance, product profitability, and customer retention trends.
---

## 📁 Dataset Summary

The dataset simulates real-world retail transactions and includes over **50,000 records** with intentional data-quality issues (missing values, duplicates, mixed data types) for practicing cleaning and transformation.

##🧹 Data Cleaning & Validation

Performed using Python (Pandas) and SQL Server to ensure data accuracy and reliability before modeling.
Key steps included:

Removing duplicates and handling missing values
Validating numeric ranges (price, quantity, discount)
Standardizing date formats and categorical fields
Calculating derived metrics such as NetAmount and Gross Profit
Creating validated dimension tables for Date, Customer, Product, and Store

**Key columns include:**

* `SaleID`, `CustomerID`, `ProductID`, `StoreID`
* `Date`, `QuantitySold`, `UnitPrice`, `Discount`, `PaymentMode`
* `Region`, `Category`, `SubCategory`, `Gender`, `AgeGroup`
* `CostPrice`, `NetAmount`

---

## 📌 Key KPIs and Visualizations

| KPI                                         | Description                                       | Visualization Type   |
| ------------------------------------------- | ------------------------------------------------- | -------------------- |
| 💰 **Total Revenue (CAD)**                  | Total revenue generated across all stores         | KPI Card             |
| 🛒 **Total Orders**                         | Count of unique sales transactions                | KPI Card             |
| 💵 **Average Order Value (AOV)**            | Average revenue per order                         | KPI Card             |
| 📈 **Monthly Revenue Trend + MoM Growth %** | Monthly revenue with month-over-month growth rate | Line Chart           |
| 📊 **YoY Sales Growth %**                   | Year-over-year comparison of total sales          | Column + Target Line |
| 💹 **Gross Profit (CAD)**                   | Profit after cost per sale                        | KPI Card             |
| 💼 **Gross Margin %**                       | Profitability ratio across products               | KPI Card             |
| 🧾 **Discount Impact % of Revenue**         | Discount percentage relative to total revenue     | Donut Chart          |
| 🏷️ **Sales by Category**                   | Revenue distribution across product categories    | Treemap / Bar Chart  |
| 📦 **Profit by Category**                   | Profitability by product type                     | Stacked Column Chart |
| 👥 **Total Customers**                      | Distinct count of customers                       | KPI Card             |
| 🔁 **Repeat Customer %**                    | Ratio of repeat buyers to total buyers            | Donut Chart          |
| 🎯 **Customer Retention Rate (YoY)**        | Retention trend year-over-year                    | Line Chart           |
| 🧍‍♂️ **Customer Analysis by Age Group**    | Sales contribution by customer demographics       | Donut / Bar Chart    |
| 🛍️ **Top 5 Products by Revenue**           | Best-performing products by sales                 | Horizontal Bar Chart |

---

## 🧮 Tools & Technologies

* **SQL Server** → Data storage, query optimization, and validation
* **Python (Pandas, Matplotlib)** → Data cleaning, preprocessing, and visualization checks
* **Power BI** → Data modeling, DAX measures, dashboard creation
* **DAX (Data Analysis Expressions)** → Custom KPI calculations
* **Power Query** → ETL and data transformation
* **Excel** → Initial data inspection and formatting

---

## 🧠 Key Insights

* **$56M+ Total Revenue** generated across 6 categories between 2019–2025
* **Beauty & Electronics** emerged as top-performing product segments
* **Gross Margin of 84%**, indicating strong pricing efficiency
* **Average Basket Size:** ~4.9 items/order
* **Customer Retention:** 51% — moderate loyalty with room for engagement improvement

---

## 📸 Dashboard Preview


<img width="1126" height="637" alt="image" src="https://github.com/user-attachments/assets/e7203d02-9c1f-45d0-b4e0-28e5e174a9e5" />
<img width="1132" height="640" alt="image" src="https://github.com/user-attachments/assets/e37203ae-f034-4bf1-a477-73f5067a4e4e" />



---

## ✅ Conclusion

The **Retail Sales & Customer Insights Dashboard** provides a holistic view of business performance — integrating **SQL**, **Python**, and **Power BI** for a complete data pipeline.
It demonstrates the ability to handle real-world data issues, design robust KPIs, and build visually compelling dashboards for decision-making.

---


---

Would you like me to also create a **shorter LinkedIn-friendly version** (3–4 sections) of this same write-up — formatted for your “Project” section text box?


