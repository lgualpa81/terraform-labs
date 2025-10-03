# Stage 1: Dependencies
FROM python:3.11-slim AS deps
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Production
FROM python:3.11-slim AS runner
WORKDIR /app
RUN addgroup --system --gid 1001 flask && \
  adduser --system --uid 1001 --gid 1001 flask
COPY --from=deps /usr/local /usr/local
COPY --chown=flask:flask . .

USER flask
EXPOSE 80
ENV PATH=/usr/local/bin:$PATH

CMD ["gunicorn", "--bind", "0.0.0.0:80", "--workers",  "2", "--threads", "4", "--log-level", "debug", "app:app"]

