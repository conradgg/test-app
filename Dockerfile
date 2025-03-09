FROM node:22.14.0 AS build

WORKDIR /app
COPY package*.json ./
RUN npm i
COPY . .
RUN npm run build

FROM nginx:1.26.3

COPY --from=build /app/dist /usr/share/nginx/html
