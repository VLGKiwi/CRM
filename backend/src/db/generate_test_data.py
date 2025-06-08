import csv
import random
from datetime import datetime, timedelta
from faker import Faker
import uuid

fake = Faker('ru_RU')

# Количество записей для генерации
NUM_USERS = 100
NUM_CLIENTS = 5000
NUM_CONTACTS = 10000
NUM_PRODUCTS = 5000
NUM_DEALS = 10000
NUM_DEAL_PRODUCTS = 20000
NUM_ACTIVITIES = 30000
NUM_TASKS = 15000

def generate_roles():
    roles = [
        (1, 'admin', 'Администратор системы'),
        (2, 'manager', 'Менеджер'),
        (3, 'sales', 'Менеджер по продажам'),
        (4, 'support', 'Сотрудник поддержки'),
        (5, 'developer', 'Разработчик')
    ]

    with open('data/roles.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id', 'name', 'description'])
        writer.writerows(roles)

def generate_teams():
    teams = [
        (1, 'Продажи', 'Отдел продаж'),
        (2, 'Разработка', 'Отдел разработки'),
        (3, 'Поддержка', 'Отдел поддержки'),
        (4, 'Маркетинг', 'Отдел маркетинга')
    ]

    with open('data/teams.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id', 'name', 'description'])
        writer.writerows(teams)

def generate_users():
    users = []
    with open('data/users.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id', 'email', 'password_hash', 'first_name', 'last_name',
                        'role_id', 'team_id', 'is_active', 'two_factor_enabled'])

        for _ in range(NUM_USERS):
            user_id = str(uuid.uuid4())
            first_name = fake.first_name()
            last_name = fake.last_name()
            email = f"{first_name.lower()}.{last_name.lower()}@{fake.domain_name()}"

            user = [
                user_id,
                email,
                '$2a$10$XFE0DcAdWRMsUVEMPZxXU.K.6Oxe5kHww3lNMlYRKXqHNyPu4uGCa',  # хеш пароля
                first_name,
                last_name,
                random.randint(1, 5),  # role_id (1-5)
                random.randint(1, 4),  # team_id (1-4)
                random.random() < 0.9,  # 90% активных пользователей
                random.random() < 0.1   # 10% с двухфакторной аутентификацией
            ]
            users.append(user)
            writer.writerow(user)
    return [u[0] for u in users]  # Возвращаем список ID пользователей

def generate_clients(user_ids):
    clients = []
    industries = ['IT', 'Manufacturing', 'Healthcare', 'Finance', 'Education',
                 'Construction', 'Retail', 'Energy', 'Logistics', 'Consulting']
    statuses = ['Active', 'Inactive', 'Lead', 'Prospect']

    with open('data/clients.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id', 'company_name', 'industry', 'website', 'phone', 'address',
                        'city', 'country', 'postal_code', 'assigned_to', 'status'])

        for i in range(1, NUM_CLIENTS + 1):
            company_name = fake.company()
            domain = fake.domain_name()
            client = [
                i,  # id
                company_name,
                random.choice(industries),
                f"www.{domain}",
                fake.phone_number(),
                fake.street_address(),
                fake.city(),
                fake.country(),
                fake.postcode(),
                random.choice(user_ids),  # assigned_to
                random.choice(statuses)
            ]
            clients.append(client)
            writer.writerow(client)
    return [c[0] for c in clients]  # Возвращаем список ID клиентов

def generate_contacts(client_ids):
    positions = ['CEO', 'CTO', 'CFO', 'Sales Manager', 'Project Manager',
                'Technical Lead', 'HR Director', 'Marketing Manager']

    contacts = []
    with open('data/contacts.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id', 'client_id', 'first_name', 'last_name', 'position',
                        'email', 'phone', 'mobile', 'is_primary'])

        for i in range(1, NUM_CONTACTS + 1):
            first_name = fake.first_name()
            last_name = fake.last_name()
            contact = [
                i,  # id
                random.choice(client_ids),  # client_id
                first_name,
                last_name,
                random.choice(positions),
                f"{first_name.lower()}.{last_name.lower()}@{fake.domain_name()}",
                fake.phone_number(),
                fake.phone_number(),
                random.random() < 0.2  # 20% основных контактов
            ]
            contacts.append(contact)
            writer.writerow(contact)
    return [c[0] for c in contacts]  # Возвращаем список ID контактов

def generate_products():
    products = []
    with open('data/products.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id', 'name', 'description', 'price', 'currency', 'is_active'])

        currencies = ['USD', 'EUR', 'RUB']
        for i in range(1, NUM_PRODUCTS + 1):
            product = [
                i,  # id
                fake.catch_phrase(),
                fake.text(max_nb_chars=200),
                round(random.uniform(100, 10000), 2),
                random.choice(currencies),
                random.random() < 0.9  # 90% активных продуктов
            ]
            products.append(product)
            writer.writerow(product)
    return [p[0] for p in products]  # Возвращаем список ID продуктов

def generate_deals(client_ids, user_ids):
    deals = []
    stages = ['lead', 'proposal', 'negotiation', 'won', 'lost']
    currencies = ['USD', 'EUR', 'RUB']

    with open('data/deals.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id', 'client_id', 'title', 'description', 'amount', 'currency',
                        'stage', 'probability', 'expected_close_date', 'actual_close_date',
                        'created_by', 'assigned_to'])

        for i in range(1, NUM_DEALS + 1):
            stage = random.choice(stages)
            created_at = fake.date_time_between(start_date='-2y', end_date='now')
            expected_close_date = fake.date_between(start_date='today', end_date='+6m')
            actual_close_date = None if stage not in ['won', 'lost'] else \
                               fake.date_between(start_date=created_at.date(), end_date='today')

            deal = [
                i,  # id
                random.choice(client_ids),  # client_id
                fake.catch_phrase(),
                fake.text(max_nb_chars=200),
                round(random.uniform(1000, 1000000), 2),
                random.choice(currencies),
                stage,
                random.randint(1, 100),
                expected_close_date,
                actual_close_date,
                random.choice(user_ids),  # created_by
                random.choice(user_ids)   # assigned_to
            ]
            deals.append(deal)
            writer.writerow(deal)
    return [d[0] for d in deals]  # Возвращаем список ID сделок

def generate_deal_products(deal_ids, product_ids):
    with open('data/deal_products.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id', 'deal_id', 'product_id', 'quantity', 'price',
                        'discount_percentage', 'total_amount'])

        for i in range(1, NUM_DEAL_PRODUCTS + 1):
            quantity = random.randint(1, 100)
            price = round(random.uniform(100, 10000), 2)
            discount = round(random.uniform(0, 30), 2)
            total = round(quantity * price * (1 - discount/100), 2)

            writer.writerow([
                i,  # id
                random.choice(deal_ids),     # deal_id
                random.choice(product_ids),  # product_id
                quantity,
                price,
                discount,
                total
            ])

def generate_activities(user_ids, client_ids, contact_ids, deal_ids):
    activity_types = ['Call', 'Meeting', 'Email', 'Task', 'Note']

    with open('data/activities.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id', 'type', 'subject', 'description', 'start_time', 'end_time',
                        'location', 'result', 'created_by', 'client_id', 'contact_id', 'deal_id'])

        for i in range(1, NUM_ACTIVITIES + 1):
            start_time = fake.date_time_between(start_date='-6m', end_date='now')
            end_time = start_time + timedelta(minutes=random.randint(15, 180))

            writer.writerow([
                i,  # id
                random.choice(activity_types),
                fake.sentence(nb_words=4),
                fake.text(max_nb_chars=200),
                start_time.isoformat(),
                end_time.isoformat(),
                fake.city() if random.random() < 0.3 else '',  # 30% имеют локацию
                fake.text(max_nb_chars=100) if random.random() < 0.7 else '',  # 70% имеют результат
                random.choice(user_ids),  # created_by
                random.choice(client_ids) if random.random() < 0.8 else None,
                random.choice(contact_ids) if random.random() < 0.6 else None,
                random.choice(deal_ids) if random.random() < 0.5 else None
            ])

def generate_tasks(user_ids):
    statuses = ['Not Started', 'In Progress', 'Review', 'Completed', 'Delayed']
    priorities = [1, 2, 3, 4, 5]
    tags = ['urgent', 'bug', 'feature', 'improvement', 'documentation', 'testing']

    with open('data/tasks.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id', 'title', 'description', 'due_date', 'priority', 'status',
                        'buyer_id', 'project_manager_id', 'team_lead_id',
                        'integrator_id', 'developer_id', 'created_by', 'task_number',
                        'final_link', 'tags', 'estimated_hours', 'actual_hours'])

        for i in range(1, NUM_TASKS + 1):
            task_tags = random.sample(tags, random.randint(1, 3))
            writer.writerow([
                i,  # id
                fake.sentence(nb_words=6),
                fake.text(max_nb_chars=200),
                fake.date_time_between(start_date='now', end_date='+30d').isoformat(),
                random.choice(priorities),
                random.choice(statuses),
                random.choice(user_ids),  # buyer_id
                random.choice(user_ids),  # project_manager_id
                random.choice(user_ids),  # team_lead_id
                random.choice(user_ids),  # integrator_id
                random.choice(user_ids),  # developer_id
                random.choice(user_ids),  # created_by
                f'TASK-{i:05d}',
                fake.url(),
                '{' + ','.join(f'"{tag}"' for tag in task_tags) + '}',
                round(random.uniform(1, 40), 1),  # estimated_hours
                round(random.uniform(1, 50), 1)   # actual_hours
            ])

if __name__ == '__main__':
    # Создаем директорию для данных если её нет
    import os
    os.makedirs('data', exist_ok=True)

    print("Generating test data...")

    print("Generating roles...")
    generate_roles()

    print("Generating teams...")
    generate_teams()

    print("Generating users...")
    user_ids = generate_users()

    print("Generating clients...")
    client_ids = generate_clients(user_ids)

    print("Generating contacts...")
    contact_ids = generate_contacts(client_ids)

    print("Generating products...")
    product_ids = generate_products()

    print("Generating deals...")
    deal_ids = generate_deals(client_ids, user_ids)

    print("Generating deal products...")
    generate_deal_products(deal_ids, product_ids)

    print("Generating tasks...")
    generate_tasks(user_ids)

    print("Generating activities...")
    generate_activities(user_ids, client_ids, contact_ids, deal_ids)

    print("All data generated successfully!")
