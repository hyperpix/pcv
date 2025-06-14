# Multi-stage build for TinyTeX
FROM python:3.11-slim as tinytex-builder

# Install dependencies for TinyTeX
RUN apt-get update && apt-get install -y \
    wget \
    perl \
    fontconfig \
    && rm -rf /var/lib/apt/lists/*

# Install TinyTeX
RUN wget -qO- "https://yihui.org/tinytex/install-bin-unix.sh" | sh

# Add TinyTeX to PATH
ENV PATH="/root/.TinyTeX/bin/x86_64-linux:${PATH}"

# Install essential LaTeX packages
RUN tlmgr install \
    collection-fontsrecommended \
    collection-latexextra \
    enumitem \
    titlesec \
    xcolor \
    geometry \
    inputenc \
    fontenc \
    babel \
    hyperref \
    graphicx \
    amsmath \
    amsfonts \
    amssymb

# Final stage
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PORT=8080

# Copy TinyTeX from builder stage
COPY --from=tinytex-builder /root/.TinyTeX /root/.TinyTeX

# Add TinyTeX to PATH
ENV PATH="/root/.TinyTeX/bin/x86_64-linux:${PATH}"

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    perl \
    fontconfig \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p uploads output temp_sessions cv_data user_data job_desc_cache

# Set permissions
RUN chmod -R 755 /app

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Run the application
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 app:app 