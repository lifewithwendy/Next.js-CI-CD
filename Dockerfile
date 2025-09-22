# 1. Build stage
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files first (better caching)
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy rest of the code
COPY . .

# Build the application
RUN npm run build

# Remove devDependencies to minimize node_modules size
RUN npm prune --production

# 2. Production stage
FROM node:18-alpine AS production

# Set working directory
WORKDIR /app

# Copy only the necessary files from the builder stage
COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# Expose Next.js port
EXPOSE 3000

# Start app
CMD ["npm", "start"]