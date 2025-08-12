#!/bin/bash

echo "🚀 Setting up College Review API with FastAPI + PostgreSQL + Docker"

# Create app directory if it doesn't exist
mkdir -p app

# Create alembic directory structure
echo "📁 Setting up database migrations..."
mkdir -p alembic/versions

# Create alembic env.py
cat > alembic/env.py << 'EOF'
from logging.config import fileConfig
from sqlalchemy import engine_from_config
from sqlalchemy import pool
from alembic import context
import os
import sys

# Add the app directory to the Python path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'app'))

# Import your models
from models import Base

# this is the Alembic Config object, which provides
# access to the values within the .ini file in use.
config = context.config

# Override sqlalchemy.url with environment variable if available
database_url = os.getenv("DATABASE_URL", "postgresql://postgres:postgres@localhost:5432/udaan")
config.set_main_option("sqlalchemy.url", database_url)

# Interpret the config file for Python logging.
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# add your model's MetaData object here
target_metadata = Base.metadata

def run_migrations_offline() -> None:
    """Run migrations in 'offline' mode."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online() -> None:
    """Run migrations in 'online' mode."""
    connectable = engine_from_config(
        config.get_section(config.config_ini_section),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection, target_metadata=target_metadata
        )

        with context.begin_transaction():
            context.run_migrations()

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
EOF

# Create alembic script.py.mako
cat > alembic/script.py.mako << 'EOF'
"""${message}

Revision ID: ${up_revision}
Revises: ${down_revision | comma,n}
Create Date: ${create_date}

"""
from alembic import op
import sqlalchemy as sa
${imports if imports else ""}

# revision identifiers, used by Alembic.
revision = ${repr(up_revision)}
down_revision = ${repr(down_revision)}
branch_labels = ${repr(branch_labels)}
depends_on = ${repr(depends_on)}

def upgrade() -> None:
    ${upgrades if upgrades else "pass"}

def downgrade() -> None:
    ${downgrades if downgrades else "pass"}
EOF

# Create .env file template
cat > .env << 'EOF'
DATABASE_URL=postgresql://postgres:password@localhost:5432/udaan
SECRET_KEY=your-very-secure-secret-key-change-this-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual environments
venv/
env/
ENV/

# Database
*.db
*.sqlite3

# Environment variables
.env

# Docker
docker-compose.override.yml

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
EOF

echo "✅ Project structure created!"
echo ""
echo "🐳 Starting Docker containers..."

# Build and start containers
docker-compose up -d --build

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 10

# Initialize database with alembic
echo "🔄 Running database migrations..."
docker-compose exec api alembic revision --autogenerate -m "Initial migration"
docker-compose exec api alembic upgrade head

echo ""
echo "🎉 Setup complete! Your College Review API is running!"
echo ""
echo "📋 Available endpoints:"
echo "   • Health check: http://localhost:8000/health"
echo "   • API docs: http://localhost:8000/docs"
echo "   • Register user: POST http://localhost:8000/auth/register"
echo "   • Login: POST http://localhost:8000/auth/login"
echo "   • Get colleges: GET http://localhost:8000/colleges"
echo "   • Create college: POST http://localhost:8000/colleges"
echo "   • Get reviews: GET http://localhost:8000/colleges/{id}/reviews"
echo "   • Create review: POST http://localhost:8000/reviews"
echo ""
echo "🔧 Useful commands:"
echo "   • View logs: docker-compose logs -f"
echo "   • Stop services: docker-compose down"
echo "   • Restart services: docker-compose restart"
echo "   • Database shell: docker-compose exec db psql -U postgres -d udaan"
echo ""
echo "📱 Test the API with curl or visit http://localhost:8000/docs for interactive documentation!"