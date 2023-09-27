import pandas as pd
import numpy as np
import random

# Генерация данных о продуктах
def generate_products(n=100):
    products = pd.DataFrame({
        'product_id': range(1, n + 1),
        'product_name': ['Product_' + str(i) for i in range(1, n + 1)],
        'category': np.random.choice(['Electronics', 'Clothing', 'Groceries', 'Toys'], n),
        'price': np.round(np.random.uniform(5.0, 500.0, n), 2)
    })
    return products

# Генерация данных о продажах
def generate_sales(products, m=1000):
    sales = pd.DataFrame({
        'transaction_id': range(1, m + 1),
        'product_id': np.random.choice(products['product_id'], m),
        'quantity': np.random.randint(1, 5, m),
        'discount': np.round(np.random.uniform(0.0, 0.5, m), 2),
        'shipping_cost': np.round(np.random.uniform(5.0, 50.0, m), 2),
        'return_status': np.random.choice([True, False], m, p=[0.1, 0.9])
    })
    
    # Introducing some missing values
    for _ in range(50):
        sales.loc[np.random.choice(m), 'discount'] = np.nan

    return sales

# Генерация данных о логах пользователей
def generate_user_logs(l=5000):
    logs = pd.DataFrame({
        'log_id': range(1, l + 1),
        'user_id': np.random.randint(1, 1000, l),
        'browser': np.random.choice(['Chrome', 'Firefox', 'Safari', 'Edge'], l),
        'ip_address': [f'192.168.{random.randint(0, 255)}.{random.randint(0, 255)}' for _ in range(l)],
        'session_duration': np.random.randint(1, 3600, l)  # in seconds
    })
    
    # Introducing some erroneous data
    for _ in range(30):
        logs.loc[np.random.choice(l), 'browser'] = 'UnknownBrowser'
    
    return logs

if __name__ == "__main__":
    products = generate_products()
    sales = generate_sales(products)
    user_logs = generate_user_logs()

    products.to_csv('product_info.csv', index=False)
    sales.to_csv('sales.csv', index=False)
    user_logs.to_csv('user_logs.csv', index=False)
