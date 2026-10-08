"""
Supply Chain Intelligence & Operations Analytics Platform
Unit Testing & Referential Integrity Suite
Author: B.Tech Computer Engineering Final Year Project
"""

import unittest
import os
import pandas as pd
import numpy as np

class TestSupplyChainDataIntegrity(unittest.TestCase):
    
    @classmethod
    def setUpClass(cls):
        cls.data_dir = os.path.join("data", "processed")
        cls.suppliers = pd.read_csv(os.path.join(cls.data_dir, "dim_suppliers.csv"))
        cls.warehouses = pd.read_csv(os.path.join(cls.data_dir, "dim_warehouses.csv"))
        cls.categories = pd.read_csv(os.path.join(cls.data_dir, "dim_categories.csv"))
        cls.products = pd.read_csv(os.path.join(cls.data_dir, "dim_products.csv"))
        cls.dates = pd.read_csv(os.path.join(cls.data_dir, "dim_date.csv"))
        cls.orders = pd.read_csv(os.path.join(cls.data_dir, "fact_supply_chain_orders.csv"))
        cls.master = pd.read_csv(os.path.join(cls.data_dir, "supply_chain_master_clean.csv"))

    def test_table_row_counts(self):
        """Verify all dimension and fact table row counts match expected domain grain."""
        self.assertEqual(len(self.suppliers), 5, "dim_suppliers should have 5 rows")
        self.assertEqual(len(self.warehouses), 5, "dim_warehouses should have 5 rows")
        self.assertEqual(len(self.categories), 4, "dim_categories should have 4 rows")
        self.assertEqual(len(self.products), 40, "dim_products should have 40 rows")
        self.assertGreaterEqual(len(self.dates), 730, "dim_date should have at least 2 full years of dates")
        self.assertEqual(len(self.orders), 15000, "fact_supply_chain_orders should have 15,000 rows")
        self.assertEqual(len(self.master), 15000, "supply_chain_master_clean should have 15,000 rows")

    def test_referential_integrity(self):
        """Verify that all foreign keys in fact table exist in their respective dimension tables."""
        # Supplier FK
        valid_suppliers = set(self.suppliers['supplier_id'])
        fact_suppliers = set(self.orders['supplier_id'])
        self.assertTrue(fact_suppliers.issubset(valid_suppliers), "Orphaned supplier_id detected in fact table")

        # Warehouse FK
        valid_warehouses = set(self.warehouses['warehouse_id'])
        fact_warehouses = set(self.orders['warehouse_id'])
        self.assertTrue(fact_warehouses.issubset(valid_warehouses), "Orphaned warehouse_id detected in fact table")

        # Product FK
        valid_products = set(self.products['product_id'])
        fact_products = set(self.orders['product_id'])
        self.assertTrue(fact_products.issubset(valid_products), "Orphaned product_id detected in fact table")

        # Date FK
        valid_dates = set(self.dates['date_key'])
        fact_order_dates = set(self.orders['order_date'])
        fact_deliv_dates = set(self.orders['delivery_date'])
        self.assertTrue(fact_order_dates.issubset(valid_dates), "Orphaned order_date detected in fact table")
        self.assertTrue(fact_deliv_dates.issubset(valid_dates), "Orphaned delivery_date detected in fact table")

    def test_date_chronology(self):
        """Verify delivery date is always greater than or equal to order date."""
        order_dates = pd.to_datetime(self.orders['order_date'])
        deliv_dates = pd.to_datetime(self.orders['delivery_date'])
        diffs = (deliv_dates - order_dates).dt.days
        self.assertTrue((diffs >= 0).all(), "Delivery date cannot precede Order date")
        self.assertTrue((diffs == self.orders['shipping_time_days']).all(), "Shipping_Time_Days must match date difference")

    def test_no_negative_numeric_values(self):
        """Verify non-negative domain constraints on quantities, prices, and stock."""
        self.assertTrue((self.orders['units_sold'] >= 0).all(), "Units sold cannot be negative")
        self.assertTrue((self.orders['stock_quantity'] >= 0).all(), "Stock quantity cannot be negative")
        self.assertTrue((self.orders['reorder_level'] >= 0).all(), "Reorder level cannot be negative")
        self.assertTrue((self.orders['unit_purchase_cost'] > 0).all(), "Purchase cost must be strictly positive")
        self.assertTrue((self.orders['unit_selling_price'] > 0).all(), "Selling price must be strictly positive")
        self.assertTrue((self.orders['logistics_cost'] >= 0).all(), "Logistics cost cannot be negative")

    def test_financial_calculations(self):
        """Verify mathematical integrity of revenue, COGS, and profit fields."""
        expected_revenue = self.orders['units_sold'] * self.orders['unit_selling_price']
        expected_cogs = self.orders['units_sold'] * self.orders['unit_purchase_cost']
        expected_gross_profit = expected_revenue - expected_cogs
        expected_net_profit = expected_gross_profit - self.orders['logistics_cost']

        np.testing.assert_allclose(self.orders['total_revenue'], expected_revenue, rtol=1e-5, err_msg="Total revenue calculation mismatch")
        np.testing.assert_allclose(self.orders['total_cogs'], expected_cogs, rtol=1e-5, err_msg="Total COGS calculation mismatch")
        np.testing.assert_allclose(self.orders['gross_profit'], expected_gross_profit, rtol=1e-5, err_msg="Gross profit calculation mismatch")
        np.testing.assert_allclose(self.orders['net_profit'], expected_net_profit, rtol=1e-5, err_msg="Net profit calculation mismatch")

    def test_status_classifications(self):
        """Verify binary and categorical status logic."""
        # On-Time flag
        expected_on_time = (self.orders['shipping_time_days'] <= 5).astype(int)
        self.assertTrue((self.orders['is_on_time'] == expected_on_time).all(), "is_on_time logic mismatch")

        # Stockout flag
        expected_stockout = (self.orders['stock_quantity'] == 0).astype(int)
        self.assertTrue((self.orders['stockout_flag'] == expected_stockout).all(), "stockout_flag logic mismatch")

        # Understock flag
        expected_understock = (self.orders['stock_quantity'] < self.orders['reorder_level']).astype(int)
        self.assertTrue((self.orders['understock_flag'] == expected_understock).all(), "understock_flag logic mismatch")

if __name__ == '__main__':
    unittest.main()
