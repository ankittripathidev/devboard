# DevBoard — Fundamentals (UI only)
FROM node:22-alpine

# Create a dedicated non-root user
RUN addgroup -S app && adduser -S -G app app

# Set working directory
WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy application source code
COPY . .

# Build production bundle
RUN npm run build

# Set ownership
RUN chown -R app:app /app

# Run as non-root user
USER app

# Expose Vite preview port
EXPOSE 4173

# Start preview server
CMD ["npm", "run", "preview", "--", "--host", "0.0.0.0", "--port", "4173"]
