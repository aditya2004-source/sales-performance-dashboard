"""Key charts from the cleaned data (same numbers as the SQL results)."""
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as mt

df = pd.read_csv("data/superstore_clean.csv", parse_dates=["order_date"])
plt.rcParams.update({"figure.figsize": (8, 4.5), "axes.spines.top": False, "axes.spines.right": False})
k = mt.FuncFormatter(lambda x, _: f"${x/1000:,.0f}K")

# 1. Monthly sales trend
m = df.set_index("order_date").resample("MS")["sales"].sum()
ax = m.plot(color="#2F6DB5", lw=2); ax.yaxis.set_major_formatter(k)
ax.set_title("Monthly Sales Trend (2019-2022)"); ax.set_xlabel("")
plt.tight_layout(); plt.savefig("images/01_monthly_sales.png", dpi=120); plt.close()

# 2. Profit by sub-category
s = df.groupby("sub_category")["profit"].sum().sort_values()
ax = s.plot(kind="barh", color=["#D9534F" if v < 0 else "#2F6DB5" for v in s], figsize=(8, 6))
ax.xaxis.set_major_formatter(k); ax.set_title("Profit by Sub-Category"); ax.set_ylabel("")
plt.tight_layout(); plt.savefig("images/02_profit_by_subcategory.png", dpi=120); plt.close()

# 3. Discount vs profit margin
bands = pd.cut(df["discount"], [-0.01, 0, 0.1, 0.2, 0.3, 0.5, 1],
               labels=["0%", "1-10%", "11-20%", "21-30%", "31-50%", ">50%"])
g = df.groupby(bands, observed=True).agg(sales=("sales", "sum"), profit=("profit", "sum"))
margin = 100 * g["profit"] / g["sales"]
ax = margin.plot(kind="bar", rot=0, color=["#D9534F" if v < 0 else "#2F6DB5" for v in margin])
ax.axhline(0, color="black", lw=0.8); ax.set_title("Profit Margin by Discount Level")
ax.set_ylabel("Profit margin (%)"); ax.set_xlabel("Discount")
for p in ax.patches:
    h = p.get_height()
    ax.annotate(f"{h:.0f}%", (p.get_x() + p.get_width() / 2, h), ha="center", va="bottom" if h >= 0 else "top")
plt.tight_layout(); plt.savefig("images/03_discount_vs_margin.png", dpi=120); plt.close()

# 4. Region sales vs profit
r = df.groupby("region")[["sales", "profit"]].sum().sort_values("sales", ascending=False)
ax = r.plot(kind="bar", rot=0, color=["#2F6DB5", "#5CB85C"]); ax.yaxis.set_major_formatter(k)
ax.set_title("Sales and Profit by Region"); ax.set_xlabel("")
plt.tight_layout(); plt.savefig("images/04_region_sales_profit.png", dpi=120); plt.close()
print("charts saved")
