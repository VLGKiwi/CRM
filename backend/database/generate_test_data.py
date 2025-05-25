import csv
import random
from datetime import datetime, timedelta
from faker import Faker
import uuid

fake = Faker('ru_RU')

# Количество записей для генерации
NUM_CLIENTS = 15000
NUM_USERS = 1000
NUM_DEALS = 20000
NUM_TASKS = 30000
NUM_CONTACTS = 25000
NUM_PRODUCTS = 100
NUM_DEAL_PRODUCTS = 40000
NUM_ACTIVITIES = 50000

# Функция для генерации UUID на основе имени (версия 5)
def generate_deterministic_uuid(email):
    # Используем UUID версии 5 (SHA-1) с пространством имен DNS
    # Это создаст одинаковый UUID для одинакового email
    return str(uuid.uuid5(uuid.NAMESPACE_DNS, email))

# Функция для генерации UUID на основе времени (версия 1)
def generate_time_based_uuid():
    # Используем UUID версии 1 (на основе времени и MAC-адреса)
    return str(uuid.uuid1())

def generate_roles():
    roles = [
        ('Sales Manager', 'Manages sales team and deals'),
        ('Account Executive', 'Handles client accounts and sales'),
        ('Team Lead', 'Leads development team'),
        ('Developer', 'Develops software solutions'),
        ('Project Manager', 'Manages project execution')
    ]

    with open('data/roles.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['name', 'description'])
        writer.writerows(roles)

def generate_teams():
    teams = [
        ('Sales Team', 'Main sales team'),
        ('Development Team', 'Software development team'),
        ('Integration Team', 'System integration team'),
        ('Support Team', 'Customer support team')
    ]

    with open('data/teams.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['name', 'description'])
        writer.writerows(teams)

def generate_users():
    with open('data/users.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id', 'email', 'password_hash', 'first_name', 'last_name', 'role_id', 'team_id', 'is_active'])

        for _ in range(NUM_USERS):
            first_name = fake.first_name()
            last_name = fake.last_name()
            email = f"{first_name.lower()}.{last_name.lower()}@company.com"

            # Вариант 1: Случайный UUID (версия 4) - текущий метод
            user_id = str(uuid.uuid4())

            # Вариант 2: Детерминированный UUID на основе email
            # user_id = generate_deterministic_uuid(email)

            # Вариант 3: UUID на основе времени
            # user_id = generate_time_based_uuid()

            writer.writerow([
                user_id,
                email,
                'HASHED_PASSWORD_PLACEHOLDER',  # В реальности здесь должен быть хеш пароля
                first_name,
                last_name,
                random.randint(1, 5),  # role_id
                random.randint(1, 4),  # team_id
                True
            ])

def generate_clients():
    with open('data/clients.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['company_name', 'industry', 'website', 'phone', 'address', 'city', 'country', 'postal_code', 'assigned_to', 'status'])

        industries = ['IT', 'Retail', 'Manufacturing', 'Healthcare', 'Finance', 'Education', 'Construction']
        statuses = ['Active', 'Inactive', 'Lead', 'Prospect', 'Customer']

        # Читаем существующие ID пользователей
        user_ids = [row[0] for row in csv.reader(open('data/users.csv', encoding='utf-8'))][1:]

        for _ in range(NUM_CLIENTS):
            writer.writerow([
                fake.company(),
                random.choice(industries),
                fake.domain_name(),
                fake.phone_number(),
                fake.street_address(),
                fake.city(),
                fake.country(),
                fake.postcode(),
                random.choice(user_ids),
                random.choice(statuses)
            ])

def generate_contacts():
    with open('data/contacts.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['client_id', 'first_name', 'last_name', 'position', 'email', 'phone', 'mobile', 'is_primary'])

        positions = ['CEO', 'CTO', 'CFO', 'Sales Director', 'IT Manager', 'Procurement Manager']

        for _ in range(NUM_CONTACTS):
            client_id = random.randint(1, NUM_CLIENTS)
            first_name = fake.first_name()
            last_name = fake.last_name()
            writer.writerow([
                client_id,
                first_name,
                last_name,
                random.choice(positions),
                fake.email(),
                fake.phone_number(),
                fake.phone_number(),
                random.random() < 0.2  # 20% шанс быть основным контактом
            ])

def generate_products():
    with open('data/products.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['name', 'description', 'price', 'currency', 'is_active'])

        for _ in range(NUM_PRODUCTS):
            writer.writerow([
                fake.catch_phrase(),
                fake.text(max_nb_chars=200),
                round(random.uniform(100, 10000), 2),
                'USD',
                random.random() < 0.9  # 90% продуктов активны
            ])

def generate_deals():
    with open('data/deals.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['client_id', 'title', 'description', 'amount', 'currency', 'stage', 'probability',
                        'expected_close_date', 'actual_close_date', 'created_by', 'assigned_to'])

        stages = ['Initial Contact', 'Qualification', 'Proposal', 'Negotiation', 'Closed Won', 'Closed Lost']
        user_ids = [row[0] for row in csv.reader(open('data/users.csv', encoding='utf-8'))][1:]

        for _ in range(NUM_DEALS):
            stage = random.choice(stages)
            created_at = fake.date_time_between(start_date='-2y', end_date='now')
            expected_close_date = fake.date_between(start_date='today', end_date='+6m')
            actual_close_date = None if stage not in ['Closed Won', 'Closed Lost'] else \
                               fake.date_between(start_date=created_at.date(), end_date='today')

            writer.writerow([
                random.randint(1, NUM_CLIENTS),
                fake.catch_phrase(),
                fake.text(max_nb_chars=200),
                round(random.uniform(1000, 1000000), 2),
                'USD',
                stage,
                random.randint(1, 100),
                expected_close_date,
                actual_close_date,
                random.choice(user_ids),
                random.choice(user_ids)
            ])

def generate_deal_products():
    with open('data/deal_products.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['deal_id', 'product_id', 'quantity', 'price', 'discount_percentage', 'total_amount'])

        for _ in range(NUM_DEAL_PRODUCTS):
            quantity = random.randint(1, 100)
            price = round(random.uniform(100, 10000), 2)
            discount = round(random.uniform(0, 30), 2)
            total = round(quantity * price * (1 - discount/100), 2)

            writer.writerow([
                random.randint(1, NUM_DEALS),
                random.randint(1, NUM_PRODUCTS),
                quantity,
                price,
                discount,
                total
            ])

def generate_tasks():
    with open('data/tasks.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['title', 'description', 'due_date', 'priority', 'status', 'buyer_id',
                        'project_manager_id', 'team_lead_id', 'integrator_id', 'developer_id',
                        'created_by', 'task_number', 'final_link', 'tags', 'estimated_hours', 'actual_hours'])

        statuses = ['Not Started', 'In Progress', 'Review', 'Completed', 'Delayed']
        user_ids = [row[0] for row in csv.reader(open('data/users.csv', encoding='utf-8'))][1:]
        tags = ['urgent', 'bug', 'feature', 'improvement', 'documentation', 'testing']

        for i in range(NUM_TASKS):
            task_tags = random.sample(tags, random.randint(1, 3))
            writer.writerow([
                fake.sentence(nb_words=6),
                fake.text(max_nb_chars=200),
                fake.date_time_between(start_date='now', end_date='+30d').isoformat(),
                random.randint(1, 5),
                random.choice(statuses),
                random.choice(user_ids),
                random.choice(user_ids),
                random.choice(user_ids),
                random.choice(user_ids),
                random.choice(user_ids),
                random.choice(user_ids),
                f'TASK-{i+1:05d}',
                fake.url(),
                '{' + ','.join(f'"{tag}"' for tag in task_tags) + '}',
                round(random.uniform(1, 40), 1),
                round(random.uniform(1, 50), 1)
            ])

def generate_activities():
    with open('data/activities.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['type', 'subject', 'description', 'start_time', 'end_time', 'location',
                        'result', 'created_by', 'client_id', 'contact_id', 'deal_id'])

        activity_types = ['Call', 'Meeting', 'Email', 'Task', 'Note']
        user_ids = [row[0] for row in csv.reader(open('data/users.csv', encoding='utf-8'))][1:]

        for _ in range(NUM_ACTIVITIES):
            start_time = fake.date_time_between(start_date='-6m', end_date='now')
            end_time = start_time + timedelta(minutes=random.randint(15, 180))

            writer.writerow([
                random.choice(activity_types),
                fake.sentence(nb_words=4),
                fake.text(max_nb_chars=200),
                start_time.isoformat(),
                end_time.isoformat(),
                fake.city() if random.random() < 0.3 else '',
                fake.text(max_nb_chars=100) if random.random() < 0.7 else '',
                random.choice(user_ids),
                random.randint(1, NUM_CLIENTS) if random.random() < 0.8 else None,
                random.randint(1, NUM_CONTACTS) if random.random() < 0.6 else None,
                random.randint(1, NUM_DEALS) if random.random() < 0.5 else None
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
    generate_users()

    print("Generating clients...")
    generate_clients()

    print("Generating contacts...")
    generate_contacts()

    print("Generating products...")
    generate_products()

    print("Generating deals...")
    generate_deals()

    print("Generating deal products...")
    generate_deal_products()

    print("Generating tasks...")
    generate_tasks()

    print("Generating activities...")
    generate_activities()

    print("All data generated successfully!")
