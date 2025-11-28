# Builder stage
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm install 

COPY . .

ARG VITE_APP_TMDB_V3_API_KEY

ENV VITE_APP_TMDB_V3_API_KEY=$VITE_APP_TMDB_V3_API_KEY

ENV VITE_APP_API_ENDPOINT_URL=https://api.themoviedb.org/3

RUN npm run build

# Final stage

FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx","-g","daemon off;"]

