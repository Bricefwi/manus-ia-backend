# MANUS IA 2.0 Backend - Production Dockerfile
FROM python:3.11-slim

# Définir le répertoire de travail
WORKDIR /app

# Installer les dépendances système nécessaires
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copier les fichiers de dépendances
COPY requirements.txt .

# Installer les dépendances Python
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copier tout le code source
COPY . .

# Créer un utilisateur non-root pour la sécurité
RUN useradd -m -u 1000 manusia && \
    chown -R manusia:manusia /app

USER manusia

# Exposer le port (Railway utilise la variable $PORT)
EXPOSE 8000

# Variable d'environnement par défaut
ENV PORT=8000
ENV PYTHONUNBUFFERED=1

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:$PORT/health || exit 1

# Commande de démarrage
CMD uvicorn src.main:app --host 0.0.0.0 --port $PORT --workers 2
